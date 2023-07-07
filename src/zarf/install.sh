#!/usr/bin/env bash

ZARF_VERSION="${VERSION:-"latest"}"
ZARF_DOWNLOAD_INIT="${INITFILE:-false}"
GITHUB_API_REPO_URL="https://api.github.com/repos/defenseunicorns/zarf/releases"
URL_RELEASES="https://github.com/defenseunicorns/zarf/releases"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="amd64" ;;
aarch64 | armv8*) architecture="arm64" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
	exit 1
	;;
esac

# check if linux/windows/macOS
OS="$(uname -s)"
case ${OS} in
Linux) OS="Linux" ;;
Darwin) OS="Darwin" ;;
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

# make sure we have curl
check_packages curl tar jq ca-certificates

# make sure version is available
if [ "${ZARF_VERSION}" = "latest" ]; then ZARF_VERSION=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name"); fi
validate_version_exists ZARF_VERSION "${ZARF_VERSION}"

# download and install binary
ZARF_FILENAME=zarf_${ZARF_VERSION}_${OS}_${architecture}
INIT_FILENAME=zarf-init-${architecture}-${ZARF_VERSION}.tar.zst
echo "Downloading ${ZARF_FILENAME}..."

url="${URL_RELEASES}/download/${ZARF_VERSION}/${ZARF_FILENAME}"
init_url="${URL_RELEASES}/download/${ZARF_VERSION}/${INIT_FILENAME}"
echo "Downloading ${url}..."
curl -sSL $url -o "zarf"
install -m 555 zarf /usr/local/bin/zarf
rm zarf

# if DOWNLOAD-INIT env var is true, then download init_url
if [ "${ZARF_DOWNLOAD_INIT}" = true ]; then
	echo "Downloading ${init_url} into /tmp ..."
	# rm /tmp/$INIT_FILENAME if exists
	rm -f /tmp/$INIT_FILENAME
	curl -sSL $init_url -o "/tmp/$INIT_FILENAME"
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
