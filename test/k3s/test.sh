#!/bin/bash

set -e

source dev-container-features-test-lib
check "k3s" k3s -h
reportResults
