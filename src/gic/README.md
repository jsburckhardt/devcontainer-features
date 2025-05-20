
# gic (gic)

Reducing cognitive load by automating commit message generation, allowing developers to focus on coding instead of crafting messages.

## Description

GIC is a tool that helps developers automating commit message generation, allowing them to focus on coding instead of crafting messages.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/gic:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/gic:1": {}
    }
}
```

Basic usage:

```bash
gic --version
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of GIC to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/gic/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
