#!/bin/bash

set -e
source dev-container-features-test-lib
check "flux with specific version" /bin/bash -c "flux version --client | grep 'v2.6.4'"

reportResults
