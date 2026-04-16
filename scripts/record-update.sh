#!/usr/bin/env bash
# Parse `nvd diff <old> <new>` output and write a JSON summary
# consumed by the Homepage dashboard's customapi widget.
set -euo pipefail

OLD="${1:-}"
NEW="${2:-/run/current-system}"
OUT_DIR="/var/lib/homepage-updates"
OUT_FILE="$OUT_DIR/latest.json"

if [ -z "$OLD" ]; then
  echo "usage: record-update <old-system> [new-system]" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

DIFF=$(nvd diff "$OLD" "$NEW" 2>&1 || true)

CHANGES=$(printf '%s\n' "$DIFF" | grep -cE '^\[[UAR][.*]\]' || true)
CLOSURE=$(printf '%s\n' "$DIFF" | grep -oE 'disk usage [+-][0-9.]+[A-Za-z]*B?' | head -1 | sed 's/disk usage //')
CLOSURE="${CLOSURE:-+0B}"

KERNEL=$(uname -r)
DATE=$(date '+%Y-%m-%d %H:%M')

if [ "$CHANGES" = "0" ]; then
  LABEL="No changes"
else
  LABEL="$CHANGES package changes"
fi

cat > "$OUT_FILE.tmp" <<EOF
{
  "date": "$DATE",
  "changes": "$LABEL",
  "closure": "$CLOSURE",
  "kernel": "$KERNEL"
}
EOF
mv "$OUT_FILE.tmp" "$OUT_FILE"
