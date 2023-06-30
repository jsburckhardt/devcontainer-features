#!/bin/bash

set -e
source dev-container-features-test-lib
check "gitleaks with specific version" /bin/bash -c "gitleaks version | grep '8.17.0'"

reportResults
