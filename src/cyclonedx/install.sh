#!/usr/bin/env bash

CYCLONEDX_VERSION="${VERSION:-"latest"}"
REPO_OWNER="CycloneDX"
REPO_NAME="cyclonedx-cli"
URL_RELEASES="https://github.com/CycloneDX/cyclonedx-cli/releases"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

ARCH="$(uname -m)"
# if ARCH is not arm64, x86_64, armv6, i386, s390x exit 1
case ${ARCH} in
arm64) ARCH="arm64" ;;
x86_64) ARCH="x64" ;;
*)
	echo "(!) Architecture ${ARCH} unsupported"
	exit 1
	;;
esac

# check if linux/windows/macOS
OS="$(uname -s)"
case ${OS} in
Linux) OS="linux" ;;
Darwin) OS="osx" ;;
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
check_packages curl tar ca-certificates libicu-dev

# get latest version via redirect if not specified
if [ "${CYCLONEDX_VERSION}" = "latest" ]; then
    CYCLONEDX_VERSION=$(curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//')
    echo "No version provided or 'latest' specified, installing the latest version: $CYCLONEDX_VERSION"
fi

# download and install binary
CYCLONEDX_FILENAME=cyclonedx-${OS}-${ARCH}
echo "Downloading ${CYCLONEDX_FILENAME}..."

url="${URL_RELEASES}/download/${CYCLONEDX_VERSION}/${CYCLONEDX_FILENAME}"
echo "Downloading ${url}..."
curl -sSL $url -o "${CYCLONEDX_FILENAME}"
chmod +x "${CYCLONEDX_FILENAME}"
mv "${CYCLONEDX_FILENAME}" /usr/local/bin/cyclonedx


# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
