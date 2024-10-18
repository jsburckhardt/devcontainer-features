#!/bin/bash

set -e
source dev-container-features-test-lib
check "uv with specific version" /bin/bash -c "uv --version | grep '0.4.23'"

reportResults
