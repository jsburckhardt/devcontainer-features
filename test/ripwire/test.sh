#!/bin/bash

set -e
source dev-container-features-test-lib
check "ripwire" ripwire --version
reportResults
