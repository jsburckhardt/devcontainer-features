#!/bin/bash

set -e
source dev-container-features-test-lib
check "kyverno with specific version" /bin/bash -c "kyverno version | grep '1.9.1'"

reportResults
