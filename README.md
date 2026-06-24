# Juan's Devcontainer Features:

[![APS version](https://img.shields.io/github/v/release/chris-buckley/agnostic-prompt-standard?label=APS&logo=github)](https://github.com/chris-buckley/agnostic-prompt-standard/releases/tag/v1.1.16)

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
| ccc | https://github.com/jsburckhardt/co-config | A TUI tool to interactively configure and view GitHub Copilot CLI settings. |
| Yazi | https://github.com/sxyazi/yazi | Blazing fast terminal file manager written in Rust, based on async I/O. |
| tmux | https://github.com/tmux/tmux | tmux is a terminal multiplexer. It lets you switch easily between several programs in one terminal. |
| fzf | https://github.com/junegunn/fzf | A command-line fuzzy finder. |
| lazygit | https://github.com/jesseduffield/lazygit | Simple terminal UI for git commands. |
| ripgrep | https://github.com/BurntSushi/ripgrep | Recursively searches directories for a regex pattern while respecting your gitignore. |
| fd | https://github.com/sharkdp/fd | A simple, fast and user-friendly alternative to 'find'. |
| rtk | https://github.com/rtk-ai/rtk | CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. Single Rust binary, zero dependencies. |
| zoxide | https://github.com/ajeetdsouza/zoxide | A smarter cd command. Supports all major shells. |
| hyperfine | https://github.com/sharkdp/hyperfine | A command-line benchmarking tool. |
| Glow | https://github.com/charmbracelet/glow | Render markdown on the CLI, with pizzazz! 💅🏻 |
| fx | https://github.com/antonmedv/fx | Terminal JSON viewer & processor. |
| hurl | https://github.com/Orange-OpenSource/hurl | Run and test HTTP requests with plain text. |
| MarkItDown | https://github.com/microsoft/markitdown | Convert PDFs, Office docs, images, audio, HTML, CSV/JSON/XML, ZIPs, and more into Markdown from the CLI. |
| ast-grep | https://github.com/ast-grep/ast-grep | Structural code search, linting, and rewriting using AST-aware patterns. |
| mise | https://github.com/jdx/mise | Manage dev tool versions, environment variables, and project tasks in one CLI. |
| jj | https://github.com/jj-vcs/jj | Git-compatible version control with a cleaner workflow for commits, branches, rebasing, and history editing. |
| difftastic | https://github.com/Wilfred/difftastic | Syntax-aware structural diffs that are much easier to read than plain text diffs. |
| delta | https://github.com/dandavison/delta | Better pager for git diff, grep, rg --json, and blame output with syntax highlighting. |
| actionlint | https://github.com/rhysd/actionlint | Static checker for GitHub Actions workflow files. |



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

### `ccc`

Running `ccc` inside the built container will print the version of ccc (Copilot Config CLI).

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/ccc:1": {}
    }
}
```

```bash
ccc --version
```

### `yazi`

Running `yazi --version` inside the built container will print the version of yazi.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/yazi:1": {}
    }
}
```

```bash
yazi --version
```

### `tmux`

Running `tmux -V` inside the built container will print the version of tmux.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/tmux:1": {}
    }
}
```

```bash
tmux -V
```

### `fzf`

Running `fzf --version` inside the built container will print the version of fzf.
### `lazygit`

Running `lazygit --version` inside the built container will print the version of lazygit.
### `ripgrep`

Running `rg --version` inside the built container will print the version of ripgrep.
### `fd`

Running `fd --version` inside the built container will print the version of fd.
### `rtk`

Running `rtk --version` inside the built container will print the version of rtk.
### `zoxide`

Running `zoxide --version` inside the built container will print the version of zoxide.
### `hyperfine`

Running `hyperfine --version` inside the built container will print the version of hyperfine.
### `glow`

Running `glow --version` inside the built container will print the version of glow.
### `fx`

Running `fx --version` inside the built container will print the version of fx.
### `hurl`

Running `hurl --version` inside the built container will print the version of hurl.
### `mise`

Running `mise --version` inside the built container will print the version of mise.
### `difftastic`

Running `difft --version` inside the built container will print the version of difftastic.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/mise:1": {}
        "ghcr.io/jsburckhardt/devcontainer-features/difftastic:1": {}
    }
}
```

```bash
mise --version
```

### `jj`

Running `jj --version` inside the built container will print the version of jj.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/jj:1": {}
    }
}
```

```bash
jj --version
difft --version
```

### `delta`

Running `delta --version` inside the built container will print the version of delta.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/delta:1": {}
    }
}
```

```bash
delta --version
```

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/fzf:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/lazygit:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/ripgrep:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/fd:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/rtk:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/zoxide:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/hyperfine:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/glow:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/fx:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/hurl:1": {},
        "ghcr.io/jsburckhardt/devcontainer-features/jj:1": {}
        "ghcr.io/jsburckhardt/devcontainer-features/delta:1": {}
    }
}
```

```bash
fzf --version
lazygit --version
rg --version
fd --version
rtk --version
zoxide --version
hyperfine --version
glow --version
fx --version
hurl --version
jj --version
delta --version
actionlint --version
```

### `actionlint`

Running `actionlint` inside the built container will check GitHub Actions workflow files.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/actionlint:1": {}
    }
}
```

```bash
actionlint --version
```

### `markitdown`

Running `markitdown --version` inside the built container will print the version of markitdown.
### `ast-grep`

Running `sg --version` inside the built container will print the version of ast-grep.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/markitdown:1": {}
        "ghcr.io/jsburckhardt/devcontainer-features/ast-grep:1": {}
    }
}
```

```bash
markitdown --version
sg --version
```
