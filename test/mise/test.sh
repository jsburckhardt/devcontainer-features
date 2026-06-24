#!/bin/bash

set -e
source dev-container-features-test-lib
check "mise" mise --version
reportResults
