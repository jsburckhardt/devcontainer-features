#!/usr/bin/env bash
KYVERNO_VERSION="${VERSION:-"latest"}"
GITHUB_API_REPO_URL="https://api.github.com/repos/kyverno/kyverno/releases"
URL_RELEASES="https://github.com/kyverno/kyverno/releases"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

ARCH="$(uname -m)"
# if ARCH is not arm64, x86_64, armv6, i386, s390x exit 1
case ${ARCH} in
arm64 | x86_64 | s390x) ;;
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
if [ "${KYVERNO_VERSION}" = "latest" ]; then KYVERNO_VERSION=$(curl -sL ${GITHUB_API_REPO_URL}/latest | jq -r ".tag_name"); fi
validate_version_exists KYVERNO_VERSION "${KYVERNO_VERSION}"

# download and install binary
KYVERNO_FILENAME=kyverno-cli_${KYVERNO_VERSION}_${OS}_${ARCH}.tar.gz
echo "Downloading ${KYVERNO_FILENAME}..."

url="${URL_RELEASES}/download/${KYVERNO_VERSION}/${KYVERNO_FILENAME}"
echo "Downloading ${url}..."
curl -sSL "$url" -o "${KYVERNO_FILENAME}"
tar -zxvf "${KYVERNO_FILENAME}" -C /usr/local/bin/ kyverno
rm "${KYVERNO_FILENAME}"


# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
