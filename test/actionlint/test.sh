#!/bin/bash

set -e

source dev-container-features-test-lib
check "actionlint" actionlint --version
reportResults
