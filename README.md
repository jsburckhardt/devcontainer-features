# Juan's Devcontainer Features:

set of features I use and I think should be included in the registry.

## Features

This repository contains a _collection_ of Features.

| Name | URL | Description |
| ---  | --- | ---         |
| bat | https://github.com/sharkdp/bat | A cat(1) clone with syntax highlighting and Git integration. |
| flux   | https://fluxcd.io/flux/installation/ | Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration |
| notation | https://notaryproject.dev/ | Notation is a CLI project to add signatures as standard items in the registry ecosystem, and to build a set of simple tooling for signing and verifying these signatures. This should be viewed as similar security to checking git commit signatures, although the signatures are generic and can be used for additional purposes. Notation is an implementation of the Notary v2 specifications.|
| crane | https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md | crane is a tool for interacting with remote images and registries.|
| skopeo | https://github.com/containers/skopeo | skopeo is a command line utility that performs various operations on container images and image repositories. It is install through package managers |
| kyverno | https://kyverno.io/docs/introduction/ | Kyverno (Greek for “govern”) is a policy engine designed specifically for Kubernetes. |
| k3d | https://k3d.io/ | K3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in docker. |
| cyclonedx | https://cyclonedx.org/ | cyclonedx is a command-line tool for working with Software Bill of Materials (SBOM). |
| Copacelic | https://project-copacetic.github.io/copacetic/website/ | Project Copacetic: Directly patch container image vulnerabilities. Copa is a CLI tool written in Go and based on buildkit that can be used to directly patch container images given the vulnerability scanning results from popular tools like Trivy. |
| Gic | https://github.com/jsburckhardt/gic | Reducing cognitive load by automating commit message generation, allowing developers to focus on coding instead of crafting messages. |
| Gitleaks | https://gitleaks.io/ | Gitleaks is a SAST tool for detecting and preventing hardcoded secrets like passwords, api keys, and tokens in git repos. Gitleaks is an easy-to-use, all-in-one solution for detecting secrets, past or present, in your code. |
| Zarf | https://zarf.dev/ | Zarf eliminates the complexity of air gap software delivery for Kubernetes clusters and cloud-native workloads using a declarative packaging strategy to support DevSecOps in offline and semi-connected environments. |
| jnv | https://github.com/ynqa/jnv | jnv is designed for navigating JSON, offering an interactive JSON viewer and jq filter editor. |
| just | https://github.com/casey/just | A command runner. Just is a handy way to save and run project-specific commands. |
| UV/UVX | https://docs.astral.sh/uv/ | An extremely fast Python package and project manager, written in Rust. A single tool to replace pip, pip-tools, pipx, poetry, pyenv, virtualenv, and more. |
| Ruff | https://docs.astral.sh/ruff/ | An extremely fast Python linter and code formatter, written in Rust. |
| OpenCode | https://opencode.ai/ | AI coding agent, built for the terminal. An open-source alternative to Claude Code with support for multiple LLM providers. |
| Codex-cli | https://github.com/openai/codex | Codex CLI is an experimental project under active development. |
| inspector | https://github.com/modelcontextprotocol/inspector | The MCP inspector is a developer tool for testing and debugging MCP servers. Includes both CLI and UI modes for interactive debugging. |



### `bat`

Running `bat` inside the built container will print the help menu of bat.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/bat:1": {}
    }
}
```

```bash
bat --version
```

### `flux`

Running `flux` inside the built container will print the help menu of flux.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/flux:1": {}
    }
}
```

```bash
flux
```

### `notation`

Running `notation` inside the built container will print the help menu of notation.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/notation:1": {}
    }
}
```

```bash
notation
```

### `crane`

Running `crane` inside the built container will print the help menu of crane.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/crane:1": {}
    }
}
```

```bash
crane
```

### `skopeo`

Running `skopeo` inside the built container will print the help menu of skopeo.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/skopeo:1": {}
    }
}
```

```bash
skopeo
```

### `kyverno`

Running `kyverno` inside the built container will print the help menu of kyverno.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/kyverno:1": {}
    }
}
```

```bash
kyverno
```

### `cyclonedx cli`

Running `cyclonedx` inside the built container will print the help menu of cyclonedx.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/cyclonedx:1": {}
    }
}
```

```bash
cyclonedx --version
```

### `Copacetic cli`

Running `copa` inside the built container will print the help menu of copa.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/copa:1": {}
    }
}
```

```bash
copa
```

### `Gic`

Running `Gic` inside the built container will print the help menu of gic.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/gic:1": {}
    }
}
```

```bash
gic --version
```

### `Gitleaks`

Running `gitleaks` inside the built container will print the help menu of gitleaks.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/gitleaks:1": {}
    }
}
```

```bash
gitleaks
```

### `Zarf`

Running `zarf` inside the built container will print the help menu of zarf.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/zarf:1": {}
    }
}
```

```bash
zarf
```

### `jnv`

Running `jnv -h` inside the built container will print the help menu of jnv.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/jnv:1": {}
    }
}
```

```bash
jnv -h
```

### `UV/UVX`

Running `uv` or `uvx` inside the built container will print the help menu of uv/uvx.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/uv:1": {}
    }
}
```

```bash
uv --version
```

### `Ruff`

Running `ruff` inside the built container will print the help menu of ruff.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/ruff:1": {}
    }
}
```

```bash
ruff --version
```


### `k3d`

Running `k3d` inside the built container will print the help menu of k3d.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/k3d:1": {}
    }
}
```

```bash
k3d --version
```

### `opencode`

Running `opencode` inside the built container will allow you to use the AI coding agent.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/opencode:1": {}
    }
}
```

```bash
opencode --version
```

### `Codex-CLI`

Running `codex` inside the built container will print the help menu of codex.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/codex:1": {}
    }
}
```

```bash
codex --version
```

### `just`

Running `just` inside the built container will print the help menu of just.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/just:1": {}
    }
}
```

```bash
just --version
```

### `inspector`

Running `inspector` inside the built container will allow you to use the MCP Inspector for debugging MCP servers.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/inspector:1": {}
    }
}
```

```bash
inspector --help
```
