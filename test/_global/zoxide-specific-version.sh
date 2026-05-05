#!/bin/bash

set -e
source dev-container-features-test-lib
check "zoxide with specific version" /bin/bash -c "zoxide --version | grep '0.9.6'"

reportResults
