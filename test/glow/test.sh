#!/bin/bash

set -e

source dev-container-features-test-lib
check "glow" glow --version
reportResults
