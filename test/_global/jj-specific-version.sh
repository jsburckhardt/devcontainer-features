#!/bin/bash

set -e
source dev-container-features-test-lib
check "jj with specific version" /bin/bash -c "jj --version | grep '0.42.0'"
reportResults
