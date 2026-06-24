#!/bin/bash

set -e
source dev-container-features-test-lib
check "ast-grep" sg --version
reportResults
