#!/bin/bash

set -e

source dev-container-features-test-lib
check "hyperfine" hyperfine --version
reportResults
