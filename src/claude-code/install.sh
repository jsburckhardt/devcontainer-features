#!/usr/bin/env bash

# Variables
CLAUDE_VERSION="${VERSION:-"latest"}"

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Make sure we have curl and ca-certificates
check_packages curl ca-certificates

echo "Installing Claude Code version: $CLAUDE_VERSION"

# Download and execute the official Claude Code installation script
# The script handles platform detection, binary download from Google's servers, and installation
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

# Download the official install script from claude.ai
# The script is the same regardless of version; version is passed as an argument
echo "Downloading Claude Code installer..."
curl -fsSL https://claude.ai/install.sh -o install.sh

# Make the script executable
chmod +x install.sh

# Run the installation script
# The official installer accepts version as an argument according to documentation:
# curl -fsSL https://claude.ai/install.sh | bash -s latest
# curl -fsSL https://claude.ai/install.sh | bash -s 1.0.58
if [ "$CLAUDE_VERSION" = "latest" ]; then
    echo "Installing latest version of Claude Code..."
    bash install.sh || {
        echo "Warning: Installation script failed. This may be expected if the official installer doesn't support unattended installation."
        exit 1
    }
else
    echo "Installing Claude Code version $CLAUDE_VERSION..."
    bash install.sh "$CLAUDE_VERSION" || {
        echo "Warning: Installation script with version argument failed."
        echo "Retrying without version argument..."
        bash install.sh || {
            echo "Warning: Installation script failed. This may be expected if the official installer doesn't support unattended installation."
            exit 1
        }
    }
fi

# Clean up
cd - >/dev/null
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
if command -v claude >/dev/null 2>&1; then
    echo "Claude Code installation completed successfully!"
    echo "The 'claude' command is now available."
else
    echo "Warning: Claude Code installed but 'claude' command not found in PATH."
    echo "You may need to restart your shell or check your PATH configuration."
fi

echo "Done!"
