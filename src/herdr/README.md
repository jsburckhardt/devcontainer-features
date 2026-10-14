
# herdr (herdr)

herdr is a fast, cross-platform CLI tool from herdrdev/herdr distributed as a static binary via GitHub releases.

## Example Usage

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/herdr:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of herdr to install (e.g. 'latest' or a specific tag like 'v0.7.3'). | string | latest |
| outsideOfContainer | Use only an external Herdr control API; requires an explicit runtime bind mount. | boolean | false |
| containerSocketPath | Absolute API socket path inside the container in external-client mode. | string | /run/herdr-host/herdr.sock |

## Share one host Herdr server (Linux)

Outside mode installs the same release binary but makes `herdr` a client-only
wrapper. Native API commands use `HERDR_SOCKET_PATH` (or `containerSocketPath`
when unset). Bare `herdr`, server/TUI launch, and session/remote routing are
rejected: no local server is automatically started. Top-level help and version work
without a socket. Default mode remains unchanged.

Use compatible host/container versions. The example pins both to **v0.9.4**,
which supports `agent prompt`; older releases such as v0.7.3 do not.

On the Linux Docker host, install Herdr, then start **one** server:

```bash
install -d -m 700 "$HOME/.local/share/herdr-control"
HERDR_SOCKET_PATH="$HOME/.local/share/herdr-control/herdr.sock" herdr
```

Start each of Repo A, Repo B, and Repo C with this `.devcontainer/devcontainer.json`:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "remoteUser": "vscode",
    "updateRemoteUserUID": true,
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/herdr:1": {
            "version": "v0.9.4",
            "outsideOfContainer": true,
            "containerSocketPath": "/run/herdr-host/herdr.sock"
        }
    },
    "mounts": [
        "source=${localEnv:HOME}/.local/share/herdr-control,target=/run/herdr-host,type=bind,readonly"
    ]
}
```

**The mount is required in addition to the option.** Feature installation runs
during image build; Feature mount metadata is unconditional and cannot
interpolate Feature options. To keep host access explicitly opt-in, this Feature
does not declare an automatic mount or a misleading `hostSocketPath` option.
Configure the host source in `mounts` and the container destination in
`containerSocketPath`. No privileged mode or Docker socket is needed.
`readonly` prevents filesystem modification, **not** API writes.

Mount the **directory**, not the individual socket: Herdr replaces sockets when
restarted, and a file bind mount can retain a stale inode. Create the host
directory before creating/rebuilding containers; keep it in place across server
restarts. This configuration survives container rebuilds.

For an already-running default server, its API socket is
`~/.config/herdr/herdr.sock` (or `$XDG_CONFIG_HOME/herdr/herdr.sock`).
A named session uses `~/.config/herdr/sessions/<name>/herdr.sock`.
Mount the appropriate directory instead, but note that the default config
directory exposes other files. Prefer the dedicated socket directory above.
Do not pass `--session`: it overrides `HERDR_SOCKET_PATH`; choose a session by
mounting its socket. Do not mount only `herdr-client.sock`: that is the separate
binary TUI protocol, not the newline-delimited JSON control API.

### Permissions and troubleshooting

Herdr creates sockets with **0600** permissions. Use a non-root container user
with the same numeric UID as the host socket owner (`id -u`, `ls -ln`).
`updateRemoteUserUID` usually provides this on native Linux with the example
image. A matching GID alone does not grant access. Rootless Docker/user-namespace
mapping may change the effective host UID; check the mapped identity.
Alternatively, the host owner can deliberately grant a narrow user ACL on the
socket and directory, or a controlled group with mode 0660. Reapply socket ACLs
after every server restart. This Feature never changes host ownership or modes
and never grants world access.

* **No Unix socket:** start Herdr on the host, check `mounts` and
  `containerSocketPath`, and rebuild after changing mounts. A directory at the
  socket path usually means the source did not exist when mounting.
* **Permission denied:** verify numeric UID, directory traversal permissions,
  user-namespace mappings, and any host SELinux policy. Do not solve this with
  `chmod 666` or privileged containers.
* **Server not running/connection refused:** the socket may be stale; restart the
  host server and use a directory mount. Native CLI connection failures are
  returned unchanged; the wrapper does not fall back to a container server.
* **Unknown command/protocol error:** align client and server versions and check
  `herdr agent --help`. `herdr api snapshot` is a useful connectivity probe.

### Host-owned agents and cross-repository communication

The socket gives access to existing host-managed terminals; it does **not**
register arbitrary processes in a container. Create three workspaces/panes in
the host Herdr UI, then launch Copilot from each corresponding **host Herdr pane**.
Forward that pane's identity through `devcontainer exec`:

```bash
devcontainer exec --workspace-folder "$HOME/repos/repo-a" \
  env HERDR_ENV=1 HERDR_PANE_ID="$HERDR_PANE_ID" \
      HERDR_WORKSPACE_ID="$HERDR_WORKSPACE_ID" HERDR_TAB_ID="$HERDR_TAB_ID" \
      HERDR_BIN_PATH=/usr/local/bin/herdr \
      HERDR_SOCKET_PATH=/run/herdr-host/herdr.sock \
  copilot
```

Repeat with repo-b and repo-c from their own host panes. Environment variables
are not automatically forwarded by `devcontainer exec`. `HERDR_BIN_PATH` must
refer to the **container** binary, not the host binary. Do not invent pane IDs or
copy one pane's ID into multiple agents.

Host process detection may see only `devcontainer exec`, not the container's
Copilot process. **`HERDR_AGENT=copilot` is not a supported registration
mechanism.** Use Herdr's native reporting/integration support for lifecycle
updates; for example, from the agent's container environment:

```bash
herdr pane report-agent "$HERDR_PANE_ID" \
  --source devcontainer-copilot --agent copilot --state idle --seq 1
herdr agent rename "$HERDR_PANE_ID" backend
```

Give the other panes unique names such as `frontend` and `tests`. The integration
must report real transitions (`working`, `blocked`, `idle`, `unknown`) with
increasing sequence numbers; a one-off report is not automatic status tracking.
After exit, release the report using `herdr pane release-agent "$HERDR_PANE_ID"
--source devcontainer-copilot --agent copilot --seq <next-number>`.
Consult [agent integration](https://herdr.dev/docs/add-herdr-support/)
and [agent automation](https://herdr.dev/docs/agent-automation/) for the installed
version. This Feature does not install a Copilot lifecycle integration.
The host still owns terminal input/output; prompt delivery, status, and
`--wait` depend on correct detection/reporting, not just socket connectivity.
**Copilot limitation in v0.9.4:** Herdr verifies host foreground process identity
before `agent prompt`/`agent send-keys`. A `devcontainer exec` wrapper hides
Copilot's identity, so these commands return `agent_not_ready` despite a state
report. Do not spoof identity to bypass this check. `agent list`, `agent get`,
and `agent read` can still use the reported host pane. Native `pane send-text`
and `pane send-keys` can address it directly, but do not provide `agent prompt`'s
readiness checks/wait semantics. Validate integration with `herdr agent explain`
and `herdr pane process-info`. Fully automated Copilot prompting through
`devcontainer exec` needs upstream Herdr container-wrapper detection support;
this Feature provides connectivity, not that missing integration.

From any of the three containers:

```bash
herdr agent list
herdr agent get backend
herdr agent prompt backend "What API contract are you implementing?" --wait --timeout 120000
herdr agent read backend --source recent --lines 100
```

Use the same host-issued IDs/names everywhere. Repeat in the opposite direction
with `frontend` and `tests` to validate A→B, B→A, A→C, and C→B. Responses are native
terminal output, not a separate mailbox. Agents must be running in their
host-owned panes and have a working status integration for reliable waits.

### Platforms and alternative transport

| Environment | Requirements / limitations |
|---|---|
| Linux, native Docker | Unix directory bind mount and matching UID/explicit ACL. Reference configuration above. |
| Windows, WSL2 | Run the Linux Herdr server and Docker integration in the same WSL distribution; keep the socket on its Linux filesystem, not `/mnt/c`. Native Windows Herdr uses named pipes, which cannot be mounted as a Linux Unix socket. |
| macOS, Docker Desktop | Ordinary file sharing across the VM boundary does not forward a macOS Unix socket listener. Direct mounting is not a supported configuration here. |
| GitHub Codespaces / remote Docker | A local workstation socket is not on the remote Docker host. Direct mounting cannot reach it. A server on the actual Linux Docker host can use the Linux setup. |

Herdr has no native TCP/HTTP listener. Current Herdr supports authenticated SSH
machine commands (`herdr --machine <label> agent list`) after configuring a saved
machine, as well as remote TUI attachment. See
[connecting machines](https://herdr.dev/docs/connecting-machines/).
This is an alternative to investigate for Desktop/Codespaces, **not** a Unix
mount: it needs SSH access, credentials, compatible versions, and separate
machine configuration. This Feature's outside wrapper intentionally rejects
machine/remote routing; use the default Feature mode for native SSH workflows.
No unauthenticated TCP relay is installed or exposed.

### Security

The [socket API](https://herdr.dev/docs/socket-api/) relies on filesystem access
permissions, not per-agent authentication or workspace-scoped authorization.
Treat access as privileged control of **all** workspaces/terminals on that Herdr
server: clients can send keystrokes, execute commands, and read other agents'
output (which may contain secrets). A read-only bind mount does not restrict
these capabilities. The client wrapper is a safety guard, not a sandbox or an
authorization boundary; the installed underlying binary is still accessible.

Grant access only to trusted repositories and agents. Cross-workspace prompt
injection can cause actions outside the originating repository. Copilot's
`--yolo` mode removes approval safeguards and amplifies this risk; the example
deliberately omits it. Use separate Herdr servers for separate trust domains,
least-privilege host users, and explicit human approval for sensitive actions.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/herdr/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
