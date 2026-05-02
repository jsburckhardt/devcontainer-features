#!/bin/bash

set -e
source dev-container-features-test-lib
check "tmux is installed" /bin/bash -c "tmux -V"

reportResults
