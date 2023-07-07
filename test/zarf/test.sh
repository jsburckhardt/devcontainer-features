#!/bin/bash

set -e

source dev-container-features-test-lib
check "zarf" zarf version
reportResults
