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

# make sure we have curl
check_packages curl tar ca-certificates

# make sure version is available
if [ "${CRANE_VERSION}" = "latest" ]; then CRANE_VERSION=$(curl -sI "https://github.com/google/go-containerregistry/releases/latest" | grep -i '^location:' | sed 's|.*/tag/||;s/\r//'); fi

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
