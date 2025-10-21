#!/bin/bash

set -e

source dev-container-features-test-lib
check "flutter" flutter --version
check "dart" dart --version
reportResults
