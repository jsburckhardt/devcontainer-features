#!/usr/bin/env bash

# Variables
REPO_OWNER="alibaba"
REPO_NAME="open-code-review"
BINARY_NAME="opencodereview"
OCR_VERSION="${VERSION:-"latest"}"
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
    curl -fsSL "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$OCR_VERSION" ] || [ "$OCR_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    OCR_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $OCR_VERSION"
else
    echo "Installing version from environment variable: $OCR_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
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
        OS="darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL
# Asset pattern: opencodereview-<os>-<arch>
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${OCR_VERSION}/${BINARY_NAME}-${OS}-${ARCH}"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading opencodereview from $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" -o "${BINARY_NAME}"

# Move the binary to /usr/local/bin
echo "Installing opencodereview..."
chmod +x "${BINARY_NAME}"
mv "${BINARY_NAME}" /usr/local/bin/

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
opencodereview --version

echo "Done!"
