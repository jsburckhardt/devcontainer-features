#!/bin/bash

set -e

source dev-container-features-test-lib
check "just" just --version
reportResults