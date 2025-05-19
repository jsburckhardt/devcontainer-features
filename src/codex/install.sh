#!/bin/bash

# Variables
REPO_OWNER="openai"
REPO_NAME="codex"
BINARY_NAME="codex"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# make sure we have packages
check_packages curl jq ca-certificates zstd unzip file

# Function to get the most recent release (including pre-releases) from GitHub API
get_latest_version() {
    RELEASES_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases"
    echo "Fetching list of releases from $RELEASES_URL to determine the latest version..." >&2
    # Fetches all releases, takes the first one (most recent, including pre-releases),
    # and extracts its tag_name using jq.
    # Returns an empty string if no releases are found or tag_name is missing, leading to an error.
    VERSION_TAG=$(curl -s "$RELEASES_URL" | jq -r '.[0].tag_name // ""')

    if [ -z "$VERSION_TAG" ]; then
        echo "Error: Could not automatically determine the latest version tag from $RELEASES_URL." >&2
        echo "Please check the releases page on GitHub and try again later." >&2
        exit 1
    fi
    echo "$VERSION_TAG"
}

# Always install the latest version
VERSION=$(get_latest_version)
echo "Installing latest version: $VERSION"

# Determine the OS and architecture
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    ARCH="x86_64"
    TARGET="x86_64-unknown-linux-musl"
elif [ "$ARCH" == "i686" ]; then
    ARCH="i386"
    TARGET="i686-unknown-linux-musl"
elif [ "$ARCH" == "armv7l" ]; then
    ARCH="armv7"
    TARGET="armv7-unknown-linux-gnueabihf"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
    TARGET="aarch64-unknown-linux-gnu"
fi

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit

# First check what assets are available in the release
RELEASE_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/tags/$VERSION"
echo "Checking available assets for release: $VERSION"

ASSETS=$(curl -s "$RELEASE_URL" | jq -r '.assets[].name' 2>/dev/null || echo "")

# If we couldn't get the assets list or it's empty, try a common pattern
if [ -z "$ASSETS" ]; then
    echo "Could not retrieve assets list, using common release patterns"

    # Try common naming patterns for binary releases
    DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/${BINARY_NAME}-${TARGET}.zst"

    echo "Attempting to download from: $DOWNLOAD_URL"
    if ! curl -L --output "${BINARY_NAME}.zst" --fail "$DOWNLOAD_URL"; then
        # Try alternative formats if zst fails
        echo "Failed to download zst format, trying tar.gz..."
        DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/${BINARY_NAME}-${OS}-${ARCH}.tar.gz"
        echo "Attempting to download from: $DOWNLOAD_URL"

        if ! curl -L --output "${BINARY_NAME}.tar.gz" --fail "$DOWNLOAD_URL"; then
            echo "Failed to download tar.gz format, trying zip..."
            DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/${BINARY_NAME}-${OS}-${ARCH}.zip"
            echo "Attempting to download from: $DOWNLOAD_URL"

            if ! curl -L --output "${BINARY_NAME}.zip" --fail "$DOWNLOAD_URL"; then
                echo "Failed to download any known release format. Please check if the release exists and try again."
                exit 1
            else
                echo "Downloaded zip file successfully"
                unzip -q "${BINARY_NAME}.zip"
            fi
        else
            echo "Downloaded tar.gz file successfully"
            tar -xzf "${BINARY_NAME}.tar.gz"
        fi
    else
        echo "Downloaded zst file successfully"
        zstd -d "${BINARY_NAME}.zst" -o "$BINARY_NAME"
    fi
else
    echo "Available assets:"
    echo "$ASSETS"

    # Look for matching assets based on architecture and naming pattern
    # Try to match the most likely asset name for the binary
    ASSET_PATTERN="${BINARY_NAME}-*${TARGET}.zst"
    ZST_ASSET=$(echo "$ASSETS" | grep -E "^$ASSET_PATTERN$" | head -n 1 || echo "")

    # Fallback: try to match any zst for the target
    if [ -z "$ZST_ASSET" ]; then
        ZST_ASSET=$(echo "$ASSETS" | grep -i "${TARGET}.zst" | head -n 1 || echo "")
    fi

    TARGZ_ASSET=$(echo "$ASSETS" | grep -i "${OS}.*${ARCH}.*tar.gz" | head -n 1 || echo "")
    ZIP_ASSET=$(echo "$ASSETS" | grep -i "${OS}.*${ARCH}.*zip" | head -n 1 || echo "")

    # Try to download in order of preference: zst, tar.gz, zip
    if [ -n "$ZST_ASSET" ]; then
        echo "Found zst asset: $ZST_ASSET"
        DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/$ZST_ASSET"
        echo "Downloading from: $DOWNLOAD_URL"
        curl -L --output "$ZST_ASSET" --fail "$DOWNLOAD_URL"
        zstd -d "$ZST_ASSET" -o "$BINARY_NAME"
    elif [ -n "$TARGZ_ASSET" ]; then
        echo "Found tar.gz asset: $TARGZ_ASSET"
        DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/$TARGZ_ASSET"
        echo "Downloading from: $DOWNLOAD_URL"
        curl -L --output "$TARGZ_ASSET" --fail "$DOWNLOAD_URL"
        tar -xzf "$TARGZ_ASSET"
    elif [ -n "$ZIP_ASSET" ]; then
        echo "Found zip asset: $ZIP_ASSET"
        DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/$ZIP_ASSET"
        echo "Downloading from: $DOWNLOAD_URL"
        curl -L --output "$ZIP_ASSET" --fail "$DOWNLOAD_URL"
        unzip -q "$ZIP_ASSET"
    else
        echo "No suitable assets found for $OS/$ARCH"
        exit 1
    fi
fi

# Find the binary in the extracted files if it's not in the current directory
if [ ! -f "$BINARY_NAME" ]; then
    BINARY_PATH=$(find . -type f -executable -name "$BINARY_NAME" | head -n 1)
    if [ -z "$BINARY_PATH" ]; then
        echo "Could not find $BINARY_NAME binary in the extracted files"
        exit 1
    fi
    BINARY_NAME="$BINARY_PATH"
fi

# Make the binary executable
chmod +x "$BINARY_NAME"

# Move the binary to /usr/local/bin
echo "Installing $BINARY_NAME"
mv "$BINARY_NAME" /usr/local/bin/

# Cleanup
cd - || exit
rm -rf "$TMP_DIR"

# Verify installation
echo "Verifying installation"
if $BINARY_NAME --version; then
    echo "Installation verified successfully"
else
    echo "Installation completed, but $BINARY_NAME --version failed. This may be expected for some versions."
fi

# Create a wrapper script to set required environment variables
echo "Creating wrapper script"
cat > "/usr/local/bin/${BINARY_NAME}-wrapper" << EOF
#!/bin/bash
# Set required environment variables for codex
export OPENAI_API_KEY=\${OPENAI_API_KEY:-}

# Execute the real binary with all arguments
echo "Starting codex - remember to set your OPENAI_API_KEY environment variable"
exec $BINARY_NAME "\$@"
EOF

# Make the wrapper script executable
chmod +x "/usr/local/bin/${BINARY_NAME}-wrapper"

# Create a symlink for convenience
ln -sf "/usr/local/bin/${BINARY_NAME}-wrapper" "/usr/local/bin/${BINARY_NAME}-cli"

echo "$BINARY_NAME has been installed successfully."
