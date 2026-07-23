#!/usr/bin/env bash

# Variables
REPO_OWNER="iOfficeAI"
REPO_NAME="OfficeCLI"
BINARY_NAME="officecli"

set -e

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

# make sure we have packages
# libicu-dev pulls in the libicuXX runtime that the .NET AOT binary needs
check_packages curl jq ca-certificates libicu-dev

# Function to get the latest version from GitHub API
get_latest_version() {
    LATEST_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    VERSION_TAG=$(curl -sL "${LATEST_URL}" | jq -r '.tag_name // ""')
    if [ -z "${VERSION_TAG}" ] || [ "${VERSION_TAG}" = "null" ]; then
        # Fallback: pick the most recent release (may include pre-releases)
        VERSION_TAG=$(curl -sL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" | jq -r '.[0].tag_name // ""')
    fi
    if [ -z "${VERSION_TAG}" ] || [ "${VERSION_TAG}" = "null" ]; then
        echo "Error: Could not determine latest ${BINARY_NAME} version from GitHub API." >&2
        exit 1
    fi
    echo "${VERSION_TAG}"
}

# Resolve version
VERSION="${VERSION:-latest}"
if [ -z "${VERSION}" ] || [ "${VERSION}" = "latest" ]; then
    VERSION=$(get_latest_version)
    echo "No version provided or 'latest' specified, installing the latest version: ${VERSION}"
else
    echo "Installing officecli version: ${VERSION}"
fi

# Determine OS
OS_RAW="$(uname -s)"
case "${OS_RAW}" in
    Linux)  OS="linux"  ;;
    Darwin) OS="mac"    ;;
    *)
        echo "(!) Platform ${OS_RAW} unsupported"
        exit 1
        ;;
esac

# Determine architecture — officecli release assets use x64/arm64 naming
ARCH_RAW="$(uname -m)"
case "${ARCH_RAW}" in
    x86_64 | amd64)    ARCH="x64"   ;;
    aarch64 | arm64)   ARCH="arm64" ;;
    *)
        echo "(!) Architecture ${ARCH_RAW} unsupported by officecli releases"
        exit 1
        ;;
esac

ASSET_NAME="${BINARY_NAME}-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/${ASSET_NAME}"

# Create a temporary directory for the download
TMP_DIR="$(mktemp -d)"
cd "${TMP_DIR}"

echo "Downloading ${BINARY_NAME} from ${DOWNLOAD_URL}"
curl -fsSL -o "${BINARY_NAME}" "${DOWNLOAD_URL}"

chmod +x "${BINARY_NAME}"
mv "${BINARY_NAME}" "/usr/local/bin/${BINARY_NAME}"

# Cleanup
cd /
rm -rf "${TMP_DIR}"
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation"
"${BINARY_NAME}" --version

echo "Done!"
