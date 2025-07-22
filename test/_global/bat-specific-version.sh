#!/bin/bash

set -e
source dev-container-features-test-lib
check "bat with specific version" /bin/bash -c "bat --version | grep '0.25.0'"

reportResults
