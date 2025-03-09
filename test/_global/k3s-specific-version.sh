#!/bin/bash

set -e
source dev-container-features-test-lib
check "k3s with specific version" /bin/bash -c "k3s --version | grep 'v1.21.4+k3s1'"

reportResults
