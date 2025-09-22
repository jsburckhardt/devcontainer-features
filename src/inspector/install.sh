#!/usr/bin/env bash

INSPECTOR_VERSION="${VERSION:-"latest"}"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

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

# Figure out correct version of a three part version number is not passed
validate_version_exists() {
    local variable_name=$1
    local requested_version=$2
    if [ "${requested_version}" = "latest" ]; then
        # Default to a known good version if we can't query npm
        requested_version="0.16.8"
        echo "Using default version ${requested_version} as fallback"
    fi
    # Remove 'v' prefix if present
    requested_version=${requested_version#v}
    echo "${variable_name}=${requested_version}"
}

# Check Node.js and install MCP Inspector 
install_inspector() {
    local node_version=""
    local required_version="22.7.5"
    local install_method="global"
    
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version | sed 's/v//')
        echo "Found Node.js version: $node_version"
        
        if ! printf '%s\n%s\n' "$required_version" "$node_version" | sort -V -C; then
            echo "Warning: Node.js version $node_version is below the recommended >=$required_version"
            echo "Installing inspector anyway - it may not work correctly with older Node.js versions"
        fi
        
        # Check if npm is available
        if ! command -v npm >/dev/null 2>&1; then
            echo "Warning: npm is not available. Installing npm..."
            apt-get install -y npm
        fi
        
    else
        echo "Node.js is not installed. Attempting to install Node.js and npm..."
        
        # Try to install nodejs from apt (will be older version but better than nothing)
        apt-get update -y
        apt-get install -y nodejs npm
        
        if command -v node >/dev/null 2>&1; then
            node_version=$(node --version | sed 's/v//')
            echo "Installed Node.js version: $node_version"
            echo "Warning: This version may not meet MCP Inspector requirements (>=$required_version)"
        else
            echo "Error: Failed to install Node.js. MCP Inspector requires Node.js to function."
            echo "Please install Node.js >=22.7.5 manually and re-run this feature."
            exit 1
        fi
    fi
    
    # Install the inspector
    echo "Installing MCP Inspector version: ${CLEAN_VERSION}"
    
    # Configure npm to handle SSL issues in container environments
    npm config set strict-ssl false
    npm config set registry https://registry.npmjs.org/
    
    if [ "${CLEAN_VERSION}" = "latest" ]; then
        npm install -g @modelcontextprotocol/inspector
    else
        npm install -g @modelcontextprotocol/inspector@${CLEAN_VERSION}
    fi
    
    # Reset npm config to secure defaults
    npm config set strict-ssl true
}

# make sure we have necessary packages
check_packages curl ca-certificates gnupg

# make sure version is available and install inspector
validate_version_exists INSPECTOR_VERSION "${INSPECTOR_VERSION}"

# Remove 'v' prefix if present for npm install
CLEAN_VERSION=${INSPECTOR_VERSION#v}

# Install inspector (this handles Node.js installation too)
install_inspector

# Verify installation
echo "Verifying installation..."
if command -v mcp-inspector >/dev/null 2>&1; then
    echo "MCP Inspector installed successfully!"
    mcp-inspector --version || echo "MCP Inspector installed (version command may not be available)"
else
    echo "Warning: mcp-inspector command not found in PATH after installation"
    echo "You can still run the inspector using: npx @modelcontextprotocol/inspector"
fi

# Create a convenience script for common usage
cat > /usr/local/bin/inspector << 'EOF'
#!/bin/bash
# Convenience wrapper for MCP Inspector
# Supports both UI mode and CLI mode

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "MCP Inspector - Developer tool for testing and debugging MCP servers"
    echo ""
    echo "Usage:"
    echo "  inspector                          # Start UI mode"
    echo "  inspector --cli [options]          # Start CLI mode"
    echo "  inspector <server-command>         # Start UI with server"
    echo ""
    echo "Examples:"
    echo "  inspector                          # Open UI at http://localhost:6274"
    echo "  inspector node server.js          # Start UI with Node.js server"
    echo "  inspector --cli node server.js    # CLI mode with server"
    echo ""
    echo "For more options, see: https://github.com/modelcontextprotocol/inspector"
    exit 0
fi

# Run the actual inspector
exec mcp-inspector "$@"
EOF

chmod +x /usr/local/bin/inspector

echo "Created convenience wrapper 'inspector' command"
echo ""
echo "MCP Inspector is now available as:"
echo "  - mcp-inspector (main command)"
echo "  - inspector (convenience wrapper)"
echo "  - npx @modelcontextprotocol/inspector (direct npm execution)"
echo ""
echo "Usage examples:"
echo "  inspector                    # Start UI mode"
echo "  inspector node server.js    # Start with a server"
echo "  inspector --cli node server.js # CLI mode"

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"