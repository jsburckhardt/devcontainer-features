#!/usr/bin/env bash

# Variables
REPO_OWNER="ynqa"
REPO_NAME="jnv"
JNV_VERSION="${VERSION:-"latest"}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    aarch64)
        ARCH="aarch64"
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
        OS="unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported OS: $OS (devcontainer features only support Linux)"
        exit 1
        ;;
esac

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

# Function to get the latest version from GitHub API
get_latest_version() {
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Make sure we have required packages
check_packages curl tar jq ca-certificates xz-utils

# Check if a version is passed as an argument
if [ -z "$JNV_VERSION" ] || [ "$JNV_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    JNV_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $JNV_VERSION"
else
    echo "Installing version from environment variable: $JNV_VERSION"
fi

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${JNV_VERSION}/jnv-${ARCH}-${OS}.tar.xz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading jnv from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "jnv.tar.xz" || {
    echo "Failed to download $DOWNLOAD_URL"
    exit 1
}

# Extract the archive
echo "Extracting jnv..."
unxz "jnv.tar.xz" || {
    echo "Failed to decompress jnv.tar.xz"
    exit 1
}

tar -xf "jnv.tar" || {
    echo "Failed to extract jnv.tar"
    exit 1
}

# Find the extracted directory (it should match the archive name pattern)
EXTRACTED_DIR=$(find . -name "jnv-${ARCH}-${OS}" -type d | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted jnv directory"
    exit 1
fi

# Move the binary to /usr/local/bin
echo "Installing jnv..."
install -m 755 "${EXTRACTED_DIR}/jnv" /usr/local/bin/jnv || {
    echo "Failed to install jnv binary"
    exit 1
}

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
jnv --version || {
    echo "Installation verification failed"
    exit 1
}

echo "Done!"
