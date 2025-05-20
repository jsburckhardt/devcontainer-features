
# Copacetic CLI (copa)

Project Copacetic: Directly patch container image vulnerabilities. Copa is a CLI tool written in Go and based on buildkit that can be used to directly patch container images given the vulnerability scanning results from popular tools like Trivy.

## Description

Project Copacetic is a tool for directly patching container image vulnerabilities. Copa is a CLI tool written in Go and based on buildkit that can be used to directly patch container images given the vulnerability scanning results from popular tools like Trivy. It helps you address security vulnerabilities in container images without needing to rebuild them from scratch.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/copa:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/copa:1": {}
    }
}
```

Basic usage:

```bash
copa
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|




---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/copa/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
