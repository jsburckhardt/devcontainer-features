#!/usr/bin/env bash

# Variables
REPO_OWNER="jesseduffield"
REPO_NAME="lazygit"
BINARY_NAME="lazygit"
LAZYGIT_VERSION="${VERSION:-"latest"}"
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

# Make sure we have curl
check_packages curl ca-certificates

# Function to get the latest version by following the GitHub releases redirect
get_latest_version() {
    curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//'
}

# Check if a version is passed as an argument
if [ -z "$LAZYGIT_VERSION" ] || [ "$LAZYGIT_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    LAZYGIT_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $LAZYGIT_VERSION"
else
    echo "Installing version from environment variable: $LAZYGIT_VERSION"
fi

# Strip the leading 'v' for the download URL (assets use version without 'v' prefix)
VERSION_NO_V="${LAZYGIT_VERSION#v}"

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="armv6"
        ;;
    i686)
        ARCH="32-bit"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        OS="Linux"
        ;;
    darwin)
        OS="Darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct the download URL
# Pattern: lazygit_{VERSION_NO_V}_{OS}_{ARCH}.tar.gz
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LAZYGIT_VERSION}/lazygit_${VERSION_NO_V}_${OS}_${ARCH}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading lazygit from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "lazygit.tar.gz"

# Extract the tarball
echo "Extracting lazygit..."
tar -xzf "lazygit.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing lazygit..."
mv lazygit /usr/local/bin/
chmod +x /usr/local/bin/lazygit

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
lazygit --version

echo "Done!"
