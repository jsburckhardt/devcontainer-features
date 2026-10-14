#!/bin/bash

set -e

source dev-container-features-test-lib

check "herdr" herdr --version
check "default installation is not wrapped" test ! -e /usr/local/share/herdr/socket-path

reportResults
