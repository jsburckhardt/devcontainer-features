#!/bin/bash

set -e

source dev-container-features-test-lib
check "actionlint with specific version" /bin/bash -c "actionlint --version | grep '1.7.7'"
reportResults
