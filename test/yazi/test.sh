#!/bin/bash

set -e

source dev-container-features-test-lib
check "yazi" yazi --version
reportResults
