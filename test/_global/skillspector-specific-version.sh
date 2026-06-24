#!/bin/bash

set -e
source dev-container-features-test-lib
check "skillspector with specific version" /bin/bash -c "skillspector --version | grep '2.3.5'"

reportResults
