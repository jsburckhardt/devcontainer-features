#!/bin/bash

set -e

source dev-container-features-test-lib
check "delta" delta --version
reportResults
