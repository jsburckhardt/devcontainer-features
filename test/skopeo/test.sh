#!/bin/bash

set -e

source dev-container-features-test-lib
check "skopeo" skopeo --version
reportResults
