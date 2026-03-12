#!/bin/bash

set -e
source dev-container-features-test-lib
check "ccc with specific version" /bin/bash -c "ccc --version | grep '0.1.5'"

reportResults
