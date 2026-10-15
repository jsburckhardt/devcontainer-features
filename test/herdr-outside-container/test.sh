#!/bin/bash

set -e

source dev-container-features-test-lib

check "herdr-outside-container" herdr --version
check "real binary installed outside PATH" test -x /usr/local/lib/herdr/herdr
check "default socket path configured" grep -qx '/run/herdr-host/herdr.sock' /usr/local/share/herdr/socket-path
# shellcheck disable=SC2016
check "bare herdr is rejected (no local server/TUI)" /bin/bash -c \
    'output=$(herdr 2>&1 </dev/null) && exit 1; [[ "$output" == *"Herdr outside-of-container:"* ]]'
check "no server socket created" test ! -e /run/herdr-host/herdr.sock

reportResults
