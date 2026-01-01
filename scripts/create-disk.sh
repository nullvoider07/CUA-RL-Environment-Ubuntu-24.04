#!/bin/bash
set -euo pipefail

LOG="/var/log/x_start.log"
echo "=== CREATE DISK START $(date) ===" >> "$LOG"

# === DEFAULT: 8GB (always created) ===
SIZE="${CUA_DISK_SIZE:-8G}"

DISK_PATH="/var/lib/cua/disk.img"
MOUNTPOINT="/mnt/data"

# === 1. FORCE FRESH START (The Fix) ===
if [ -f "$DISK_PATH" ]; then
    echo "Found old disk. Wiping for fresh start..." >> "$LOG"
    rm -f "$DISK_PATH"
fi

# === 2. CREATE + FORMAT ===
mkdir -p "$(dirname "$DISK_PATH")"
chown 1001:1001 "$(dirname "$DISK_PATH")"

echo "Creating fresh $SIZE disk..." >> "$LOG"
truncate -s "$SIZE" "$DISK_PATH"
mkfs.ext4 -F -L CUA-DATA "$DISK_PATH" >> "$LOG" 2>&1

# === 3. MOUNT ===
mkdir -p "$MOUNTPOINT"
chown 1001:1001 "$MOUNTPOINT"

if ! mountpoint -q "$MOUNTPOINT"; then
    mount -o loop,uid=1001,gid=1001 "$DISK_PATH" "$MOUNTPOINT"
    echo "Mounted at $MOUNTPOINT" >> "$LOG"
fi

# === 4. FSTAB ===
sed -i "|$DISK_PATH|d" /etc/fstab
echo "$DISK_PATH $MOUNTPOINT ext4 loop,defaults,noatime,uid=1001,gid=1001 0 2" >> /etc/fstab

echo "DISK READY: $(df -h "$MOUNTPOINT" | tail -1)" >> "$LOG"