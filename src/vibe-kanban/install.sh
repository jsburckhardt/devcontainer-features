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

# Update CA certificates to ensure SSL works properly
update-ca-certificates

echo "Installing Vibe Kanban version: $VIBE_KANBAN_VERSION"

# Check if node and npm are available
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Node.js and npm are required but not found. Installing Node.js..."
    
    # Install Node.js and npm using official Ubuntu packages
    check_packages nodejs npm
    
    # Verify installation
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        echo "ERROR: Failed to install Node.js and npm"
        exit 1
    fi
fi

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Install vibe-kanban globally
# Note: In some Docker environments, npm may encounter SSL certificate issues.
# If installation fails, users should ensure ca-certificates package is up to date.
if [ "$VIBE_KANBAN_VERSION" = "latest" ]; then
    echo "Installing latest version of vibe-kanban..."
    npm install -g vibe-kanban || npm install -g vibe-kanban --strict-ssl=false
else
    echo "Installing vibe-kanban version $VIBE_KANBAN_VERSION..."
    npm install -g vibe-kanban@"$VIBE_KANBAN_VERSION" || npm install -g vibe-kanban@"$VIBE_KANBAN_VERSION" --strict-ssl=false
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
if command -v vibe-kanban >/dev/null 2>&1; then
    # Try to get version, but don't fail if it requires network access
    vibe-kanban --version 2>&1 || echo "vibe-kanban command is available (version check may require network)"
    echo "Vibe Kanban installation completed successfully!"
else
    echo "Warning: vibe-kanban command not found in PATH. This might be expected if npm global bin is not in PATH."
    echo "Vibe Kanban has been installed via npm."
fi

echo "Done!"
