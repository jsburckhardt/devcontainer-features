#!/bin/bash

set -e
source dev-container-features-test-lib
check "glow with specific version" /bin/bash -c "glow --version | grep '2.1.2'"

reportResults
