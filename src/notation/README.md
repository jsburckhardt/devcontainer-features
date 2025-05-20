
# notation (notation)

Notation is a CLI project to add signatures as standard items in the registry ecosystem, and to build a set of simple tooling for signing and verifying these signatures. This should be viewed as similar security to checking git commit signatures, although the signatures are generic and can be used for additional purposes. Notation is an implementation of the Notary v2 specifications

## Description

Notation is a CLI tool developed as part of the Notary v2 project, which is focused on container image signing and verification. It provides a set of simple tools for signing and verifying signatures in container registries, helping to ensure the integrity and authenticity of container images and other artifacts.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/notation:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/notation:1": {}
    }
}
```

Basic usage:

```bash
notation
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of notation to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/notation/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
