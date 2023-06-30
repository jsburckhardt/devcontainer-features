#!/bin/bash

set -e

source dev-container-features-test-lib
check "gitleaks" gitleaks
reportResults
