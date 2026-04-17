#!/bin/sh
set -e

FEATURE_DIR="/usr/local/share/jsburckhardt-devcontainer-features/copilot-persistence"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

mkdir -p "${FEATURE_DIR}"
echo "" > "$LOG_FILE"

log() {
    echo "$1"
    echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'copilot-persistence'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

# Skip if already installed
if [ -f "$FEATURE_DIR/markers/install" ]; then
    log "Feature 'copilot-persistence' already installed, skipping"
    exit 0
fi

# Back up existing .copilot folder if present
got_old_copilot_folder=false
if [ -e "$_REMOTE_USER_HOME/.copilot" ]; then
    log "Moving existing .copilot folder to .copilot-old"
    mv "$_REMOTE_USER_HOME/.copilot" "$_REMOTE_USER_HOME/.copilot-old"
    got_old_copilot_folder=true
else
    log "No existing .copilot folder found at '$_REMOTE_USER_HOME/.copilot'"
fi

# Create symlink from ~/.copilot to the mounted volume
ln -s /dc/copilot/ "$_REMOTE_USER_HOME/.copilot"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.copilot"

# Copy lifecycle scripts
if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
    chmod +x "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi

# Mark as installed
log "Adding marker file to indicate persistence is installed"
mkdir -p "$FEATURE_DIR/markers"
touch "$FEATURE_DIR/markers/install"
