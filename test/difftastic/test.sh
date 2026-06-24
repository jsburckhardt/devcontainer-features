#!/bin/bash

set -e

source dev-container-features-test-lib
check "difftastic" difft --version
reportResults
