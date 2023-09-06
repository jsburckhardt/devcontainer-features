#!/usr/bin/env bash

AZURE_DEV_VERSION="${VERSION:-"latest"}"
GITHUB_API_REPO_URL="https://api.github.com/repos/Azure/azure-dev/releases"
URL_RELEASES="https://github.com/Azure/azure-dev/releases"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="x64" ;;
aarch64 | armv8*) architecture="arm64" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
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
	if [ "${requested_version}" = "latest" ]; then requested_version=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name"); fi
	local version_list
    version_list=$(curl -sL ${GITHUB_API_REPO_URL} | jq -r ".[].tag_name")
	if [ -z "${variable_name}" ] || ! echo "${version_list}" | grep "${requested_version}" >/dev/null 2>&1; then
		echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
		exit 1
	fi
	echo $requested_version
	echo "${variable_name}=${requested_version}"
}

# make sure we have curl
check_packages curl tar jq ca-certificates xdg-utils

# make sure version is available
if [ "${AZURE_DEV_VERSION}" = "latest" ]; then
	AZURE_DEV_VERSION=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name")
else
	AZURE_DEV_VERSION="azure-dev-cli_${AZURE_DEV_VERSION#v}"
fi

validate_version_exists AZURE_DEV_VERSION "${AZURE_DEV_VERSION}"

# remove azure-dev-cli_ prefix
AZURE_DEV_VERSION=${AZURE_DEV_VERSION#azure-dev-cli_}

curl -fsSL https://aka.ms/install-azd.sh | bash -s -- -a $architecture --version $AZURE_DEV_VERSION

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
