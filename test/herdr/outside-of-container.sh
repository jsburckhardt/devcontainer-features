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
SHELL=/bin/bash HERDR_CONFIG_PATH="$SOCKET_DIR/config.toml" /usr/local/lib/herdr/herdr server >"$SOCKET_DIR/server.log" 2>&1 &
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

# Deterministic shell fixtures emulate recognized processes, not real Copilot.
for name in frontend backend; do
    pane=$(herdr workspace create --label "$name" --cwd "$SOCKET_DIR" | jq -er '.result.root_pane.pane_id')
    herdr pane run "$pane" 'exec -a copilot bash --noprofile --norc'
    sleep 0.5
    herdr pane report-agent "$pane" --source test-fixture --agent copilot --state idle --seq 1
    herdr agent rename "$pane" "$name"
done
check "shared agent identifiers" /bin/bash -c 'herdr agent list | jq -e ".result.agents | length == 2"'
check "native prompt delivery" herdr agent prompt backend "echo external-response"
check "reverse native prompt delivery" herdr agent prompt frontend "echo reverse-response"
sleep 1
check "native response retrieval" /bin/bash -c 'herdr agent read backend --source recent --lines 30 | grep -Fx external-response'
check "reverse response retrieval" /bin/bash -c 'herdr agent read frontend --source recent --lines 30 | grep -Fx reverse-response'
# The pane's shell, not this test process, must expand HERDR_PANE_ID.
# shellcheck disable=SC2016
check "native lifecycle wait" herdr agent prompt backend \
    '/usr/local/lib/herdr/herdr pane report-agent "$HERDR_PANE_ID" --source test-fixture --agent copilot --state working --seq 2 >/dev/null; sleep 0.5; /usr/local/lib/herdr/herdr pane report-agent "$HERDR_PANE_ID" --source test-fixture --agent copilot --state idle --seq 3 >/dev/null' \
    --wait --timeout 10000

chmod 755 "$SOCKET_DIR"
# shellcheck disable=SC2016
check "different UID receives a permission diagnostic" /bin/bash -c \
    'output=$(su -s /bin/bash nobody -c "HERDR_SOCKET_PATH=$1 herdr agent list" 2>&1) && exit 1; [[ "$output" == *"not writable by UID"* ]]' \
    _ "$HERDR_SOCKET_PATH"
chmod 700 "$SOCKET_DIR"

export HERDR_SOCKET_PATH="$SOCKET_DIR/unavailable.sock"
check "runtime socket override diagnostic" reject agent list

reportResults
