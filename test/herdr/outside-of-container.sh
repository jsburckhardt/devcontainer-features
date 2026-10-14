#!/bin/bash

set -e

source dev-container-features-test-lib

SOCKET_DIR="/tmp/herdr-external-test"
mkdir -p "$SOCKET_DIR"
chmod 700 "$SOCKET_DIR"
export HERDR_SOCKET_PATH="$SOCKET_DIR/herdr.sock"

reject() {
    local output
    if output=$(herdr "$@" 2>&1); then
        return 1
    fi
    [[ "$output" == *"Herdr outside-of-container:"* ]]
}

check "CLI installed without a server" herdr --version
check "missing socket diagnostic" reject agent list
check "no local TUI launch" reject
check "no local server launch" reject server
check "no session routing override" reject agent list --session other
check "no launch via version flag" reject --version --no-session
check "no server socket created" test ! -e "$HERDR_SOCKET_PATH"

# A real external API fixture; the public CLI must never start this server.
HERDR_CONFIG_PATH="$SOCKET_DIR/config.toml" /usr/local/lib/herdr/herdr server >"$SOCKET_DIR/server.log" 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true; wait "$server_pid" 2>/dev/null || true; rm -rf "$SOCKET_DIR"' EXIT
for _ in $(seq 1 100); do
    [ ! -S "$HERDR_SOCKET_PATH" ] || break
    sleep 0.1
done

check "real external API connection" herdr api snapshot
check "discover agents through external API" herdr agent list
check "workspace status through external API" herdr workspace list
check "configured socket used without environment override" env -u HERDR_SOCKET_PATH herdr api snapshot

export HERDR_SOCKET_PATH="$SOCKET_DIR/unavailable.sock"
check "runtime socket override diagnostic" reject agent list

reportResults
