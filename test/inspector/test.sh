#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md
source dev-container-features-test-lib

# Feature-specific tests
check "mcp-inspector command exists" which mcp-inspector
check "inspector wrapper exists" which inspector
check "inspector help (non-interactive)" timeout 10 inspector --help
check "npm package installed" npm list -g @modelcontextprotocol/inspector

# Report result
reportResults