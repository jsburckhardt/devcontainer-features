#!/bin/bash

set -e

source dev-container-features-test-lib
check "k3d" k3d version
reportResults