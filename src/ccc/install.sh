#!/usr/bin/env bash

# Variables
REPO_OWNER="jsburckhardt"
REPO_NAME="co-config"
BINARY_NAME="ccc"
CCC_VERSION="${VERSION:-"latest"}"
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
check_packages curl jq ca-certificates tar

# Function to get the latest version from GitHub API
get_latest_version() {
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$CCC_VERSION" ] || [ "$CCC_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    CCC_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $CCC_VERSION"
else
    echo "Installing version from environment variable: $CCC_VERSION"
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
# Asset pattern: co-config_{os}_{arch}.tar.gz
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${CCC_VERSION}/${REPO_NAME}_${OS}_${ARCH}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "${BINARY_NAME}.tar.gz"

# Extract the tarball
echo "Extracting $BINARY_NAME..."
tar -xzf "${BINARY_NAME}.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing $BINARY_NAME..."
mv "$BINARY_NAME" /usr/local/bin/
chmod +x /usr/local/bin/$BINARY_NAME

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
$BINARY_NAME --version

echo "Done!"
