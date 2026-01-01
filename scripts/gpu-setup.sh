#!/bin/bash
# /usr/local/bin/gpu-setup.sh
# CONFIGURATOR & TUNING ORCHESTRATOR

set -euo pipefail
LOG="/var/log/gpu-setup.log"
mkdir -p "$(dirname "$LOG")"
exec >> "$LOG" 2>&1

echo "=== GPU SETUP START $(date) ==="

# CLEAN STALE LOCKS
echo "Cleaning stale locks..."
rm -rf /tmp/.X*-lock /tmp/.X11-unix /tmp/ssh-* /tmp/gpg-* /tmp/dbus-*
find /run/user/1001/ -type f -delete 2>/dev/null || true
rm -rf /var/lib/gdm3/.config /var/lib/gdm3/.local

# CLEAN STALE DBUS KEYS
USER_HOME=$(getent passwd 1001 | cut -d: -f6)
if [ -d "$USER_HOME" ]; then
    echo "Wiping stale DBus keyrings for user..."
    rm -rf "$USER_HOME/.dbus" "$USER_HOME/.dbus-keyrings"
fi

# PREPARE X11 SOCKETS
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
chown root:root /tmp/.X11-unix

# 1. D-Bus Setup
dbus-uuidgen --ensure=/var/lib/dbus/machine-id 2>/dev/null || true
ln -sf /var/lib/dbus/machine-id /etc/machine-id 2>/dev/null || true


# 2. Start Networking
echo "Enabling and starting NetworkManager..."
systemctl enable NetworkManager --now >/dev/null 2>&1 || true &
echo "NetworkManager started background init..."

# 3. XORG CONFIGURATION
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "Detecting NVIDIA GPU Bus ID..."
    BUS_ID_HEX=$(nvidia-smi --query-gpu=pci.bus_id --format=csv,noheader | head -n 1)
    # Convert Hex "0000:01:00.0" -> Decimal "PCI:1:0:0"
    BUS_ID_DEC=$(echo "$BUS_ID_HEX" | awk -F: '{printf "PCI:%d:%d:%d", strtonum("0x"$2), strtonum("0x"$3), strtonum("0x"$4)}')
    echo "Found NVIDIA GPU: $BUS_ID_HEX -> Config: $BUS_ID_DEC"

    CONF_FILE="/etc/X11/xorg.conf.d/20-nvidia-isolated.conf"
    if [ -f "$CONF_FILE" ]; then
        sed -i '/BusID/d' "$CONF_FILE"
        sed -i "/Driver.*\"nvidia\"/a \    BusID \"$BUS_ID_DEC\"" "$CONF_FILE"
        echo "Injected BusID ($BUS_ID_DEC) into $CONF_FILE"
    else
        echo "WARNING: Xorg config file missing!"
    fi
fi

# ==============================================================================
# 4. BACKGROUND ORCHESTRATION
# ==============================================================================
orchestrate_services() {
    # A. Wait for GDM's Xorg to be ready
    echo "Background: Waiting for Display :0..."
    for i in {1..45}; do
        if timeout 1 xdpyinfo -display :0 >/dev/null 2>&1; then
            echo "Xorg is live after ${i}s"
            break
        fi
        sleep 1
    done

    # B. Apply NVIDIA Performance Settings
    if command -v nvidia-settings >/dev/null 2>&1; then
        echo "Applying PowerMizer & Composition..."
        DISPLAY=:0 nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" >/dev/null 2>&1 || true
        DISPLAY=:0 nvidia-settings -a "[gpu:0]/GPUFanControlState=1" >/dev/null 2>&1 || true
        DISPLAY=:0 nvidia-settings -a "SyncToVBlank=1" >/dev/null 2>&1 || true
    fi

    # C. Start Peripherals (Your Parallel Logic)
    DESKTOP_USER="$(id -un 1001)"
    
    echo "Starting PulseAudio..."
    su - "$DESKTOP_USER" -c "pulseaudio --start --exit-idle-time=-1 --load=module-native-protocol-unix" >/dev/null 2>&1 || true

    echo "Restarting NoMachine..."
    /usr/NX/bin/nxserver --restart >/dev/null 2>&1 || true

    # D. Mutter Recovery & Fullscreen Redirect Enforcement
    sleep 3
    if ! pgrep -u "$DESKTOP_USER" -f gnome-shell >/dev/null; then
        echo "Monitor: GNOME Shell missing? Attempting restart..."
        su - "$DESKTOP_USER" -c "DISPLAY=:0 gnome-shell --replace &" >/dev/null 2>&1 || true
    fi
   
    echo "Background Orchestration Complete."
}

# Launch background logic and disown it so it survives script exit
orchestrate_services &
disown

# 5. Clean Locks
rm -rf /tmp/.X*-lock /tmp/.X11-unix/*

echo "=== GPU SETUP COMPLETE — Exiting to unblock GDM ==="
exit 0