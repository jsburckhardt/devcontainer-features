#!/bin/bash

set -e

source dev-container-features-test-lib
check "difftastic with versioned release asset" /bin/bash -c "difft --version | grep -F 'Difftastic 0.71.0'"
reportResults
