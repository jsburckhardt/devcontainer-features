#!/bin/bash

set -e

source dev-container-features-test-lib
check "vibe-kanban" vibe-kanban --version
reportResults
