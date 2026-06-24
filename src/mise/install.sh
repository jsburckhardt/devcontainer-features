#!/usr/bin/env bash

# Variables
REPO_OWNER="jdx"
REPO_NAME="mise"
BINARY_NAME="mise"
MISE_VERSION="${VERSION:-"latest"}"
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

# Make sure we have curl and jq
check_packages curl jq ca-certificates

# Function to get the latest version from GitHub API
get_latest_version() {
    local version
    version=$(curl -fsSL "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name")
    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "Failed to resolve latest mise version from GitHub API (possibly rate-limited)." >&2
        return 1
    fi
    echo "$version"
}

# Check if a version is passed as an argument
if [ -z "$MISE_VERSION" ] || [ "$MISE_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    MISE_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $MISE_VERSION"
else
    echo "Installing version from environment variable: $MISE_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="armv7"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        OS="linux"
        ;;
    darwin)
        OS="macos"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL (mise provides standalone binaries)
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-${OS}-${ARCH}"

echo "Downloading mise from $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" -o /usr/local/bin/mise

# Make binary executable
chmod +x /usr/local/bin/mise

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
mise --version

echo "Done!"
