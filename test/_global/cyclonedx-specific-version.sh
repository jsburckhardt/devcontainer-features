#!/bin/bash

set -e
source dev-container-features-test-lib
check "cyclonedx with specific version" /bin/bash -c "cyclonedx --version | grep '0.24.2'"

reportResults
