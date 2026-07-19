#!/bin/bash

set -e
source dev-container-features-test-lib
check "colibri with specific version" /bin/bash -c "cat /usr/local/share/colibri/VERSION | grep 'v1.0.0'"

reportResults
