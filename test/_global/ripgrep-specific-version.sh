#!/bin/bash

set -e
source dev-container-features-test-lib
check "ripgrep with specific version" /bin/bash -c "rg --version | grep '14.1.1'"

reportResults
