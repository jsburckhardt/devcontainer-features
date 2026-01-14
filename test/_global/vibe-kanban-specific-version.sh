#!/bin/bash

set -e
source dev-container-features-test-lib
check "vibe-kanban with specific version" /bin/bash -c "vibe-kanban --version | grep '0.0.97'"

reportResults
