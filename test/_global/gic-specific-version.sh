#!/bin/bash

set -e
source dev-container-features-test-lib
check "gic with specific version" /bin/bash -c "gic --version | grep '2.1.0'"

reportResults
