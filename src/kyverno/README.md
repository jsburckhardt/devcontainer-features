
# Kyverno CLI (kyverno)

Kyverno (Greek for "govern") is a policy engine designed specifically for Kubernetes.

## Description

Kyverno is a policy engine designed specifically for Kubernetes. It can validate, mutate, and generate Kubernetes resources. As a Kubernetes native policy engine, Kyverno leverages Kubernetes' admission controllers and can be managed using standard Kubernetes tools. The CLI provides a way to test policies and apply resource configurations from the command line.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/kyverno:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/kyverno:1": {}
    }
}
```

Basic usage:

```bash
kyverno
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of kyverno to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/kyverno/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
