
# zarf (zarf)



## Description



## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/zarf:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/zarf:1": {}
    }
}
```

Basic usage:

```bash
zarf
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Zarf to install. Accepts versions with 'v' prefix. | string | latest |
| initfile | flag to download the init package into /tmp folder | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/zarf/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
