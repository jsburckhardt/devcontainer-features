#!/bin/bash

set -e
source dev-container-features-test-lib
check "flux with specific version" /bin/bash -c "flux version --client | grep 'v0.37.0'"

reportResults
