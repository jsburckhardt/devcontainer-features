
# crane (crane)

crane is a tool for interacting with remote images and registries.

## Description

crane is a tool for interacting with remote container images and registries. It provides simple and powerful commands for working with container images, including pushing, pulling, copying, and inspecting container images.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/crane:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/crane:1": {}
    }
}
```

Basic usage:

```bash
crane
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of crane to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/crane/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
