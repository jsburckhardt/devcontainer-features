## Share one host Herdr server (Linux)

With `outsideOfContainer: true`, `herdr` becomes a client-only wrapper around the
release binary. API commands (`agent`, `pane`, `workspace`, `api`, ...) talk to
`HERDR_SOCKET_PATH`, or `containerSocketPath` when unset. Launching the TUI or a
server, and `--session`/`--remote`/`--machine` routing, are rejected. Default
mode is unchanged.

Pin the same Herdr version on host and container. On the Linux Docker host,
start **one** server:

```bash
install -d -m 700 "$HOME/.local/share/herdr-control"
HERDR_SOCKET_PATH="$HOME/.local/share/herdr-control/herdr.sock" herdr
```

In each repository's `.devcontainer/devcontainer.json`:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "remoteUser": "vscode",
    "updateRemoteUserUID": true,
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/herdr:1": {
            "version": "v0.9.4",
            "outsideOfContainer": true
        }
    },
    "mounts": [
        "source=${localEnv:HOME}/.local/share/herdr-control,target=/run/herdr-host,type=bind,readonly"
    ]
}
```

**The mount is required.** Feature mounts cannot depend on options, so the
Feature never mounts host sockets itself. Mount the socket **directory**, not
the socket file: Herdr recreates the socket on restart and a file mount would
keep a stale inode. Create the host directory before building the container.
`readonly` only prevents filesystem changes, not API writes.

### Permissions and troubleshooting

Herdr sockets are mode 0600, so the container user needs the **same numeric UID**
as the host socket owner (`updateRemoteUserUID` usually handles this on Linux;
rootless Docker may remap it). Never `chmod 666` the socket.

* **No Unix socket:** start the host server, check `mounts`, rebuild the container.
* **Permission denied:** compare `id -u` with `ls -ln` on the socket.
* **Connection refused:** the socket is stale; restart the host server.
* **Unknown command:** align host and container Herdr versions.

`herdr api snapshot` is a quick connectivity probe.

### Agents across containers

The socket controls terminals owned by the host server; it does not register
container processes. Run each container's agent from its own host Herdr pane
and forward the pane identity:

```bash
devcontainer exec --workspace-folder "$HOME/repos/repo-a" \
  env HERDR_ENV=1 HERDR_PANE_ID="$HERDR_PANE_ID" \
      HERDR_SOCKET_PATH=/run/herdr-host/herdr.sock copilot
```

Report lifecycle state and name the agent from inside the container, then
other containers can find it and exchange terminal input/output:

```bash
herdr pane report-agent "$HERDR_PANE_ID" --source devcontainer-copilot --agent copilot --state idle --seq 1
herdr agent rename "$HERDR_PANE_ID" backend

# From another container:
herdr agent list
herdr pane run <backend-pane-id> "..."
herdr agent read backend --source recent --lines 100
herdr agent wait backend --until idle --timeout 120000
```

**Limitation:** `herdr agent prompt` and `agent send-keys` return
`agent_not_ready`, because the host pane's foreground process is
`devcontainer exec`, not Copilot. Use `pane run`/`pane send-text` instead; they
skip the readiness checks. Reports must use increasing `--seq` numbers. Release
the agent with `herdr pane release-agent` when it exits. See
[agent integration](https://herdr.dev/docs/add-herdr-support/).

### Platforms

Supported only where the Herdr server and the Docker daemon share a Linux
filesystem: native Linux, or WSL2 with both in the same distribution (not under
`/mnt/c`). Docker Desktop on macOS, native Windows (named pipes), Codespaces and
remote Docker hosts cannot mount a local socket; consider Herdr's SSH
[machine support](https://herdr.dev/docs/connecting-machines/) in default mode.

### Security

Socket access is full control of **every** workspace and terminal on that
server: clients can type commands and read other agents' output, including
secrets. There is no per-agent authorization, and the wrapper is not a sandbox.
Share a server only between trusted repositories, use separate servers for
separate trust domains, and avoid approval-skipping modes such as `--yolo`.
