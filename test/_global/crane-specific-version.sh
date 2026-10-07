#!/bin/bash

set -e
source dev-container-features-test-lib
check "crane with specific version" /bin/bash -c "crane version | grep -Fx '0.22.1'"

reportResults
