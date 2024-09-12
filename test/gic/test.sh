#!/bin/bash

set -e

source dev-container-features-test-lib
check "gic" gic
reportResults
