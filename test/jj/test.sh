#!/bin/bash

set -e
source dev-container-features-test-lib
check "jj" jj --version
reportResults
