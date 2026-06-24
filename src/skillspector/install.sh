#!/usr/bin/env bash

# Variables
REPO_OWNER="NVIDIA"
REPO_NAME="SkillSpector"
BINARY_NAME="skillspector"
SKILLSPECTOR_VERSION="${VERSION:-"latest"}"
# SkillSpector upstream pyproject pins Python >=3.12,<3.14. We provision it via uv.
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"
GITHUB_API_REPO_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"

set -e

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

check_packages curl jq ca-certificates tar git

# Map architecture for uv asset naming
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) UV_ARCH="x86_64" ;;
    aarch64) UV_ARCH="aarch64" ;;
    armv7l) UV_ARCH="armv7" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Bootstrap uv from astral-sh/uv GitHub releases. uv handles Python toolchain
# provisioning so we can satisfy SkillSpector's strict <3.14 Python requirement
# regardless of the base image's system Python.
if ! command -v uv >/dev/null 2>&1; then
    UV_LATEST=$(curl -s https://api.github.com/repos/astral-sh/uv/releases/latest | jq -r '.tag_name')
    UV_URL="https://github.com/astral-sh/uv/releases/download/${UV_LATEST}/uv-${UV_ARCH}-unknown-linux-gnu.tar.gz"
    UV_TMP=$(mktemp -d)
    echo "Installing uv ${UV_LATEST} from ${UV_URL}"
    curl -sSL "${UV_URL}" -o "${UV_TMP}/uv.tar.gz"
    tar -xzf "${UV_TMP}/uv.tar.gz" -C "${UV_TMP}"
    mv "${UV_TMP}/uv-${UV_ARCH}-unknown-linux-gnu/uv" /usr/local/bin/uv
    mv "${UV_TMP}/uv-${UV_ARCH}-unknown-linux-gnu/uvx" /usr/local/bin/uvx
    chmod +x /usr/local/bin/uv /usr/local/bin/uvx
    rm -rf "${UV_TMP}"
fi

# Resolve git ref. SkillSpector has no GitHub releases; we pin against a Git ref
# (tag, branch, or commit SHA). "latest" resolves to the default branch's HEAD SHA.
get_default_branch_sha() {
    local branch
    branch=$(curl -s "${GITHUB_API_REPO_URL}" | jq -r '.default_branch')
    curl -s "${GITHUB_API_REPO_URL}/commits/${branch}" | jq -r '.sha'
}

if [ -z "$SKILLSPECTOR_VERSION" ] || [ "$SKILLSPECTOR_VERSION" == "latest" ]; then
    SKILLSPECTOR_VERSION=$(get_default_branch_sha)
    echo "No version provided or 'latest' specified, installing from default branch HEAD: $SKILLSPECTOR_VERSION"
else
    echo "Installing SkillSpector at git ref: $SKILLSPECTOR_VERSION"
fi

# Use uv to install into a system-wide tool location with the right Python
export UV_TOOL_DIR="${UV_TOOL_DIR:-/opt/uv-tools}"
export UV_TOOL_BIN_DIR="${UV_TOOL_BIN_DIR:-/usr/local/bin}"
export UV_PYTHON_INSTALL_DIR="${UV_PYTHON_INSTALL_DIR:-/opt/uv-python}"
mkdir -p "${UV_TOOL_DIR}" "${UV_PYTHON_INSTALL_DIR}"

PIP_SPEC="git+https://github.com/${REPO_OWNER}/${REPO_NAME}.git@${SKILLSPECTOR_VERSION}"

echo "Installing skillspector from ${PIP_SPEC} via uv tool (python=${PYTHON_VERSION})..."
uv tool install --python "${PYTHON_VERSION}" "${PIP_SPEC}"

# Cleanup
rm -rf /var/lib/apt/lists/*

# Verify installation
echo "Verifying installation..."
skillspector --version

echo "Done!"
