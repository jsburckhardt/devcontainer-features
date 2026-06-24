#!/bin/bash

set -e
source dev-container-features-test-lib
check "ast-grep with specific version" /bin/bash -c "sg --version | grep '0.36.0'"
reportResults
