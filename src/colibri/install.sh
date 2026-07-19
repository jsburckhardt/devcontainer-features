#!/usr/bin/env bash

# Variables
REPO_OWNER="JustVugg"
REPO_NAME="colibri"
BINARY_NAME="colibri"
COLIBRI_VERSION="${VERSION:-"latest"}"
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

# Make sure we have the required tools and runtime libraries.
# colibri is a native C binary that links against libgomp at runtime.
check_packages curl jq ca-certificates tar libgomp1

# Function to get the latest version from GitHub API
get_latest_version() {
    curl -s "${GITHUB_API_REPO_URL}/latest" | jq -r ".tag_name"
}

# Check if a version is passed as an argument
if [ -z "$COLIBRI_VERSION" ] || [ "$COLIBRI_VERSION" = "latest" ]; then
    COLIBRI_VERSION=$(get_latest_version)
    if [ -z "$COLIBRI_VERSION" ] || [ "$COLIBRI_VERSION" = "null" ]; then
        echo "ERROR: Could not resolve latest colibri version from GitHub API"
        exit 1
    fi
    echo "No version provided or 'latest' specified, installing the latest version: $COLIBRI_VERSION"
else
    echo "Installing version from environment variable: $COLIBRI_VERSION"
fi

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
    linux)
        OS_NAME="linux"
        ;;
    darwin)
        OS_NAME="macos"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

case "$ARCH" in
    x86_64|amd64)
        ARCH_NAME="x86_64"
        ;;
    aarch64|arm64)
        # Upstream currently publishes macos-arm64 only; no linux-aarch64 asset exists.
        ARCH_NAME="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Upstream release assets follow: colibri-<version>-<os>-<arch>.tar.gz
ASSET_NAME="colibri-${COLIBRI_VERSION}-${OS_NAME}-${ARCH_NAME}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${COLIBRI_VERSION}/${ASSET_NAME}"

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

echo "Downloading colibri from $DOWNLOAD_URL"
if ! curl -fsSL "$DOWNLOAD_URL" -o "colibri.tar.gz"; then
    echo "ERROR: Failed to download colibri release asset $ASSET_NAME"
    echo "This platform (${OS_NAME}-${ARCH_NAME}) may not be supported by the upstream release."
    exit 1
fi

# Extract the tarball
echo "Extracting colibri..."
tar -xzf "colibri.tar.gz"

# Locate the extracted binary (upstream ships a single file named like the asset stem)
BIN_FILE=$(find . -maxdepth 2 -type f -name "colibri-${COLIBRI_VERSION}-${OS_NAME}-${ARCH_NAME}" | head -1)
if [ -z "$BIN_FILE" ]; then
    # Fallback: any executable-looking file
    BIN_FILE=$(find . -maxdepth 2 -type f ! -name "*.tar.gz" | head -1)
fi
if [ -z "$BIN_FILE" ]; then
    echo "ERROR: Could not find colibri binary in extracted archive"
    exit 1
fi

# Install the binary
echo "Installing colibri to /usr/local/bin/${BINARY_NAME}..."
install -m 0755 "$BIN_FILE" "/usr/local/bin/${BINARY_NAME}"

# Persist the installed version for later verification (the binary itself has no --version flag).
mkdir -p /usr/local/share/colibri
echo "$COLIBRI_VERSION" > /usr/local/share/colibri/VERSION
chmod 0644 /usr/local/share/colibri/VERSION

# Cleanup
cd - >/dev/null || exit
rm -rf "$TMP_DIR"
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
command -v "${BINARY_NAME}" >/dev/null || { echo "colibri not found on PATH"; exit 1; }
echo "colibri installed: $(cat /usr/local/share/colibri/VERSION)"

echo "Done!"
