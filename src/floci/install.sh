#!/usr/bin/env bash

set -euo pipefail

# Variables
REPO_OWNER="floci-io"
REPO_NAME="floci-cli"
BINARY_NAME="floci"
VERSION="${VERSION:-latest}"

# Root check
if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists -mindepth 1 -maxdepth 1 | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Ensure required packages are installed
check_packages curl jq ca-certificates

# Query the latest GitHub release, falling back to the releases list if needed.
get_latest_version() {
    local response version

    response="$(curl -fsSL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" || true)"
    version="$(printf '%s' "$response" | jq -r '.tag_name // empty' 2>/dev/null || true)"

    if [ -z "$version" ]; then
        response="$(curl -fsSL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases?per_page=1" || true)"
        version="$(printf '%s' "$response" | jq -r '.[0].tag_name // empty' 2>/dev/null || true)"
    fi

    printf '%s\n' "$version"
}

# Resolve version
if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
    VERSION="$(get_latest_version)"
    if [ -z "$VERSION" ]; then
        echo "Failed to resolve the latest floci version from the GitHub API." >&2
        exit 1
    fi
    echo "No version provided or latest specified, installing the latest version: $VERSION"
else
    echo "Installing floci version: $VERSION"
fi

# Upstream publishes floci-{linux,darwin}-{amd64,arm64} binaries.
OS_RAW="$(uname -s)"
case "$OS_RAW" in
    Linux) OS="linux" ;;
    Darwin) OS="darwin" ;;
    *) echo "Unsupported OS: $OS_RAW" >&2; exit 1 ;;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH_RAW" >&2; exit 1 ;;
esac

ASSET_NAME="${BINARY_NAME}-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/${ASSET_NAME}"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
    rm -rf /var/lib/apt/lists/*
}
trap cleanup EXIT

cd "$TMP_DIR"
echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -fsSL -o "$BINARY_NAME" "$DOWNLOAD_URL"
chmod +x "$BINARY_NAME"
mv "$BINARY_NAME" /usr/local/bin/

# Verify installation
echo "Verifying installation"
"$BINARY_NAME" --version
