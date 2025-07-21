#!/usr/bin/env bash

BAT_VERSION="${VERSION:-"latest"}"

set -e

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

echo "Installing bat..."

# For simplicity and reliability, install bat from Ubuntu repositories
# This provides a stable version that works well in devcontainer environments
check_packages bat

# Verify installation
echo "Verifying bat installation..."

# In Ubuntu, bat is installed as 'batcat' to avoid conflicts
if command -v batcat >/dev/null 2>&1; then
	echo "batcat installed successfully!"
	batcat --version
	# Create a symlink so users can use 'bat' command
	ln -sf /usr/bin/batcat /usr/local/bin/bat
	echo "Created symlink: /usr/local/bin/bat -> /usr/bin/batcat"
elif command -v bat >/dev/null 2>&1; then
	echo "bat installed successfully!"
	bat --version
else
	echo "ERROR: bat installation failed - neither bat nor batcat found"
	exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"