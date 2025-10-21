#!/bin/bash

set -e
source dev-container-features-test-lib
# Check flutter installation directory for version tag
check "flutter specific version tag" test -d /opt/flutter/.git

reportResults
