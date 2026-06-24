#!/bin/bash

set -e

source dev-container-features-test-lib
check "difftastic with specific version" /bin/bash -c "difft --version | grep '0.63.0'"
reportResults
