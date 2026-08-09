#!/usr/bin/env bash

ZARF_VERSION="${VERSION:-"latest"}"
ZARF_DOWNLOAD_INIT="${INITFILE:-false}"
REPO_OWNER="zarf-dev"
REPO_NAME="zarf"
URL_RELEASES="https://github.com/zarf-dev/zarf/releases"

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

# make sure we have curl
check_packages curl tar ca-certificates

# get latest version via redirect if not specified
if [ "${ZARF_VERSION}" = "latest" ]; then
    ZARF_VERSION=$(curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//')
    echo "No version provided or 'latest' specified, installing the latest version: $ZARF_VERSION"
fi

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
