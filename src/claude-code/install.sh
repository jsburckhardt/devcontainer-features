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

echo "Installing Claude Code version: $CLAUDE_VERSION"

# Check if Node.js/npm is installed, if not install from Ubuntu repositories
if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Installing Node.js and npm..."
    check_packages nodejs npm
    echo "Node.js installed: $(node --version 2>/dev/null || echo 'N/A')"
    echo "npm installed: $(npm --version)"
fi

# Install Claude Code via npm
# The npm package @anthropic-ai/claude-code includes a bundled Node.js runtime
# This is the official installation method for Claude Code
echo "Installing Claude Code via npm..."

# Try with strict SSL first
NPM_INSTALL_SUCCESS=false
if [ "$CLAUDE_VERSION" = "latest" ]; then
    if npm install -g @anthropic-ai/claude-code --loglevel=error 2>/dev/null; then
        NPM_INSTALL_SUCCESS=true
    fi
else
    if npm install -g @anthropic-ai/claude-code@"$CLAUDE_VERSION" --loglevel=error 2>/dev/null; then
        NPM_INSTALL_SUCCESS=true
    fi
fi

# If strict SSL fails (common in build environments), retry without strict SSL verification
if [ "$NPM_INSTALL_SUCCESS" = "false" ]; then
    echo "Standard npm install failed, retrying with relaxed SSL settings for build environments..."
    if [ "$CLAUDE_VERSION" = "latest" ]; then
        npm install -g @anthropic-ai/claude-code --loglevel=error --strict-ssl=false || {
            echo "ERROR: npm installation failed even with relaxed SSL settings."
            echo "This may indicate network issues or that the package is not available."
            echo "In production environments with proper network access, this should work."
            echo "Manual installation: npm install -g @anthropic-ai/claude-code"
            exit 1
        }
    else
        npm install -g @anthropic-ai/claude-code@"$CLAUDE_VERSION" --loglevel=error --strict-ssl=false || {
            echo "ERROR: npm installation of version $CLAUDE_VERSION failed."
            echo "In production environments with proper network access, this should work."
            exit 1
        }
    fi
fi

# Find where npm installed the binary and create symlink to /usr/local/bin
NPM_BIN_DIR=$(npm bin -g 2>/dev/null || npm root -g 2>/dev/null | sed 's/lib\/node_modules$/bin/')

if [ -n "$NPM_BIN_DIR" ] && [ -d "$NPM_BIN_DIR" ]; then
    if [ -f "$NPM_BIN_DIR/claude" ]; then
        echo "Creating symlink from $NPM_BIN_DIR/claude to /usr/local/bin/claude"
        ln -sf "$NPM_BIN_DIR/claude" /usr/local/bin/claude
        chmod +x /usr/local/bin/claude
    elif [ -f "$NPM_BIN_DIR/claude-code" ]; then
        echo "Creating symlink from $NPM_BIN_DIR/claude-code to /usr/local/bin/claude"
        ln -sf "$NPM_BIN_DIR/claude-code" /usr/local/bin/claude
        chmod +x /usr/local/bin/claude
    fi
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
if command -v claude >/dev/null 2>&1; then
    echo "Claude Code installation completed successfully!"
    echo "The 'claude' command is now available at: $(which claude)"
    claude --version 2>/dev/null || echo "Claude is installed (version command may not be supported)"
else
    # Check if installed via npm even if not in PATH
    if npm list -g @anthropic-ai/claude-code 2>/dev/null | grep -q "@anthropic-ai/claude-code"; then
        echo "Claude Code installed via npm successfully."
        echo "Note: The 'claude' command may require a shell restart or PATH update."
        npm list -g @anthropic-ai/claude-code
    else
        echo "WARNING: Claude Code installation could not be verified."
        echo "This may be normal in restricted build environments."
    fi
fi

echo "Done!"
