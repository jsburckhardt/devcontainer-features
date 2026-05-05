#!/bin/bash

set -e

source dev-container-features-test-lib
check "zoxide" zoxide --version
reportResults
