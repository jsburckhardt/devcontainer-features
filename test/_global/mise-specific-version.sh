#!/bin/bash

set -e
source dev-container-features-test-lib
check "mise with specific version" /bin/bash -c "mise --version | grep '2024.7.1'"
reportResults
