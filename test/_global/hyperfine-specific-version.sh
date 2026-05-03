#!/bin/bash

set -e
source dev-container-features-test-lib
check "hyperfine with specific version" /bin/bash -c "hyperfine --version | grep '1.19.0'"

reportResults
