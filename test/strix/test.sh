#!/bin/bash

set -e

source dev-container-features-test-lib
check "strix" strix --version
reportResults
