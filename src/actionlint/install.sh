#!/usr/bin/env bash

# Variables
REPO_OWNER="rhysd"
REPO_NAME="actionlint"
BINARY_NAME="actionlint"
ACTIONLINT_VERSION="${VERSION:-"latest"}"
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
if [ -z "$ACTIONLINT_VERSION" ] || [ "$ACTIONLINT_VERSION" == "latest" ]; then
    # No version provided, get the latest version
    ACTIONLINT_VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: $ACTIONLINT_VERSION"
else
    echo "Installing version from environment variable: $ACTIONLINT_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    i686)
        ARCH="386"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="armv6"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Strip the leading 'v' from the version for the download URL
VERSION_NUMBER="${ACTIONLINT_VERSION#v}"

# Construct the download URL
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${ACTIONLINT_VERSION}/actionlint_${VERSION_NUMBER}_${OS}_${ARCH}.tar.gz"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading actionlint from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" -o "actionlint.tar.gz"

# Extract the tarball
echo "Extracting actionlint..."
tar -xzf "actionlint.tar.gz"

# Move the binary to /usr/local/bin
echo "Installing actionlint..."
mv actionlint /usr/local/bin/

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Clean up
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
actionlint --version

echo "Done!"
