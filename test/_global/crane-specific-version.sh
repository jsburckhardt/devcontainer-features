#!/bin/bash

set -e
source dev-container-features-test-lib
check "crane with specific version" /bin/bash -c "crane version | grep '0.13.0'"

reportResults
