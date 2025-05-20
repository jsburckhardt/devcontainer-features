
# uv/uvx (uv)

An extremely fast Python package and project manager, written in Rust. A single tool to replace pip, pip-tools, pipx, poetry, pyenv, virtualenv, and more.

## Description

UV is an extremely fast Python package and project manager, written in Rust. It's designed to be a single tool that can replace pip, pip-tools, pipx, poetry, pyenv, virtualenv, and more. UV offers significant performance improvements over traditional Python package managers and provides a more streamlined workflow for Python development.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/uv:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/uv:1": {}
    }
}
```

Basic usage:

```bash
uv --version
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of UV to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/uv/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
