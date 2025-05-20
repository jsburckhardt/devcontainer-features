
# flux (flux)

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration

## Description

Flux is a GitOps tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories) and automating updates to configuration when there is new code to deploy. It enables application deployment and continuous delivery by ensuring the cluster state matches the configuration checked into Git.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/flux:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/flux:1": {}
    }
}
```

Basic usage:

```bash
flux
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of flux2 to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/flux/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
