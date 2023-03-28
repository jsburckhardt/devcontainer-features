#!/bin/bash

set -e

source dev-container-features-test-lib
check "cyclonedx" cyclonedx
reportResults
