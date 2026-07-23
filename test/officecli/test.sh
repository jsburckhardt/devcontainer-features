#!/bin/bash
set -e
source dev-container-features-test-lib
check "officecli" officecli --version
reportResults
