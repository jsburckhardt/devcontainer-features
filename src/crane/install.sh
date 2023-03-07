#!/usr/bin/env bash

CRANE_VERSION="${VERSION:-"latest"}"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

ARCH="$(uname -m)"
# if ARCH is not arm64, x86_64, armv6, i386, s390x exit 1
case ${ARCH} in
arm64 | x86_64 | armv6 | i386 | s390x) ;;
*)
	echo "(!) Architecture ${ARCH} unsupported"
	exit 1
	;;
esac

# check if linux/windows/macOS
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
	if [ "${requested_version}" = "latest" ]; then requested_version=$(curl -sL https://api.github.com/repos/google/go-containerregistry/releases/latest | jq -r ".tag_name"); fi
	local version_list
    version_list=$(curl -sL https://api.github.com/repos/google/go-containerregistry/releases | jq -r ".[].tag_name")
	if [ -z "${variable_name}" ] || ! echo "${version_list}" | grep "${requested_version}" >/dev/null 2>&1; then
		echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
		exit 1
	fi
	echo "${variable_name}=${requested_version}"
}

# make sure we have curl
check_packages curl tar jq ca-certificates

# make sure version is available
if [ "${CRANE_VERSION}" = "latest" ]; then CRANE_VERSION=$(curl -sL https://api.github.com/repos/google/go-containerregistry/releases/latest | jq -r ".tag_name"); fi
validate_version_exists CRANE_VERSION "${CRANE_VERSION}"

# download and install binary
CRANE_FILENAME=go-containerregistry_${OS}_${ARCH}.tar.gz
echo "Downloading ${CRANE_FILENAME}..."

url="https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/${CRANE_FILENAME}"
echo "Downloading ${url}..."
curl -sSL $url -o "${CRANE_FILENAME}"
tar -zxvf "${CRANE_FILENAME}" -C /usr/local/bin/ crane
rm "${CRANE_FILENAME}"


# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
