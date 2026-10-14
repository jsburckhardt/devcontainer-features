#!/usr/bin/env bash

set -euo pipefail

fail() {
    echo "Herdr outside-of-container: $*" >&2
    exit 1
}

case "${1:-}" in
    --version|-V|--help|-h)
        [ "$#" -eq 1 ] || fail "Use a single help/version flag, or a native API subcommand."
        exec /usr/local/lib/herdr/herdr "$@"
        ;;
    agent|api|workspace|worktree|tab|pane|notification|wait|status) ;;
    *) fail "Use native API commands such as 'herdr agent list'. Local server/TUI launch is disabled; start Herdr on the host." ;;
esac

# Explicit session selection overrides HERDR_SOCKET_PATH in Herdr.
for arg in "$@"; do
    [ "$arg" != "--" ] || break
    case "$arg" in
        --session|--session=*|--remote|--remote=*|--machine|--machine=*|--no-session)
            fail "Session/remote routing is disabled. Select the host session by mounting its API socket."
            ;;
    esac
done

IFS= read -r configured_socket < /usr/local/share/herdr/socket-path
export HERDR_SOCKET_PATH="${HERDR_SOCKET_PATH:-$configured_socket}"
[[ "$HERDR_SOCKET_PATH" = /* ]] || fail "HERDR_SOCKET_PATH must be an absolute Unix socket path."
[ -S "$HERDR_SOCKET_PATH" ] || fail "No Unix socket at '$HERDR_SOCKET_PATH'. Start the host server and bind mount its socket directory in devcontainer.json. Docker Desktop/native Windows sockets cannot be mounted this way."
[ -w "$HERDR_SOCKET_PATH" ] || fail "Socket '$HERDR_SOCKET_PATH' is not writable by UID $(id -u). Match the host UID or grant a narrow host ACL; do not chmod 666."

exec /usr/local/lib/herdr/herdr "$@"
