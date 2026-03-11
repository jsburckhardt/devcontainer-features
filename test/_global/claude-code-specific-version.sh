#!/bin/bash

set -e
source dev-container-features-test-lib
check "claude-code with specific version" /bin/bash -c "claude --version | grep '1.0.58'"

reportResults
