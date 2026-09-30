#!/bin/bash

set -e
source dev-container-features-test-lib
check "worktrunk" wt --version
reportResults
