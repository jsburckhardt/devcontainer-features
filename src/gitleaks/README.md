
# Gitleaks (gitleaks)

Gitleaks is a SAST tool for detecting and preventing hardcoded secrets like passwords, api keys, and tokens in git repos. Gitleaks is an easy-to-use, all-in-one solution for detecting secrets, past or present, in your code.

## Description

Gitleaks is a SAST (Static Application Security Testing) tool for detecting and preventing hardcoded secrets like passwords, API keys, and tokens in git repositories. It scans your codebase to identify potential security vulnerabilities and helps you keep your sensitive information secure.

## Installation

This feature can be added to your devcontainer by adding it to your `devcontainer.json` file.

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/gitleaks:1": {}
}
```

## Example Usage

```jsonc
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/gitleaks:1": {}
    }
}
```

Basic usage:

```bash
gitleaks
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of gitleaks to install. Accepts versions with 'v' prefix. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/gitleaks/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
