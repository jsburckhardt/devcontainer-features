#!/bin/bash

# Variables
REPO_OWNER="astral-sh"
REPO_NAME="uv"
BINARY_NAME="uv"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# make sure we have packages
check_packages curl tar jq ca-certificates

# Function to get the latest version from GitHub API
get_latest_version() {
    LATEST_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    curl -s "$LATEST_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Check if a version is passed as an argument
if [ -z "$1" ]; then
    # No version provided, get the latest version
    VERSION=$(get_latest_version)
    echo "No version provided, installing the latest version: $VERSION"
else
    # if the version provided, starts with v, remove it
    if [[ $1 == v* ]]; then
        VERSION=${1:1}
    else
        VERSION=$1
    fi
    echo "Installing specified version: $VERSION"
fi

# Determine the OS and architecture following the naming template
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    i686)
        ARCH="i686"
        ;;
    armv7l)
        ARCH="armv7"
        ;;
    aarch64)
        ARCH="aarch64"
        ;;
    powerpc64)
        ARCH="powerpc64"
        ;;
    powerpc64le)
        ARCH="powerpc64le"
        ;;
    s390x)
        ARCH="s390x"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Construct the download URL to match the naming template
if [[ "$OS" == "darwin" ]]; then
    OS="apple-darwin"
elif [[ "$OS" == "linux" ]]; then
    OS="unknown-linux-gnu"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/${REPO_NAME}-${ARCH}-${OS}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

# Download the binary tarball
echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# Extract the tarball
echo "Extracting the tarball"
tar -xzf "${REPO_NAME}-${ARCH}-${OS}.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing $BINARY_NAME"
mv ${REPO_NAME}-${ARCH}-${OS}/* /usr/local/bin/


# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Verify installation
echo "Verifying installation"
$BINARY_NAME --version
