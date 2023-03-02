#!/bin/bash

set -e
source dev-container-features-test-lib
check "notation with specific version" /bin/bash -c "notation version | grep '1.0.0-rc.2'"

reportResults
