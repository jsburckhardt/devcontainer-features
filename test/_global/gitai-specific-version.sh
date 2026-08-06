#!/bin/bash

set -e

source dev-container-features-test-lib
check "gitai with specific version" /bin/bash -c "git-ai --version | grep '1.6.21'"
reportResults
