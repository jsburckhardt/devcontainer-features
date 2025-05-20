
# skopeo (skopeo)

skopeo is a command line utility that performs various operations on container images and image repositories.

## Description

skopeo is a command line utility that performs various operations on container images and image repositories. It allows you to inspect, copy, delete, and sign container images across different registries without having to pull the entire image locally.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/skopeo:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/skopeo:1": {}
    }
}
```

Basic usage:

```bash
skopeo
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|




---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/skopeo/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
