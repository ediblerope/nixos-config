#!/usr/bin/env bash
set -euo pipefail

# transcode-hevc — Batch re-encode H.264 video files to HEVC (x265)
#
# Usage:
#   transcode-hevc /mnt/disk1          # process all video files on disk1
#   transcode-hevc /mnt/storage/torrents/shows  # process a specific directory
#
# Features:
#   - Skips files already encoded as HEVC
#   - Tracks completed files in a log so it can resume after reboot
#   - Verifies output duration matches input before replacing
#   - Logs all activity to /var/log/transcode-hevc.log

FFMPEG="${FFMPEG_PATH:-$(command -v ffmpeg)}"
FFPROBE="${FFPROBE_PATH:-$(command -v ffprobe)}"

DONE_LOG="/var/lib/transcode-hevc/completed.log"
LOG_FILE="/var/log/transcode-hevc.log"
CRF="${TRANSCODE_CRF:-24}"
PRESET="${TRANSCODE_PRESET:-medium}"
DRY_RUN="${DRY_RUN:-0}"
QB_URL="${QB_URL:-http://localhost:8080}"

# Duration tolerance in seconds (allow 1s difference)
DURATION_TOLERANCE=1

# Build a set of file sizes actively seeded in qBittorrent.
# Queries each torrent's individual files for accurate per-file sizes.
# Radarr/Sonarr may rename files but preserve size, so matching by size
# reliably detects copies of seeded content across filesystems.
build_seeded_sizes() {
    local sizes_file="/tmp/transcode-hevc-seeded-sizes"
    rm -f "$sizes_file"
    touch "$sizes_file"

    local hashes
    hashes=$(curl -sf "${QB_URL}/api/v2/torrents/info" \
        | tr '}' '\n' | grep -o '"hash":"[^"]*"' | cut -d'"' -f4) || return 1

    for hash in $hashes; do
        curl -sf "${QB_URL}/api/v2/torrents/files?hash=${hash}" \
            | tr '}' '\n' | grep -o '"size":[0-9]*' | cut -d: -f2 \
            >> "$sizes_file" 2>/dev/null || true
    done

    sort -u -o "$sizes_file" "$sizes_file"
    echo "$sizes_file"
}

is_seeded_size() {
    local size="$1"
    local sizes_file="$2"
    [[ -n "$sizes_file" ]] && grep -Fxq "$size" "$sizes_file" 2>/dev/null
}

usage() {
    echo "Usage: transcode-hevc [OPTIONS] <directory>"
    echo ""
    echo "Options:"
    echo "  --dry-run     Show what would be done without encoding"
    echo "  --crf N       Set CRF value (default: 24)"
    echo "  --preset P    Set x265 preset (default: medium)"
    echo "  --status      Show progress stats and exit"
    echo "  -h, --help    Show this help"
    exit 0
}

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

get_codec() {
    "$FFPROBE" -v quiet -select_streams v:0 \
        -show_entries stream=codec_name -of csv=p=0 "$1" 2>/dev/null || echo "unknown"
}

get_duration() {
    "$FFPROBE" -v quiet -show_entries format=duration \
        -of csv=p=0 "$1" 2>/dev/null || echo "0"
}

get_size_human() {
    du -h "$1" 2>/dev/null | cut -f1
}

is_done() {
    grep -Fxq "$1" "$DONE_LOG" 2>/dev/null
}

mark_done() {
    echo "$1" >> "$DONE_LOG"
}

show_status() {
    if [[ ! -f "$DONE_LOG" ]]; then
        echo "No transcoding has been done yet."
        exit 0
    fi
    local done_count
    done_count=$(wc -l < "$DONE_LOG")
    echo "Completed files: $done_count"
    if [[ -f "$LOG_FILE" ]]; then
        local saved
        saved=$(grep "Saved:" "$LOG_FILE" | tail -20)
        if [[ -n "$saved" ]]; then
            echo ""
            echo "Recent savings:"
            echo "$saved"
        fi
    fi
    exit 0
}

# Parse arguments
SEARCH_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=1; shift ;;
        --crf)      CRF="$2"; shift 2 ;;
        --preset)   PRESET="$2"; shift 2 ;;
        --status)   show_status ;;
        -h|--help)  usage ;;
        *)          SEARCH_DIR="$1"; shift ;;
    esac
done

if [[ -z "$SEARCH_DIR" ]]; then
    echo "Error: No directory specified."
    echo ""
    usage
fi

if [[ ! -d "$SEARCH_DIR" ]]; then
    echo "Error: '$SEARCH_DIR' is not a directory."
    exit 1
fi

# Ensure state directories exist
mkdir -p "$(dirname "$DONE_LOG")"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$DONE_LOG"

log "Starting transcode run on: $SEARCH_DIR (CRF=$CRF, preset=$PRESET)"

# Build lookup of file sizes currently being seeded in qBittorrent
SEEDED_SIZES=""
if SEEDED_SIZES=$(build_seeded_sizes); then
    seeded_count=$(wc -l < "$SEEDED_SIZES")
    log "Loaded $seeded_count unique file sizes from qBittorrent (will skip matches)"
else
    log "WARNING: Could not reach qBittorrent API — seeded file detection disabled"
    SEEDED_SIZES=""
fi

# Counters
total=0
skipped_hevc=0
skipped_done=0
encoded=0
failed=0
saved_bytes=0

# Find all video files
while IFS= read -r -d '' file; do
    total=$((total + 1))

    # Never touch files in downloads directories (still being seeded)
    if [[ "$file" == */downloads/* ]]; then
        continue
    fi

    # Skip if already processed
    if is_done "$file"; then
        skipped_done=$((skipped_done + 1))
        continue
    fi

    # Check codec
    codec=$(get_codec "$file")
    if [[ "$codec" == "hevc" || "$codec" == "h265" ]]; then
        skipped_hevc=$((skipped_hevc + 1))
        mark_done "$file"
        continue
    fi

    if [[ "$codec" != "h264" ]]; then
        log "Skipping (codec=$codec): $file"
        continue
    fi

    # Skip files with hardlinks (likely still linked to downloads for seeding)
    link_count=$(stat -c%h "$file")
    if [[ "$link_count" -gt 1 ]]; then
        log "Skipping (hardlinked, likely still seeding): $file"
        continue
    fi

    original_size=$(stat -c%s "$file")

    # Skip files whose size matches an actively seeded torrent file in qBittorrent
    # (catches cross-filesystem copies where hardlink detection doesn't work)
    if is_seeded_size "$original_size" "$SEEDED_SIZES"; then
        log "Skipping (size matches seeded torrent): $file"
        continue
    fi
    original_size_h=$(get_size_human "$file")
    original_duration=$(get_duration "$file")

    if [[ "$DRY_RUN" == "1" ]]; then
        log "[DRY RUN] Would encode: $file ($original_size_h)"
        continue
    fi

    log "Encoding: $file ($original_size_h)"

    # Always output as MKV — it supports all codecs/subtitle formats
    dir=$(dirname "$file")
    base=$(basename "$file")
    name="${base%.*}"
    tmp_file="${dir}/.transcode-${name}.mkv"
    final_file="${dir}/${name}.mkv"

    # Clean up any leftover temp file from a previous interrupted run
    rm -f "$tmp_file"

    if "$FFMPEG" -nostdin -y \
        -i "$file" \
        -map 0:v:0 -map 0:a -map 0:s? \
        -c:v libx265 -crf "$CRF" -preset "$PRESET" \
        -c:a copy \
        -c:s copy \
        "$tmp_file" \
        </dev/null 2>> "$LOG_FILE"; then

        # Verify duration matches
        new_duration=$(get_duration "$tmp_file")
        duration_diff=$(echo "$original_duration $new_duration" | awk '{d=$1-$2; print (d<0?-d:d)}')

        if (( $(echo "$duration_diff > $DURATION_TOLERANCE" | bc -l) )); then
            log "FAILED (duration mismatch: ${original_duration}s vs ${new_duration}s): $file"
            rm -f "$tmp_file"
            failed=$((failed + 1))
            continue
        fi

        new_size=$(stat -c%s "$tmp_file")
        new_size_h=$(get_size_human "$tmp_file")
        diff_bytes=$((original_size - new_size))
        saved_bytes=$((saved_bytes + diff_bytes))
        diff_h=$(numfmt --to=iec "$diff_bytes" 2>/dev/null || echo "${diff_bytes}B")

        # Move temp to final destination
        mv "$tmp_file" "$final_file"
        # Remove original if it was a different format (e.g. .mp4 -> .mkv)
        if [[ "$file" != "$final_file" ]]; then
            rm -f "$file"
        fi
        mark_done "$final_file"
        encoded=$((encoded + 1))

        log "Done: $file ($original_size_h -> $new_size_h) Saved: $diff_h"
    else
        log "FAILED (ffmpeg error): $file"
        rm -f "$tmp_file"
        failed=$((failed + 1))
    fi

done < <(find "$SEARCH_DIR" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) -print0 | sort -z)

saved_total=$(numfmt --to=iec "$saved_bytes" 2>/dev/null || echo "${saved_bytes}B")

log ""
log "=== Transcode complete ==="
log "Total files found:    $total"
log "Already HEVC:         $skipped_hevc"
log "Previously completed: $skipped_done"
log "Encoded this run:     $encoded"
log "Failed:               $failed"
log "Space saved this run: $saved_total"
