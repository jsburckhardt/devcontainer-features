#!/bin/bash

set -e
source dev-container-features-test-lib
check "yazi with specific version" /bin/bash -c "yazi --version | grep '26.1.22'"

reportResults
