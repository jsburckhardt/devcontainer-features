#!/bin/bash

set -e

source dev-container-features-test-lib
check "ccc" ccc --version
reportResults
