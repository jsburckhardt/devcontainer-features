#!/bin/bash

set -e

source dev-container-features-test-lib
check "spec-kit version" spec-kit version
reportResults