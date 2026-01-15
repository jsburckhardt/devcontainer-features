#!/bin/bash

set -e

source dev-container-features-test-lib
check "vibe-kanban command exists" command -v vibe-kanban
reportResults
