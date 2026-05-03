#!/bin/bash

set -e
source dev-container-features-test-lib
check "fzf with specific version" /bin/bash -c "fzf --version | grep '0.58.0'"

reportResults
