#!/usr/bin/env bash

set -e

# Variables
REPO_OWNER="redhat-et"
REPO_NAME="ripwire"
BINARY_NAME="ripwire"
VERSION="${VERSION:-latest}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

# Root check
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

# Ensure required download and extraction tools are installed
check_packages curl jq ca-certificates tar

# Resolve the latest release tag through the GitHub API, with the releases redirect as a fallback
get_latest_version() {
    local latest_version
    local latest_url

    if latest_version="$(curl -fsSL "${GITHUB_API_REPO_URL}/latest" | jq -er '.tag_name // empty' 2>/dev/null)" && [ -n "$latest_version" ]; then
        echo "$latest_version"
        return 0
    fi

    echo "GitHub API version lookup failed; trying the releases/latest redirect." >&2
    if latest_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest")"; then
        latest_version="${latest_url##*/}"
        if [ -n "$latest_version" ] && [ "$latest_version" != "latest" ]; then
            echo "$latest_version"
            return 0
        fi
    fi

    return 1
}

if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
    if ! VERSION="$(get_latest_version)"; then
        echo "Failed to resolve the latest ripwire release version." >&2
        exit 1
    fi
    echo "No version provided or 'latest' specified, installing the latest version: $VERSION"
else
    echo "Installing version from environment variable: $VERSION"
fi

case "$VERSION" in
    v*) TAG_VERSION="$VERSION" ;;
    *) TAG_VERSION="v${VERSION}" ;;
esac
RELEASE_VERSION="${TAG_VERSION#v}"

# Map the operating system to ripwire release asset names
OS_RAW="$(uname -s)"
case "$OS_RAW" in
    Linux) OS="linux" ;;
    Darwin) OS="macos" ;;
    *) echo "Unsupported OS: $OS_RAW" >&2; exit 1 ;;
esac

# Upstream publishes x64 and arm64 Linux archives; current macOS releases are arm64-only
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
    x86_64|amd64) ARCH="x64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    i386|i686|armv7l)
        echo "Unsupported architecture: $ARCH_RAW (ripwire does not publish a release asset for it)" >&2
        exit 1
        ;;
    *) echo "Unsupported architecture: $ARCH_RAW" >&2; exit 1 ;;
esac

if [ "$OS" = "macos" ] && [ "$ARCH" != "arm64" ]; then
    echo "Unsupported architecture on macOS: $ARCH_RAW" >&2
    exit 1
fi

ASSET_NAME="ripwire-${RELEASE_VERSION}-${OS}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TAG_VERSION}/${ASSET_NAME}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"
echo "Downloading ripwire from $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" -o "$ASSET_NAME"

echo "Extracting ripwire..."
tar -xzf "$ASSET_NAME"

EXTRACTED_BINARY="$(find . -type f -name "$BINARY_NAME" -perm /111 | head -1)"
if [ -z "$EXTRACTED_BINARY" ]; then
    echo "ERROR: Could not find the ripwire binary in $ASSET_NAME" >&2
    exit 1
fi

install -m 0755 "$EXTRACTED_BINARY" "/usr/local/bin/$BINARY_NAME"

cd /
rm -rf "$TMP_DIR"
trap - EXIT
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
"$BINARY_NAME" --version

echo "Done!"
