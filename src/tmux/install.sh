#!/usr/bin/env bash

# Variables
REPO_OWNER="tmux"
REPO_NAME="tmux"
BINARY_NAME="tmux"
TMUX_VERSION="${VERSION:-"latest"}"
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

# Make sure we have required dependencies
check_packages curl ca-certificates build-essential pkg-config libevent-dev libncurses-dev bison tar

# Function to get the latest version by following the GitHub releases redirect
get_latest_version() {
    curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//'
}

# Check if a version is passed as an argument
if [ -z "$TMUX_VERSION" ] || [ "$TMUX_VERSION" == "latest" ]; then
    TMUX_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $TMUX_VERSION"
else
    echo "Installing version from environment variable: $TMUX_VERSION"
fi

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading tmux from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "tmux.tar.gz"

# Extract the tarball
echo "Extracting tmux..."
tar -xzf "tmux.tar.gz"

# Build from source
cd "tmux-${TMUX_VERSION}" || exit
echo "Configuring tmux..."
./configure --prefix=/usr/local
echo "Building tmux..."
make -j"$(nproc)"
echo "Installing tmux..."
make install

# Cleanup
cd / || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
tmux -V

echo "Done!"
