#!/usr/bin/env bash

# Variables
FLUTTER_VERSION="${VERSION:-"latest"}"
FLUTTER_INSTALL_DIR="/opt/flutter"
FLUTTER_CHANNEL="${CHANNEL:-"stable"}"

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
check_packages curl git ca-certificates xz-utils libglu1-mesa file

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

# Clone the Flutter repository
echo "Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_INSTALL_DIR"

cd "$FLUTTER_INSTALL_DIR"

# If a specific version is requested, checkout that version
if [ "$FLUTTER_VERSION" != "latest" ]; then
    echo "Checking out Flutter version: $FLUTTER_VERSION"
    git checkout "$FLUTTER_VERSION"
else
    echo "Using latest stable version"
fi

# Run Flutter precache to download necessary artifacts
echo "Running flutter precache..."
"$FLUTTER_INSTALL_DIR/bin/flutter" precache

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
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
flutter --version

echo "Done!"
