#!/bin/bash
set -e
source dev-container-features-test-lib
check "officecli with specific version" /bin/bash -c "officecli --version | grep '1.0.139'"
reportResults
