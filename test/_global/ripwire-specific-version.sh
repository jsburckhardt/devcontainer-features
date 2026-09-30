#!/bin/bash

set -e
source dev-container-features-test-lib
check "ripwire with specific version" /bin/bash -c "ripwire --version | grep '0.6.4'"
reportResults
