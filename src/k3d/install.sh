#!/usr/bin/env bash

K3D_VERSION="${VERSION:-"latest"}"
REPO_OWNER="k3d-io"
REPO_NAME="k3d"
URL_RELEASES="https://github.com/k3d-io/k3d/releases"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

ARCH="$(uname -m)"
# Map the architecture to the format used by k3d
case ${ARCH} in
x86_64) ARCH="amd64" ;;
i686) ARCH="386" ;;
armv7*) ARCH="arm" ;;
aarch64) ARCH="arm64" ;;
*)
    echo "(!) Architecture ${ARCH} unsupported"
    exit 1
    ;;
esac

# Check if linux/windows/macOS
OS="$(uname -s)"
case ${OS} in
Linux) OS="linux" ;;
Darwin) OS="darwin" ;;
*)
    echo "(!) Platform ${OS} unsupported"
    exit 1
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

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

# get latest version via redirect if not specified
if [ "${K3D_VERSION}" = "latest" ]; then
    K3D_VERSION=$(curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//')
    echo "No version provided or 'latest' specified, installing the latest version: $K3D_VERSION"
fi

# Download and install binary
K3D_DIST="k3d-${OS}-${ARCH}"
echo "Downloading ${K3D_DIST} version ${K3D_VERSION}..."

url="${URL_RELEASES}/download/${K3D_VERSION}/${K3D_DIST}"
echo "Downloading ${url}..."
curl -sSL --insecure "$url" -o /usr/local/bin/k3d
chmod +x /usr/local/bin/k3d

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"