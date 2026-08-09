#!/usr/bin/env bash
KYVERNO_VERSION="${VERSION:-"latest"}"
REPO_OWNER="kyverno"
REPO_NAME="kyverno"
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

# make sure we have curl
check_packages curl tar ca-certificates

# get latest version via redirect if not specified
if [ "${KYVERNO_VERSION}" = "latest" ]; then
    KYVERNO_VERSION=$(curl -sI "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest" \
        | grep -i '^location:' | sed 's|.*/tag/||;s/\r//')
    echo "No version provided or 'latest' specified, installing the latest version: $KYVERNO_VERSION"
fi

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
