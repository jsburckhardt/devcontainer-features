#!/usr/bin/env bash

# Variables
REPO_OWNER="sst"
REPO_NAME="opencode"
OPENCODE_VERSION="${VERSION:-"latest"}"

set -euo pipefail

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

# Make sure we have curl, ca-certificates, and unzip
check_packages curl ca-certificates unzip jq

echo "Installing OpenCode version: $OPENCODE_VERSION"

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH_SUFFIX="x64"
        ;;
    aarch64 | arm64)
        ARCH_SUFFIX="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        echo "Supported architectures: x86_64, aarch64/arm64"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        PLATFORM="linux"
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS"
        echo "Supported OS: Linux"
        exit 1
        ;;
esac

# Function to resolve the latest version using GitHub API
resolve_latest_version() {
    echo "Resolving latest version using GitHub API..." >&2
    local api_response
    api_response=$(curl -s --max-time 10 "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null || echo "")

    if [ -n "$api_response" ] && echo "$api_response" | jq -e '.tag_name' >/dev/null 2>&1; then
        local version_tag
        version_tag=$(echo "$api_response" | jq -r '.tag_name')
        # Remove 'v' prefix if present
        echo "${version_tag#v}"
        return 0
    else
        echo "GitHub API failed, falling back to HTML parsing..." >&2
        return 1
    fi
}

# Function to resolve latest version by parsing HTML (fallback)
resolve_latest_version_fallback() {
    echo "Attempting to resolve latest version from releases page HTML..." >&2
    local releases_page
    releases_page=$(curl -s --max-time 10 "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null || echo "")

    if [ -n "$releases_page" ]; then
        # Look for version tag in the HTML
        local version_tag
        version_tag=$(echo "$releases_page" | grep -oE 'releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/.*releases\/tag\/v\?\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/')

        if [ -n "$version_tag" ] && [[ "$version_tag" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$version_tag"
            return 0
        fi
    fi

    echo "Failed to resolve version from HTML, using known fallback version..." >&2
    echo "0.10.4"  # Known recent version as last resort
    return 1
}

# Resolve version
if [ "$OPENCODE_VERSION" = "latest" ]; then
    if ! RESOLVED_VERSION=$(resolve_latest_version); then
        RESOLVED_VERSION=$(resolve_latest_version_fallback)
    fi
    echo "Resolved latest version to: $RESOLVED_VERSION"
    OPENCODE_VERSION="$RESOLVED_VERSION"
else
    echo "Using specified version: $OPENCODE_VERSION"
    # Remove 'v' prefix if present in user input
    OPENCODE_VERSION="${OPENCODE_VERSION#v}"
fi

# Construct download URL based on opencode's release pattern
# Asset name format: opencode-{platform}-{arch}.zip
ASSET_NAME="opencode-${PLATFORM}-${ARCH_SUFFIX}.zip"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${OPENCODE_VERSION}/${ASSET_NAME}"

echo "Downloading OpenCode from: ${DOWNLOAD_URL}"

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

# Download with retries and proper error handling
for attempt in 1 2 3; do
    if curl -fL --retry 3 --retry-delay 2 -o "${ASSET_NAME}" "${DOWNLOAD_URL}"; then
        echo "Download successful on attempt $attempt"
        break
    else
        echo "Download attempt $attempt failed"
        if [ $attempt -eq 3 ]; then
            echo "ERROR: Failed to download after 3 attempts"
            exit 1
        fi
        sleep 2
    fi
done

# Verify the download
if [ ! -f "${ASSET_NAME}" ] || [ ! -s "${ASSET_NAME}" ]; then
    echo "ERROR: Downloaded file is missing or empty"
    exit 1
fi

echo "Extracting OpenCode..."
unzip -q "${ASSET_NAME}"

# Find the binary in the extracted contents
# The archive should contain the opencode binary
if [ -f "opencode" ]; then
    echo "Installing opencode..."
    mv "opencode" /usr/local/bin/
    chmod +x /usr/local/bin/opencode
elif [ -f "bin/opencode" ]; then
    echo "Installing opencode from bin directory..."
    mv "bin/opencode" /usr/local/bin/
    chmod +x /usr/local/bin/opencode
else
    echo "ERROR: Could not find opencode binary in archive"
    echo "Archive contents:"
    ls -la
    exit 1
fi

# Clean up
cd - >/dev/null
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
if opencode --version >/dev/null 2>&1; then
    opencode --version
    echo "OpenCode installation completed successfully!"
else
    echo "Warning: OpenCode installed but version check failed. This might be expected behavior."
    echo "OpenCode installation completed!"
fi

echo "Done!"
