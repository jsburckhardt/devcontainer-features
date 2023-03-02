#!/bin/bash

set -e
source dev-container-features-test-lib
check "flux" flux version --client
check "notation" notation version

reportResults
