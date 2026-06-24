#!/bin/bash

set -e
source dev-container-features-test-lib
check "markitdown with specific version" /bin/bash -c "markitdown --version | grep '0.1.6'"

reportResults
