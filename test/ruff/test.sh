#!/bin/bash

set -e

source dev-container-features-test-lib
check "ruff" ruff -h
reportResults
