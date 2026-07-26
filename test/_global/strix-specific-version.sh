#!/bin/bash

set -e
source dev-container-features-test-lib
check "strix with specific version" /bin/bash -c "strix --version | grep '1.0.4'"

reportResults
