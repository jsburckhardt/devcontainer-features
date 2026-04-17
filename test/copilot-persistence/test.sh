#!/bin/bash

set -e

source dev-container-features-test-lib
check "copilot-persistence" test -L "$HOME/.copilot"
reportResults
