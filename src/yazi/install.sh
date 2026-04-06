#!/usr/bin/env bash

# Variables
REPO_OWNER="sxyazi"
REPO_NAME="yazi"
BINARY_NAME="yazi"
YAZI_VERSION="${VERSION:-"latest"}"
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

# Make sure we have curl, jq, and unzip
check_packages curl jq ca-certificates unzip

# Function to get the latest version from GitHub API
get_latest_version() {
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$YAZI_VERSION" ] || [ "$YAZI_VERSION" == "latest" ]; then
    YAZI_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $YAZI_VERSION"
else
    echo "Installing version from environment variable: $YAZI_VERSION"
fi

# Determine the OS and architecture
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    aarch64)
        ARCH="aarch64"
        ;;
    i686)
        ARCH="i686"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Construct the download URL
# Asset pattern: yazi-{ARCH}-unknown-linux-gnu.zip
ASSET_NAME="${BINARY_NAME}-${ARCH}-unknown-linux-gnu"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${YAZI_VERSION}/${ASSET_NAME}.zip"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "${BINARY_NAME}.zip"

# Extract the zip
echo "Extracting $BINARY_NAME..."
unzip -q "${BINARY_NAME}.zip"

# Move the binaries to /usr/local/bin
echo "Installing $BINARY_NAME..."
mv "${ASSET_NAME}/${BINARY_NAME}" /usr/local/bin/
mv "${ASSET_NAME}/ya" /usr/local/bin/
chmod +x /usr/local/bin/$BINARY_NAME
chmod +x /usr/local/bin/ya

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
$BINARY_NAME --version

echo "Done!"
