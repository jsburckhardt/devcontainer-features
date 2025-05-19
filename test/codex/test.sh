#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md
source dev-container-features-test-lib

# Feature-specific tests
check "codex version" codex --version

# Report result
reportResults
