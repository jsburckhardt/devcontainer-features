#!/bin/bash

set -e

source dev-container-features-test-lib

check "floci" floci --version

reportResults
