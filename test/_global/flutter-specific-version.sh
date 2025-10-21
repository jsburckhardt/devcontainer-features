#!/bin/bash

set -e
source dev-container-features-test-lib
check "flutter with specific version" /bin/bash -c "flutter --version | grep '3.24.5'"

reportResults
