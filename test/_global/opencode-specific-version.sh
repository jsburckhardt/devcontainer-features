#!/bin/bash

set -e
source dev-container-features-test-lib
check "opencode with specific version" /bin/bash -c "opencode --version | grep '0.10.0'"

reportResults
