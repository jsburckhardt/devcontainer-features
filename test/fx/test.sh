#!/bin/bash

set -e

source dev-container-features-test-lib
check "fx" fx --version
reportResults
