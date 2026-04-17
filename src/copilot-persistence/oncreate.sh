#!/usr/bin/env bash
set -e

FEATURE_DIR="/usr/local/share/jsburckhardt-devcontainer-features/copilot-persistence"
LOG_FILE="$FEATURE_DIR/log.txt"

log() {
    echo "$1"
    echo "$1" >> "$LOG_FILE"
}

# Fix permissions on the log file so the remote user can write to it
if command -v sudo > /dev/null; then
    sudo chown -R "$(id -u):$(id -g)" "$LOG_FILE"
else
    chown -R "$(id -u):$(id -g)" "$LOG_FILE"
fi

log "In OnCreate script"

# Skip if oncreate actions already ran
if [ -f "$FEATURE_DIR/markers/oncreate" ]; then
    log "Feature 'copilot-persistence' oncreate actions already run, skipping"
    exit 0
fi

fix_permissions() {
    local dir="${1}"
    if [ ! -w "${dir}" ]; then
        echo "Fixing permissions of '${dir}'..."
        sudo chown -R "$(id -u):$(id -g)" "${dir}"
        echo "Done!"
    else
        echo "Permissions of '${dir}' are OK!"
    fi
}

fix_permissions "/dc/copilot"

# Mark oncreate as done
log "Adding marker file to indicate oncreate actions have been run"
mkdir -p "$FEATURE_DIR/markers"
if command -v sudo > /dev/null; then
    sudo touch "$FEATURE_DIR/markers/oncreate"
else
    touch "$FEATURE_DIR/markers/oncreate"
fi

log "Done"
