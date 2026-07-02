#!/usr/bin/env bash

# Variables
REPO_OWNER="junegunn"
REPO_NAME="fzf"
BINARY_NAME="fzf"
FZF_VERSION="${VERSION:-"latest"}"
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
if [ -z "$FZF_VERSION" ] || [ "$FZF_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    FZF_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $FZF_VERSION"
else
    echo "Installing version from environment variable: $FZF_VERSION"
fi

# Strip the leading 'v' for the download URL filename
FZF_VERSION_NUMBER="${FZF_VERSION#v}"

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
    armv7l)
        ARCH="armv7"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Construct the download URL
# Pattern: fzf-{VERSION_NUMBER}-{os}_{arch}.tar.gz
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION_NUMBER}-${OS}_${ARCH}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading fzf from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "fzf.tar.gz"

# Extract the tarball
echo "Extracting fzf..."
tar -xzf "fzf.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing fzf..."
mv fzf /usr/local/bin/
chmod +x /usr/local/bin/fzf

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
fzf --version

echo "Done!"
