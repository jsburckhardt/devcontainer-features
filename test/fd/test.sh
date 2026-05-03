#!/bin/bash

set -e

source dev-container-features-test-lib
check "fd" fd --version
reportResults
