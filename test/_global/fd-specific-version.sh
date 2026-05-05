#!/bin/bash

set -e
source dev-container-features-test-lib
check "fd with specific version" /bin/bash -c "fd --version | grep '10.2.0'"

reportResults
