#!/bin/bash

set -e
source dev-container-features-test-lib
check "lazygit with specific version" /bin/bash -c "lazygit --version | grep '0.44.0'"

reportResults
