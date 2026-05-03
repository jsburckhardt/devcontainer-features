#!/bin/bash

set -e

source dev-container-features-test-lib
check "ripgrep" rg --version
reportResults
