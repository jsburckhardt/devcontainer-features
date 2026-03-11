#!/bin/bash

set -e

source dev-container-features-test-lib
check "claude-code" claude --version
reportResults
