#!/usr/bin/env bash

NOTATION_VERSION="${VERSION:-"latest"}"

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
platform="$(uname -s)"
case ${platform} in
Linux) platform="linux" ;;
Darwin) platform="darwin" ;;
*)
	echo "(!) Platform ${platform} unsupported"
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
if [ "${NOTATION_VERSION}" = "latest" ]; then NOTATION_VERSION=$(curl -sI "https://github.com/notaryproject/notation/releases/latest" | grep -i '^location:' | sed 's|.*/tag/||;s/\r//'); fi

# download and install binary
NOTATION_FILENAME=notation_${NOTATION_VERSION:1}_${platform}_${architecture}.tar.gz
echo "Downloading ${NOTATION_FILENAME}..."
url="https://github.com/notaryproject/notation/releases/download/${NOTATION_VERSION}/${NOTATION_FILENAME}"
echo "Downloading ${url}..."
curl -sSL https://github.com/notaryproject/notation/releases/download/"${NOTATION_VERSION}"/"${NOTATION_FILENAME}" -o "${NOTATION_FILENAME}"
tar xzvf "${NOTATION_FILENAME}"
install -m 555 notation /usr/local/bin/notation
rm "${NOTATION_FILENAME}"
rm notation
rm LICENSE

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
