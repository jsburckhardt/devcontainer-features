#!/usr/bin/env bash

# Variables
REPO_OWNER="charmbracelet"
REPO_NAME="glow"
BINARY_NAME="glow"
GLOW_VERSION="${VERSION:-"latest"}"
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
if [ -z "$GLOW_VERSION" ] || [ "$GLOW_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    GLOW_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $GLOW_VERSION"
else
    echo "Installing version from environment variable: $GLOW_VERSION"
fi

# Strip the leading 'v' for the download URL filename
VERSION_NO_V="${GLOW_VERSION#v}"

# Determine the OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    i686 | i386)
        ARCH="i386"
        ;;
    aarch64 | arm64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="arm"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    Linux)
        OS="Linux"
        ;;
    Darwin)
        OS="Darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${GLOW_VERSION}/glow_${VERSION_NO_V}_${OS}_${ARCH}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading glow from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "glow.tar.gz"

# Extract the tarball
echo "Extracting glow..."
tar -xzf "glow.tar.gz"

# Find the extracted binary (tarball uses glow_VERSION_OS_ARCH/ directory)
EXTRACTED_DIR=$(find . -name "glow_*" -type d | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted glow directory"
    exit 1
fi

# Move the binary to /usr/local/bin
echo "Installing glow..."
mv "${EXTRACTED_DIR}/glow" /usr/local/bin/
chmod +x /usr/local/bin/glow

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
glow --version

echo "Done!"
