#!/usr/bin/env bash

# Variables
REPO_OWNER="ajeetdsouza"
REPO_NAME="zoxide"
BINARY_NAME="zoxide"
ZOXIDE_VERSION="${VERSION:-"latest"}"
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
if [ -z "$ZOXIDE_VERSION" ] || [ "$ZOXIDE_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    ZOXIDE_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $ZOXIDE_VERSION"
else
    echo "Installing version from environment variable: $ZOXIDE_VERSION"
fi

# Strip the leading 'v' for the download URL filename
VERSION_NO_V="${ZOXIDE_VERSION#v}"

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
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        OS="unknown-linux-musl"
        ;;
    darwin)
        OS="apple-darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${ZOXIDE_VERSION}/zoxide-${VERSION_NO_V}-${ARCH}-${OS}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading zoxide from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "zoxide.tar.gz"

# Extract the tarball
echo "Extracting zoxide..."
tar -xzf "zoxide.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing zoxide..."
mv zoxide /usr/local/bin/
chmod +x /usr/local/bin/zoxide

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
zoxide --version

echo "Done!"
