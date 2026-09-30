#!/bin/bash

set -e

source dev-container-features-test-lib

check "floci with specific version" /bin/bash -c "floci --version | grep 'floci 0.2.3'"

reportResults
