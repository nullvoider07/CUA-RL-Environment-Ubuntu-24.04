#!/bin/bash

# Default Configuration
EYE_BIN="/usr/local/bin/eye"
LOG_FILE="$HOME/eye_agent.log"
CONFIG_DIR="$HOME/.eye"
SERVER_FILE="$CONFIG_DIR/server_url"
TOKEN_FILE="$CONFIG_DIR/token"

# 1. Ensure Display Environment
export DISPLAY=${DISPLAY:-:0}
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY=$(find /run/user/$(id -u)/ -name "Xauthority" 2>/dev/null | head -n 1)
fi

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

discover_server() {
    # Option A: Check Config File
    if [ -f "$SERVER_FILE" ]; then
        url=$(cat "$SERVER_FILE" | tr -d '[:space:]')
        if curl -s --head --fail --max-time 1 "$url/health" >/dev/null; then echo "$url"; return; fi
    fi

    # Option B: Check Docker Gateway (Auto-Discovery)
    gateway=$(ip route show default | awk '/default/ {print $3}')
    if [ -n "$gateway" ]; then
        if curl -s --head --fail --max-time 1 "http://$gateway:8080/health" >/dev/null; then echo "http://$gateway:8080"; return; fi
    fi

    # Option C: Localhost
    if curl -s --head --fail --max-time 1 "http://localhost:8080/health" >/dev/null; then echo "http://localhost:8080"; return; fi
}

log "=== Eye Agent Daemon Started ==="

while true; do
    # Load Token (if exists)
    TOKEN=""
    [ -f "$TOKEN_FILE" ] && TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')

    # Find Server
    SERVER=$(discover_server)

    if [ -z "$SERVER" ]; then
        log "[WAIT] No server found. Retrying in 5s..."
        sleep 5
        continue
    fi

    log "[START] Launching Agent -> $SERVER"
    
    # Build Command
    CMD="$EYE_BIN agent start --server $SERVER --interval 1.5 --format png"
    [ -n "$TOKEN" ] && CMD="$CMD --token $TOKEN"

    # Run (unbuffered output)
    stdbuf -oL -eL $CMD >> "$LOG_FILE" 2>&1
    
    log "[STOP] Agent exited (Code: $?). Restarting in 2s..."
    sleep 2
done