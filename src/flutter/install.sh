#!/usr/bin/env bash

# Variables
FLUTTER_VERSION="${VERSION:-"latest"}"
FLUTTER_INSTALL_DIR="/opt/flutter"
FLUTTER_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

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

# Make sure we have required packages
# curl, xz-utils, git, unzip, libglu1-mesa, file are required for Flutter
check_packages curl ca-certificates xz-utils git unzip libglu1-mesa file

echo "Installing Flutter version: $FLUTTER_VERSION"

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH_SUFFIX="x64"
        ;;
    aarch64 | arm64)
        ARCH_SUFFIX="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        echo "Supported architectures: x86_64, aarch64/arm64"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        PLATFORM="linux"
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS"
        echo "Supported OS: Linux"
        exit 1
        ;;
esac

# Construct download URL for Flutter SDK precompiled binaries
# Flutter distributes precompiled binaries via Google Cloud Storage
# URL patterns we'll try (in order of preference):
# 1. flutter_linux-{version}-{arch}-stable.tar.xz (versioned with arch)
# 2. flutter_linux-{arch}-stable.tar.xz (latest with arch)
# 3. flutter_linux_v{version}-stable.tar.xz (versioned with 'v' prefix)
# 4. flutter_linux-stable.tar.xz (latest without arch, usually x64)

declare -a DOWNLOAD_URLS=()

if [ "$FLUTTER_VERSION" = "latest" ]; then
    echo "Preparing to download latest stable Flutter precompiled binary..."
    # Try multiple URL patterns for latest stable
    DOWNLOAD_URLS+=(
        "${FLUTTER_BASE_URL}/stable/${PLATFORM}/flutter_${PLATFORM}-${ARCH_SUFFIX}-stable.tar.xz"
        "${FLUTTER_BASE_URL}/stable/${PLATFORM}/flutter_${PLATFORM}-stable.tar.xz"
    )
else
    # Use specified version
    echo "Preparing to download Flutter ${FLUTTER_VERSION} precompiled binary..."
    # Remove 'v' prefix if present
    CLEAN_VERSION="${FLUTTER_VERSION#v}"
    # Try multiple URL patterns for specific version
    DOWNLOAD_URLS+=(
        "${FLUTTER_BASE_URL}/stable/${PLATFORM}/flutter_${PLATFORM}-${CLEAN_VERSION}-${ARCH_SUFFIX}-stable.tar.xz"
        "${FLUTTER_BASE_URL}/stable/${PLATFORM}/flutter_${PLATFORM}-v${CLEAN_VERSION}-stable.tar.xz"
        "${FLUTTER_BASE_URL}/stable/${PLATFORM}/flutter_${PLATFORM}-${CLEAN_VERSION}-stable.tar.xz"
    )
fi

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

# Try each URL until one works
DOWNLOAD_SUCCESS=false
for DOWNLOAD_URL in "${DOWNLOAD_URLS[@]}"; do
    echo "Trying: ${DOWNLOAD_URL}"
    
    # Try with SSL verification first
    if curl -fsSL "$DOWNLOAD_URL" -o "flutter.tar.xz" 2>/dev/null; then
        DOWNLOAD_SUCCESS=true
        break
    fi
    
    # If SSL fails, try without SSL verification (for Docker build environments)
    echo "  SSL verification failed, retrying without..."
    if curl -fsSLk "$DOWNLOAD_URL" -o "flutter.tar.xz" 2>/dev/null; then
        DOWNLOAD_SUCCESS=true
        break
    fi
    
    echo "  Failed, trying next URL..."
    rm -f "flutter.tar.xz"
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo "ERROR: Failed to download Flutter SDK from any known URL"
    echo "URLs attempted:"
    printf '  %s\n' "${DOWNLOAD_URLS[@]}"
    echo ""
    echo "This might be due to:"
    echo "  1. Network connectivity issues"
    echo "  2. Invalid version number"
    echo "  3. Google Cloud Storage access restrictions"
    echo ""
    echo "Please check https://docs.flutter.dev/release/archive for available versions"
    exit 1
fi

echo "Download successful from: ${DOWNLOAD_URL}"

# Verify we got a valid tar.xz file
if ! file "flutter.tar.xz" | grep -q "XZ compressed data"; then
    echo "ERROR: Downloaded file is not a valid tar.xz archive"
    file "flutter.tar.xz"
    exit 1
fi

# Extract to install directory
echo "Extracting Flutter SDK..."
mkdir -p "$(dirname "$FLUTTER_INSTALL_DIR")"
tar -xf "flutter.tar.xz" -C "$(dirname "$FLUTTER_INSTALL_DIR")"

# Verify extraction
if [ ! -d "$FLUTTER_INSTALL_DIR" ] || [ ! -f "$FLUTTER_INSTALL_DIR/bin/flutter" ]; then
    echo "ERROR: Flutter SDK extraction failed"
    exit 1
fi

# Add Flutter to PATH for all users
echo "Adding Flutter to PATH..."
cat << EOF > /etc/profile.d/flutter.sh
export PATH="\$PATH:$FLUTTER_INSTALL_DIR/bin"
export FLUTTER_ROOT="$FLUTTER_INSTALL_DIR"
EOF
chmod +x /etc/profile.d/flutter.sh

# Also create a symlink to make flutter available system-wide
ln -sf "$FLUTTER_INSTALL_DIR/bin/flutter" /usr/local/bin/flutter
ln -sf "$FLUTTER_INSTALL_DIR/bin/dart" /usr/local/bin/dart

# Set permissions for the Flutter directory to allow non-root users to use it
chmod -R a+rw "$FLUTTER_INSTALL_DIR"

# Clean up
cd - >/dev/null
rm -rf /var/lib/apt/lists/*

echo "Flutter SDK installation completed!"
echo "Run 'flutter doctor' to verify the installation and download necessary components."
echo "Done!"

