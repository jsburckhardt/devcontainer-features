#!/bin/bash

set -e
source dev-container-features-test-lib
check "just with specific version" /bin/bash -c "just --version | grep '1.42.0'"

reportResults