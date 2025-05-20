
# codex (codex)

A CLI for AI-assisted coding, using OpenAI models to help with programming tasks - chat-driven development with code execution capability. Always installs the latest version.

## Description

Codex CLI is an experimental project that provides AI-assisted coding capabilities. It uses OpenAI models to help with programming tasks through a chat-driven development interface with code execution capability. This tool helps developers write, analyze, and optimize code more efficiently.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/codex:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/codex:1": {}
    }
}
```

Basic usage:

```bash
codex --version
```





---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
