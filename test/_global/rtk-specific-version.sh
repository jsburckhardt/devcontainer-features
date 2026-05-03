#!/bin/bash

set -e
source dev-container-features-test-lib
check "rtk with specific version" /bin/bash -c "rtk --version | grep '0.38.0'"

reportResults
