#!/bin/bash

set -e
source dev-container-features-test-lib
check "vibe-kanban with specific version installed" command -v vibe-kanban

reportResults
