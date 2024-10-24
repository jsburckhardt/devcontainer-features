#!/bin/bash

set -e
source dev-container-features-test-lib
check "ruff with specific version" /bin/bash -c "ruff --version | grep '0.7.0'"

reportResults
