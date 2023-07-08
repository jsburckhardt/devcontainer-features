#!/bin/bash

set -e
source dev-container-features-test-lib
check "azd with specific version" /bin/bash -c "azd version | grep '1.0.2'"

reportResults
