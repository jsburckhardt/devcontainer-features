#!/bin/bash

set -e
source dev-container-features-test-lib
check "worktrunk with specific version" /bin/bash -c "wt --version | grep '0.79.0'"
reportResults
