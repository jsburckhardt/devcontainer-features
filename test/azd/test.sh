#!/bin/bash

set -e

source dev-container-features-test-lib
check "azd" azd version
reportResults
