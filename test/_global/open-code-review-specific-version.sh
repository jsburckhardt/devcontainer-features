#!/bin/bash

set -e

source dev-container-features-test-lib
check "open-code-review with specific version" /bin/bash -c "opencodereview --version | grep '1.4.1'"
reportResults
