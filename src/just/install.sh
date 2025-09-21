#!/usr/bin/env bash

# Variables
REPO_OWNER="casey"
REPO_NAME="just"
BINARY_NAME="just"
JUST_VERSION="${VERSION:-"latest"}"

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

# Make sure we have curl and ca-certificates
check_packages curl ca-certificates

# Check if a version is passed as an argument
# If latest, use a known recent version as fallback since API access may be limited
if [ -z "$JUST_VERSION" ] || [ "$JUST_VERSION" == "latest" ]; then
    # Use a recent known version as fallback when "latest" is requested
    JUST_VERSION="1.42.4"
    echo "No version provided or 'latest' specified, using version: $JUST_VERSION"
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

# Construct download URL based on just's release pattern
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${TARGET}.tar.gz"

echo "Downloading just from: ${DOWNLOAD_URL}"

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and extract
curl -L -o "just.tar.gz" "${DOWNLOAD_URL}"
tar -xzf "just.tar.gz"

# The just release usually has the binary directly in the archive
if [ -f "just" ]; then
    echo "Installing just..."
    mv "just" /usr/local/bin/
    chmod +x /usr/local/bin/just
else
    echo "ERROR: Could not find just binary in archive"
    exit 1
fi

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
just --version

echo "Done!"