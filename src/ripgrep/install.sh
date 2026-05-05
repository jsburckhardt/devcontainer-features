#!/usr/bin/env bash

# Variables
REPO_OWNER="BurntSushi"
REPO_NAME="ripgrep"
BINARY_NAME="rg"
RIPGREP_VERSION="${VERSION:-"latest"}"
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
if [ -z "$RIPGREP_VERSION" ] || [ "$RIPGREP_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    RIPGREP_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $RIPGREP_VERSION"
else
    echo "Installing version from environment variable: $RIPGREP_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH_TRIPLE="x86_64-unknown-linux-musl"
        ;;
    i686)
        ARCH_TRIPLE="i686-unknown-linux-gnu"
        ;;
    aarch64)
        ARCH_TRIPLE="aarch64-unknown-linux-gnu"
        ;;
    armv7l)
        ARCH_TRIPLE="armv7-unknown-linux-gnueabihf"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        # ARCH_TRIPLE already set above for linux
        ;;
    darwin)
        case "$ARCH" in
            x86_64)
                ARCH_TRIPLE="x86_64-apple-darwin"
                ;;
            aarch64|arm64)
                ARCH_TRIPLE="aarch64-apple-darwin"
                ;;
            *)
                echo "Unsupported architecture on macOS: $ARCH"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${ARCH_TRIPLE}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading ripgrep from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "ripgrep.tar.gz"

# Extract the tarball
echo "Extracting ripgrep..."
tar -xzf "ripgrep.tar.gz"

# Find the extracted directory
EXTRACTED_DIR=$(find . -name "ripgrep-${RIPGREP_VERSION}-*" -type d | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted ripgrep directory"
    exit 1
fi

# Move the binary to /usr/local/bin
echo "Installing ripgrep..."
mv "${EXTRACTED_DIR}/rg" /usr/local/bin/

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
rg --version

echo "Done!"
