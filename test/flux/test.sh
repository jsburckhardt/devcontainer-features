#!/bin/bash

set -e

source dev-container-features-test-lib
check "flux" flux version
reportResults
