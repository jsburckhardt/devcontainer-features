#!/bin/bash

set -e
source dev-container-features-test-lib
check "skopeo in debian" /bin/bash -c "skopeo --version | grep 'skopeo'"

reportResults
