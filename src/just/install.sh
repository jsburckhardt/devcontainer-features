#!/usr/bin/env bash

# Variables
REPO_OWNER="casey"
REPO_NAME="just"
BINARY_NAME="just"
JUST_VERSION="${VERSION:-"latest"}"
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
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$JUST_VERSION" ] || [ "$JUST_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    JUST_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $JUST_VERSION"
else
    echo "Installing version from environment variable: $JUST_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    i686)
        ARCH="i686"
        ;;
    aarch64)
        ARCH="aarch64"
        ;;
    armv7l)
        ARCH="armv7"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        TARGET="${ARCH}-unknown-linux-musl"
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${TARGET}.tar.gz"

echo "Downloading just from: ${DOWNLOAD_URL}"

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and extract
curl -L -o "just.tar.gz" "${DOWNLOAD_URL}"
tar -xzf "just.tar.gz"

# Find the extracted directory (it might be just 'just' or contain version info)
EXTRACTED_DIR=$(find . -type d -name "*just*" | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    # Maybe the binary is directly in the archive
    if [ -f "just" ]; then
        EXTRACTED_DIR="."
    else
        echo "ERROR: Could not find extracted just directory or binary"
        exit 1
    fi
fi

# Move the binary to /usr/local/bin
echo "Installing just..."
if [ -f "${EXTRACTED_DIR}/just" ]; then
    mv "${EXTRACTED_DIR}/just" /usr/local/bin/
elif [ -f "just" ]; then
    mv "just" /usr/local/bin/
else
    echo "ERROR: Could not find just binary"
    exit 1
fi

# Make sure it's executable
chmod +x /usr/local/bin/just

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
just --version

echo "Done!"