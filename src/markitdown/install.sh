#!/usr/bin/env bash

# Variables
REPO_OWNER="microsoft"
REPO_NAME="markitdown"
BINARY_NAME="markitdown"
MARKITDOWN_VERSION="${VERSION:-"latest"}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

set -e

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

# Make sure we have required packages
check_packages curl jq ca-certificates python3 python3-pip pipx

# Function to get the latest version from GitHub API
get_latest_version() {
    local version
    version=$(curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name")
    # Strip leading 'v' if present
    echo "${version#v}"
}

# Check if a version is passed as an argument
if [ -z "$MARKITDOWN_VERSION" ] || [ "$MARKITDOWN_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    MARKITDOWN_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $MARKITDOWN_VERSION"
else
    # Strip leading 'v' if user provided it
    MARKITDOWN_VERSION="${MARKITDOWN_VERSION#v}"
    echo "Installing version from environment variable: $MARKITDOWN_VERSION"
fi

# Ensure PIPX_HOME and PIPX_BIN_DIR are set for root installs
export PIPX_HOME="${PIPX_HOME:-/opt/pipx}"
export PIPX_BIN_DIR="${PIPX_BIN_DIR:-/usr/local/bin}"

# Install markitdown via pipx
echo "Installing markitdown==${MARKITDOWN_VERSION} via pipx..."
pipx install "markitdown==${MARKITDOWN_VERSION}"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
markitdown --version

echo "Done!"
