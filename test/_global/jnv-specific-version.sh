#!/bin/bash

set -e
source dev-container-features-test-lib
check "jnv with specific version" /bin/bash -c "jnv -V | grep '0.1.2'"

reportResults
