#!/usr/bin/env bash

# Variables
REPO_OWNER="rtk-ai"
REPO_NAME="rtk"
BINARY_NAME="rtk"
RTK_VERSION="${VERSION:-"latest"}"
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
if [ -z "$RTK_VERSION" ] || [ "$RTK_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    RTK_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $RTK_VERSION"
else
    echo "Installing version from environment variable: $RTK_VERSION"
fi

# Determine the OS and architecture
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH_TRIPLE="x86_64-unknown-linux-musl"
        ;;
    aarch64)
        ARCH_TRIPLE="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${RTK_VERSION}/rtk-${ARCH_TRIPLE}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading rtk from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "rtk.tar.gz"

# Extract the tarball
echo "Extracting rtk..."
tar -xzf "rtk.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing rtk..."
mv rtk /usr/local/bin/
chmod +x /usr/local/bin/rtk

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
rtk --version

echo "Done!"
