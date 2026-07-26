#!/bin/bash

set -e

source dev-container-features-test-lib
check "colibri" bash -c "command -v colibri"
check "colibri VERSION marker" test -s /usr/local/share/colibri/VERSION
reportResults
