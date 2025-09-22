#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test specific version installation
check "mcp-inspector exists" which mcp-inspector
check "inspector wrapper exists" which inspector  
check "specific version installed" npm list -g @modelcontextprotocol/inspector@0.16.8
check "inspector help works" inspector --help

# Report result
reportResults