#!/usr/bin/env bash

set -euo pipefail

# Variables
REPO_OWNER="rtk-ai"
REPO_NAME="rtk"
BINARY_NAME="rtk"
RTK_VERSION="${VERSION:-latest}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root. Use sudo, su, or add USER root to your Dockerfile before running this script."
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

# Make sure the release can be downloaded, resolved, and extracted.
check_packages curl jq ca-certificates tar

# Resolve the latest stable release. Fall back to GitHub release redirects if
# the API is temporarily unavailable or rate limited.
get_latest_version() {
    local version
    local effective_url

    version=$(curl -fsSL --retry 3 "${GITHUB_API_REPO_URL}/latest" 2>/dev/null | jq -er ".tag_name // empty" 2>/dev/null || true)
    if [ -n "$version" ]; then
        echo "$version"
        return 0
    fi

    echo "GitHub API lookup failed; trying the releases/latest redirect." >&2
    effective_url=$(curl -fsSL --retry 3 -o /dev/null -w "%{url_effective}" "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null || true)
    version="${effective_url##*/}"
    if [ -n "$version" ] && [ "$version" != "latest" ]; then
        echo "$version"
        return 0
    fi

    return 1
}

if [ -z "$RTK_VERSION" ] || [ "$RTK_VERSION" = "latest" ]; then
    if ! RTK_VERSION=$(get_latest_version); then
        echo "ERROR: Unable to resolve the latest RTK release." >&2
        exit 1
    fi
    echo "No version provided or latest specified, installing: $RTK_VERSION"
else
    echo "Installing version from environment variable: $RTK_VERSION"
fi

# RTK release assets are published for Linux on x86_64 and aarch64.
ARCH=$(uname -m)
case "$ARCH" in
    x86_64 | amd64)
        ARCH="x86_64"
        LIBC="musl"
        ;;
    aarch64 | arm64)
        ARCH="aarch64"
        LIBC="gnu"
        ;;
    i386 | i686 | armv7l)
        echo "ERROR: RTK does not publish Linux release assets for architecture: $ARCH" >&2
        exit 1
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

OS=$(uname -s)
case "$OS" in
    Linux)
        TARGET="${ARCH}-unknown-linux-${LIBC}"
        ;;
    *)
        echo "ERROR: Unsupported OS for this Dev Container Feature: $OS" >&2
        exit 1
        ;;
esac

ASSET_NAME="${BINARY_NAME}-${TARGET}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${RTK_VERSION}/${ASSET_NAME}"
TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
    rm -rf /var/lib/apt/lists/*
}
trap cleanup EXIT

cd "$TMP_DIR"
echo "Downloading $BINARY_NAME from $DOWNLOAD_URL"
curl -fsSL --retry 3 "$DOWNLOAD_URL" -o "$ASSET_NAME"

echo "Extracting $BINARY_NAME..."
tar -xzf "$ASSET_NAME"

if [ ! -f "$BINARY_NAME" ]; then
    echo "ERROR: Could not find $BINARY_NAME in $ASSET_NAME" >&2
    exit 1
fi

echo "Installing $BINARY_NAME..."
install -m 0755 "$BINARY_NAME" "/usr/local/bin/$BINARY_NAME"

cd /
cleanup
trap - EXIT

echo "Verifying installation..."
"$BINARY_NAME" --version

echo "Done!"
