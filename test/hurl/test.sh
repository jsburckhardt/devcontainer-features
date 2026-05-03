#!/bin/bash

set -e

source dev-container-features-test-lib
check "hurl" hurl --version
reportResults
