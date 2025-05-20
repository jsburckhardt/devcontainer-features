
# CycloneDX CLI (cyclonedx)

cyclonedx is a command-line tool for working with Software Bill of Materials (SBOM). It can perform various operations on SBOMs, such as analysis, modification, diffing, merging, format conversion, signing and verification.

## Description

CycloneDX is a command-line tool for working with Software Bill of Materials (SBOM). It can perform various operations on SBOMs, such as analysis, modification, diffing, merging, format conversion, signing and verification.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/cyclonedx:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/cyclonedx:1": {}
    }
}
```

Basic usage:

```bash
cyclonedx --version
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of cyclonedx to install. Accepts versions with 'v' prefix. | string | latest |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/cyclonedx/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/cyclonedx/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
