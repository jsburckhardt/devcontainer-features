#!/bin/bash

set -e
source dev-container-features-test-lib
check "fx with specific version" /bin/bash -c "fx --version | grep '35.0.0'"

reportResults
