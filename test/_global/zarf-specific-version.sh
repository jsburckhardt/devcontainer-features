#!/bin/bash

set -e
source dev-container-features-test-lib
check "zarf with specific version" /bin/bash -c "zarf version | grep 'v0.61.2'"

reportResults
