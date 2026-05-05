#!/bin/bash

set -e
source dev-container-features-test-lib
check "tmux with specific version" /bin/bash -c "tmux -V | grep '3.6a'"

reportResults
