#!/usr/bin/env bash

GITLEAKS_VERSION="${VERSION:-"latest"}"
REPO_OWNER="gitleaks"
REPO_NAME="gitleaks"
URL_RELEASES="https://github.com/gitleaks/gitleaks/releases"

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

# make sure we have curl
check_packages curl tar ca-certificates

# get latest version via redirect if not specified
if [ "${GITLEAKS_VERSION}" = "latest" ]; then
    GITLEAKS_VERSION=$(curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//')
    echo "No version provided or 'latest' specified, installing the latest version: $GITLEAKS_VERSION"
fi

# download and install binary
GITLEAKS_FILENAME=gitleaks_${GITLEAKS_VERSION#v}_${OS}_${architecture}.tar.gz
echo "Downloading ${GITLEAKS_FILENAME}..."

url="${URL_RELEASES}/download/${GITLEAKS_VERSION}/${GITLEAKS_FILENAME}"
echo "Downloading ${url}..."
curl -sSL $url -o "${GITLEAKS_FILENAME}"
tar -zxvf "${GITLEAKS_FILENAME}" -C /usr/local/bin/ gitleaks
rm "${GITLEAKS_FILENAME}"


# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
