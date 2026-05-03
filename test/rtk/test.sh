#!/bin/bash

set -e

source dev-container-features-test-lib
check "rtk" rtk --version
reportResults
