#!/usr/bin/env bash

# Variables
REPO_OWNER="Orange-OpenSource"
REPO_NAME="hurl"
BINARY_NAME="hurl"
HURL_VERSION="${VERSION:-"latest"}"
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

# Install libxml2 runtime dependency
# On newer Ubuntu (25.04+), the package is libxml2-16 and provides libxml2.so.16
# but hurl is linked against libxml2.so.2, so we need a compatibility symlink
if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
    apt-get update -y
fi
if apt-cache show libxml2 2>&1 | grep -q "^Version:"; then
    check_packages libxml2
else
    check_packages libxml2-16
    # Create compatibility symlink for binaries expecting libxml2.so.2
    LIBXML2_SO=$(find /usr/lib -name "libxml2.so.*" ! -name "*.so.*.*" | head -1)
    if [ -n "$LIBXML2_SO" ] && [ ! -e "$(dirname "$LIBXML2_SO")/libxml2.so.2" ]; then
        ln -s "$LIBXML2_SO" "$(dirname "$LIBXML2_SO")/libxml2.so.2"
        ldconfig
    fi
fi

# Function to get the latest version from GitHub API
get_latest_version() {
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$HURL_VERSION" ] || [ "$HURL_VERSION" == "latest" ]; then
    HURL_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $HURL_VERSION"
else
    echo "Installing version from environment variable: $HURL_VERSION"
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
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${HURL_VERSION}/hurl-${HURL_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading hurl from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "hurl.tar.gz"

# Extract the tarball
echo "Extracting hurl..."
tar -xzf "hurl.tar.gz"

# Find the extracted directory
EXTRACTED_DIR=$(find . -name "hurl-${HURL_VERSION}-*" -type d | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted hurl directory"
    exit 1
fi

# Move the binaries to /usr/local/bin (hurl ships hurl and hurlfmt)
echo "Installing hurl..."
mv "${EXTRACTED_DIR}/bin/hurl" /usr/local/bin/
mv "${EXTRACTED_DIR}/bin/hurlfmt" /usr/local/bin/

# Cleanup
cd / || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
hurl --version

echo "Done!"
