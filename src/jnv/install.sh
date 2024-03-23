#!/usr/bin/env bash

JNV_VERSION="${VERSION:-"latest"}"
JNV_API_URL="https://api.github.com/repos/ynqa/jnv/releases"
JNV_RELEASES_URL="https://github.com/ynqa/jnv/releases"

set -e -x

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="x86_64" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
	exit 1
	;;
esac

# check if linux/windows/macOS
OS="$(uname -s)"
case ${OS} in
Linux) OS="unknown-linux-gnu" ;;
Darwin) OS="apple-darwin" ;;
*)
	echo "(!) Platform ${OS} unsupported"
	exit 1
	;;
esac

# Checks if packages are installed and installs them if not
check_packages() {
	if ! dpkg -s "$@" >/dev/null 2>&1; then
		if [ "$(find /var/lib/apt/lists/* -print0 | wc -l)" = "0" ]; then
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
	if [ "${requested_version}" = "latest" ]; then requested_version=$(curl -sL ${JNV_API_URL}/latest | jq -r ".tag_name"); fi
	local version_list
	version_list=$(curl -sL ${JNV_API_URL} | jq -r ".[].tag_name")
	if [ -z "${variable_name}" ] || ! echo "${version_list}" | grep "${requested_version}" >/dev/null 2>&1; then
		echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
		exit 1
	fi
	echo "${variable_name}=${requested_version}"
}

# make sure we have curl
check_packages curl tar jq ca-certificates xz-utils

# make sure version is available
if [ "${JNV_VERSION}" = "latest" ]; then JNV_VERSION=$(curl -sL ${JNV_API_URL}/latest | jq -r ".tag_name"); fi
validate_version_exists JNV_VERSION "${JNV_VERSION}"

# download and install binary
JNV_FILENAME="jnv-${architecture}-${OS}.tar.xz"

url="${JNV_RELEASES_URL}/download/${JNV_VERSION}/${JNV_FILENAME}"
echo "Downloading ${url}..."
curl -sSL "$url" -o "${JNV_FILENAME}"
if [ $? -ne 0 ]; then
	echo "Failed to download ${url}"
	exit 1
fi

# Custom steps for jnv
# unxz jnv-x86_64-unknown-linux-gnu.tar.xz
# tar xf jnv-x86_64-unknown-linux-gnu.tar
# mv jnv-x86_64-unknown-linux-gnu/jnv /usr/local/bin/jnv
# rm -rf jnv-x86_64-unknown-linux-gnu
# rm jnv-x86_64-unknown-linux-gnu.tar

unxz "${JNV_FILENAME}"
tar xf "${JNV_FILENAME%.xz}"
install -m 555 "${JNV_FILENAME%.tar.xz}/jnv" /usr/local/bin/jnv

if [ $? -ne 0 ]; then
	echo "Failed to extract ${JNV_FILENAME}"
	exit 1
fi

rm -rf "${JNV_FILENAME%.tar.xz}"
rm "${JNV_FILENAME%.xz}"

# Clean up
# rm -rf /var/lib/apt/lists/*

echo "Done!"
