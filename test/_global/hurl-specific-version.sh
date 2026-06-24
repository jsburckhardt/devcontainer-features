#!/bin/bash

set -e
source dev-container-features-test-lib
check "hurl with specific version" /bin/bash -c "hurl --version | grep '7.1.0'"

reportResults
