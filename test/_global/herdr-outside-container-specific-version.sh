#!/bin/bash

set -e

source dev-container-features-test-lib

check "herdr-outside-container with specific version" /bin/bash -c "herdr --version | grep '0.9.4'"

reportResults
