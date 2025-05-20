
# jnv (jnv)

jnv is designed for navigating JSON, offering an interactive JSON viewer and jq filter editor.

## Description

jnv (JSON Navigator) is a tool designed for navigating and exploring JSON data. It offers an interactive JSON viewer and jq filter editor that makes it easy to browse through complex JSON structures and apply filters to extract specific information. It's particularly useful for working with large JSON files or API responses.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/jnv:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/jnv:1": {}
    }
}
```

Basic usage:

```bash
jnv -h
```
## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of jnv to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/jnv/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
