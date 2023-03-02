#!/bin/bash

set -e

source dev-container-features-test-lib
check "notation" notation
reportResults
