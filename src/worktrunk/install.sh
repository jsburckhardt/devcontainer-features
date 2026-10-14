#!/usr/bin/env bash

set -euo pipefail

# Variables
REPO_OWNER="max-sixty"
REPO_NAME="worktrunk"
BINARY_NAME="wt"
WORKTRUNK_VERSION="${VERSION:-latest}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ -z "$(find /var/lib/apt/lists -mindepth 1 -print -quit 2>/dev/null)" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Make sure release metadata can be queried and .tar.xz assets can be extracted.
check_packages curl jq ca-certificates tar xz-utils

# Query the GitHub API, falling back to GitHub's latest-release redirect if needed.
get_latest_version() {
    local version
    local latest_url

    version="$(curl -fsSL "${GITHUB_API_REPO_URL}/latest" 2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null || true)"
    if [ -n "${version}" ]; then
        printf '%s\n' "${version}"
        return 0
    fi

    echo "GitHub API lookup failed; falling back to the latest-release redirect." >&2
    latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null || true)"
    version="${latest_url##*/}"
    if [ -z "${version}" ] || [ "${version}" = "latest" ]; then
        echo "Unable to determine the latest Worktrunk version." >&2
        return 1
    fi
    printf '%s\n' "${version}"
}

if [ -z "${WORKTRUNK_VERSION}" ] || [ "${WORKTRUNK_VERSION}" = "latest" ]; then
    WORKTRUNK_VERSION="$(get_latest_version)"
    echo "No version provided or 'latest' specified, installing the latest version: ${WORKTRUNK_VERSION}"
else
    echo "Installing Worktrunk version: ${WORKTRUNK_VERSION}"
fi

case "$(uname -m)" in
    x86_64 | amd64)
        ARCH="x86_64"
        ;;
    aarch64 | arm64)
        ARCH="aarch64"
        ;;
    i386 | i686)
        ARCH="i686"
        echo "Unsupported architecture: ${ARCH} (upstream does not publish i686 release assets)" >&2
        exit 1
        ;;
    armv7l)
        ARCH="armv7"
        echo "Unsupported architecture: ${ARCH} (upstream does not publish armv7 release assets)" >&2
        exit 1
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
    linux)
        TARGET="unknown-linux-musl"
        ;;
    darwin)
        TARGET="apple-darwin"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac

ASSET_NAME="worktrunk-${ARCH}-${TARGET}.tar.xz"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${WORKTRUNK_VERSION}/${ASSET_NAME}"
TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "${TMP_DIR}"
    rm -rf /var/lib/apt/lists/*
}
trap cleanup EXIT

echo "Downloading Worktrunk from ${DOWNLOAD_URL}"
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ASSET_NAME}"

echo "Extracting Worktrunk..."
tar -xJf "${TMP_DIR}/${ASSET_NAME}" -C "${TMP_DIR}"
EXTRACTED_DIR="${TMP_DIR}/worktrunk-${ARCH}-${TARGET}"
if [ ! -x "${EXTRACTED_DIR}/${BINARY_NAME}" ]; then
    echo "Could not find ${BINARY_NAME} in ${ASSET_NAME}." >&2
    exit 1
fi

install -m 0755 "${EXTRACTED_DIR}/${BINARY_NAME}" "/usr/local/bin/${BINARY_NAME}"

echo "Verifying installation..."
"${BINARY_NAME}" --version

echo "Done!"
