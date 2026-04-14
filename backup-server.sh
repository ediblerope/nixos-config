#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/mnt/disk4/server-backup-$(date +%Y%m%d)"
echo "Backing up to: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Stop services first to get clean copies
echo "Stopping services..."
sudo systemctl stop jellyfin sonarr radarr prowlarr bazarr qbittorrent-nox authelia-main 2>/dev/null || true
sleep 3

# Service databases and config
for dir in jellyfin sonarr radarr prowlarr bazarr qbittorrent authelia-main; do
  if [ -d "/var/lib/$dir" ]; then
    echo "Backing up /var/lib/$dir ..."
    sudo mkdir -p "$BACKUP_DIR/var-lib/$dir"
    sudo rsync -a "/var/lib/$dir/" "$BACKUP_DIR/var-lib/$dir/"
  else
    echo "Skipping /var/lib/$dir (not found)"
  fi
done

# Secrets
if [ -d "/var/secrets" ]; then
  echo "Backing up /var/secrets ..."
  sudo mkdir -p "$BACKUP_DIR/var-secrets"
  sudo rsync -a "/var/secrets/" "$BACKUP_DIR/var-secrets/"
else
  echo "Skipping /var/secrets (not found)"
fi

echo ""
echo "Backup complete: $BACKUP_DIR"
echo ""
echo "Size: $(sudo du -sh "$BACKUP_DIR" | cut -f1)"
echo ""
echo "NOTE: Media files on /mnt/storage are NOT included — move the data disks to the new server directly."
echo ""
echo "Restarting services..."
sudo systemctl start jellyfin sonarr radarr prowlarr bazarr qbittorrent-nox authelia-main 2>/dev/null || true
