#!/usr/bin/env bash

# Variables
VIBE_KANBAN_VERSION="${VERSION:-"latest"}"

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

echo "Installing Vibe Kanban version: $VIBE_KANBAN_VERSION"

# Check if node and npm are available
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Node.js and npm are required but not found. Installing Node.js..."
    
    # Install Node.js using NodeSource setup script
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    check_packages nodejs
    
    # Verify installation
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        echo "ERROR: Failed to install Node.js and npm"
        exit 1
    fi
fi

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Install vibe-kanban globally
if [ "$VIBE_KANBAN_VERSION" = "latest" ]; then
    echo "Installing latest version of vibe-kanban..."
    npm install -g vibe-kanban
else
    echo "Installing vibe-kanban version $VIBE_KANBAN_VERSION..."
    npm install -g vibe-kanban@"$VIBE_KANBAN_VERSION"
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
if command -v vibe-kanban >/dev/null 2>&1; then
    vibe-kanban --version
    echo "Vibe Kanban installation completed successfully!"
else
    echo "Warning: vibe-kanban command not found in PATH. This might be expected if npm global bin is not in PATH."
    echo "Vibe Kanban has been installed via npm."
fi

echo "Done!"
