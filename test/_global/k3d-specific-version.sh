#!/bin/bash

set -e
source dev-container-features-test-lib
check "k3d with specific version" /bin/bash -c "k3d version | grep '5.6.0'"

reportResults