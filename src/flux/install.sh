#!/usr/bin/env bash

FLUX2_VERSION="${VERSION:-"latest"}"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="amd64" ;;
aarch64 | armv8*) architecture="arm64" ;;
aarch32 | armv7* | armvhf*) architecture="arm" ;;
i?86) architecture="386" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
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
if [ "${FLUX2_VERSION}" = "latest" ]; then FLUX2_VERSION=$(curl -sI "https://github.com/fluxcd/flux2/releases/latest" | grep -i '^location:' | sed 's|.*/tag/||;s/\r//'); fi

# download and install binary
FLUX2_FILENAME=flux_${FLUX2_VERSION:1}_linux_${architecture}.tar.gz
echo "Downloading ${FLUX2_FILENAME}..."
url="https://github.com/fluxcd/flux2/releases/download/${FLUX2_VERSION}/${FLUX2_FILENAME}"
echo "Downloading ${url}..."
curl -sSL https://github.com/fluxcd/flux2/releases/download/"${FLUX2_VERSION}"/"${FLUX2_FILENAME}" -o "${FLUX2_FILENAME}"
tar xzvf "${FLUX2_FILENAME}"
install -m 555 flux /usr/local/bin/flux
rm "${FLUX2_FILENAME}"
rm flux

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
