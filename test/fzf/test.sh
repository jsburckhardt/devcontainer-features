#!/bin/bash

set -e

source dev-container-features-test-lib
check "fzf" fzf --version
reportResults
