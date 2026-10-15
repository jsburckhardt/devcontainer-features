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
check "external server fixture started" test -S "$HERDR_SOCKET_PATH"

check "no local launch via other commands" reject update
check "real external API connection" herdr api snapshot
check "discover agents through external API" herdr agent list
check "workspace status through external API" herdr workspace list
check "configured socket used without environment override" env -u HERDR_SOCKET_PATH herdr api snapshot

# Plain shell panes stand in for host-owned panes running agents via devcontainer exec.
declare -A panes
for name in frontend backend; do
    panes[$name]=$(herdr workspace create --label "$name" --cwd "$SOCKET_DIR" | jq -er '.result.root_pane.pane_id')
    herdr pane report-agent "${panes[$name]}" --source test-fixture --agent copilot --state idle --seq 1 >/dev/null
    herdr agent rename "${panes[$name]}" "$name" >/dev/null
done
check "shared agent identifiers" /bin/bash -c 'herdr agent list | jq -e ".result.agents | length == 2"'

deliver() {
    local name=$1 text=$2
    herdr pane run "${panes[$name]}" "echo $text" >/dev/null &&
        herdr pane wait-output "${panes[$name]}" --regex "(?m)^$text\$" --timeout 10000 >/dev/null &&
        herdr agent read "$name" --source recent --lines 30 | grep -Fqx "$text"
}
check "message delivery and response" deliver backend external-response
check "reverse message delivery and response" deliver frontend reverse-response

# Documented limitation: the pane foreground process is not the reported agent.
check "agent prompt reports agent_not_ready" /bin/bash -c \
    '! output=$(herdr agent prompt backend "echo hi" 2>&1) && [[ "$output" == *agent_not_ready* ]]'

herdr pane report-agent "${panes[backend]}" --source test-fixture --agent copilot --state working --seq 2 >/dev/null
check "lifecycle state wait" herdr agent wait backend --until working --timeout 10000
check "agent release" herdr pane release-agent "${panes[backend]}" --source test-fixture --agent copilot --seq 3

# Removing write access emulates a socket owned by a different host UID.
chmod 400 "$HERDR_SOCKET_PATH"
# shellcheck disable=SC2016
check "unwritable socket receives a permission diagnostic" /bin/bash -c \
    'output=$(herdr agent list 2>&1) && exit 1; [[ "$output" == *"not writable by UID"* ]]'
chmod 600 "$HERDR_SOCKET_PATH"

export HERDR_SOCKET_PATH="$SOCKET_DIR/unavailable.sock"
check "runtime socket override diagnostic" reject agent list

reportResults
