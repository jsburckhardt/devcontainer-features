#!/usr/bin/env bash

K3D_VERSION="${VERSION:-"latest"}"
GITHUB_API_REPO_URL="https://api.github.com/repos/k3d-io/k3d/releases"
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

# Figure out correct version of a three part version number is not passed
validate_version_exists() {
    local variable_name=$1
    local requested_version=$2
    if [ "${requested_version}" = "latest" ]; then requested_version=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name"); fi
    local version_list
    version_list=$(curl -sL ${GITHUB_API_REPO_URL} | jq -r ".[].tag_name")
    if [ -z "${variable_name}" ] || ! echo "${version_list}" | grep "${requested_version}" >/dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${requested_version}"
}

# Make sure we have curl and jq
check_packages curl jq ca-certificates

# Make sure version is available
if [ "${K3D_VERSION}" = "latest" ]; then K3D_VERSION=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name"); fi
validate_version_exists K3D_VERSION "${K3D_VERSION}"

# Download and install binary
K3D_DIST="k3d-${OS}-${ARCH}"
echo "Downloading ${K3D_DIST} version ${K3D_VERSION}..."

url="${URL_RELEASES}/download/${K3D_VERSION}/${K3D_DIST}"
echo "Downloading ${url}..."
curl -sSL "$url" -o /usr/local/bin/k3d
chmod +x /usr/local/bin/k3d

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"