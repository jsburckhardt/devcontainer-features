# Juan's Devcontainer Features:

set of features I use and I think should be included in the registry.

## Features

This repository contains a _collection_ of Features.

| Name | URL | Description |
| ---  | --- | ---         |
| flux   | https://fluxcd.io/flux/installation/ | Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration |
| notation | https://notaryproject.dev/ | Notation is a CLI project to add signatures as standard items in the registry ecosystem, and to build a set of simple tooling for signing and verifying these signatures. This should be viewed as similar security to checking git commit signatures, although the signatures are generic and can be used for additional purposes. Notation is an implementation of the Notary v2 specifications.|
| crane | https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md | crane is a tool for interacting with remote images and registries.|

### `flux`

Running `flux` inside the built container will print the help menu of flux.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/flux:1": {}
    }
}
```

```bash
$ flux
```

### `notation`

Running `notation` inside the built container will print the help menu of notation.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/notation:1": {}
    }
}
```

```bash
$ notation
```

### `crane`

Running `crane` inside the built container will print the help menu of notation.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jsburckhardt/devcontainer-features/crane:1": {}
    }
}
```

```bash
$ crane
```
