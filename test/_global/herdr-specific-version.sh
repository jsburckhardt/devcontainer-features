#!/bin/bash

set -e

source dev-container-features-test-lib

check "herdr with specific version" /bin/bash -c "herdr --version | grep '0.7.3'"

reportResults
