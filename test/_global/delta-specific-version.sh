#!/bin/bash

set -e

source dev-container-features-test-lib
check "delta with specific version" /bin/bash -c "delta --version | grep '0.18.2'"
reportResults
