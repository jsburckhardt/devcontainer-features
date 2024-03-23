#!/bin/bash

set -e

source dev-container-features-test-lib
check "jnv" jnv -h
reportResults
