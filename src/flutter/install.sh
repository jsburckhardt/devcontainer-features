#!/usr/bin/env bash

# Variables
FLUTTER_VERSION="${VERSION:-"latest"}"
FLUTTER_INSTALL_DIR="/opt/flutter"

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
# git, unzip, xz-utils, curl, libglu1-mesa are required for Flutter
check_packages curl git ca-certificates unzip xz-utils libglu1-mesa file

echo "Installing Flutter version: $FLUTTER_VERSION"

# Clone Flutter repository using git (most reliable method)
echo "Cloning Flutter repository..."
# Use shallow clone for faster download, disable SSL verification for build environment
if [ "$FLUTTER_VERSION" = "latest" ]; then
    GIT_SSL_NO_VERIFY=true git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_INSTALL_DIR"
else
    # Clone with specific version tag
    GIT_SSL_NO_VERIFY=true git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_INSTALL_DIR"
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
rm -rf /var/lib/apt/lists/*

echo "Flutter SDK installation completed!"
echo "Note: Dart SDK and other components will be downloaded automatically on first use."
echo "Run 'flutter doctor' to complete the setup and download necessary components."
echo "Done!"

