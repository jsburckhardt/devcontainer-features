#!/bin/bash

set -e
source dev-container-features-test-lib
check "opencode with specific version" /bin/bash -c "opencode --version | grep '1.0.107'"

reportResults
