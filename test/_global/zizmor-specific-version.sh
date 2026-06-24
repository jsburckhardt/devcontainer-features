#!/bin/bash
set -e
source dev-container-features-test-lib
check "zizmor with specific version" /bin/bash -c "zizmor --version | grep '1.23.1'"
reportResults
