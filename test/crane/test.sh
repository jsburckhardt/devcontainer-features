#!/bin/bash

set -e

source dev-container-features-test-lib
check "crane" crane
reportResults
