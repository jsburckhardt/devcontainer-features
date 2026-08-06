#!/usr/bin/env bash

set -e

# Variables
REPO_OWNER="git-ai-project"
REPO_NAME="git-ai"
BINARY_NAME="git-ai"

# Root check
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

# Ensure required packages are installed
check_packages curl ca-certificates jq

# Function to get the latest version from GitHub API
get_latest_version() {
    LATEST_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    curl -s "$LATEST_URL" | jq -r ".tag_name"
}

# Resolve version
if [ -z "${VERSION:-}" ] || [ "${VERSION}" = "latest" ]; then
    VERSION="$(get_latest_version)"
    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        echo "Failed to resolve latest version from GitHub API." >&2
        exit 1
    fi
    echo "No version provided or 'latest' specified, installing the latest version: $VERSION"
else
    echo "Installing version from environment variable: $VERSION"
fi

# Normalize version tag: upstream release tags are prefixed with "v" (e.g. v1.6.21).
# If the user supplied a bare semver like "1.6.21", prepend "v".
case "$VERSION" in
    v*) ;;
    *) VERSION="v${VERSION}" ;;
esac

# Determine OS
OS_RAW="$(uname -s)"
case "$OS_RAW" in
    Linux)  OS="linux" ;;
    Darwin) OS="macos" ;;
    *) echo "Unsupported OS: $OS_RAW" >&2; exit 1 ;;
esac

# Determine architecture. Upstream publishes raw binaries named:
#   git-ai-linux-x64, git-ai-linux-arm64, git-ai-macos-x64, git-ai-macos-arm64
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
    x86_64|amd64)  ARCH="x64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH_RAW" >&2; exit 1 ;;
esac

ASSET_NAME="${BINARY_NAME}-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/${ASSET_NAME}"

# Download the raw binary directly (no tarball is published by upstream)
TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"

echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -fsSL -o "$BINARY_NAME" "$DOWNLOAD_URL"

chmod +x "$BINARY_NAME"
mv "$BINARY_NAME" /usr/local/bin/

# Cleanup
cd /
rm -rf "$TMP_DIR"
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation"
"$BINARY_NAME" --version

echo "Done!"
