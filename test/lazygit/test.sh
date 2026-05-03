#!/bin/bash

set -e

source dev-container-features-test-lib
check "lazygit" lazygit --version
reportResults
