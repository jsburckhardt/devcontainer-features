# Juan's Devcontainer Features:

set of features I use and I think should be included in the registry.

## Features

This repository contains a _collection_ of Features.

| Name | URL | Description |
| ---  | --- | ---         |
| flux   | https://fluxcd.io/flux/installation/ | Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration |


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



| skaffold  | https://skaffold.dev | A tool that helps with your development loop. It can continuously build, deploy and even sync files into already running containers whenever you make changes. Combine it with a tool like entr inside the running container and you have a killer combo. |
| kustomize | https://kustomize.io | Helps wrangling your kubernetes YAML manifests into the different shapes you need. Without templates! |
| k9s       | https://k9scli.io/ | A fast, reliable and interactive CLI tool for kubernetes. You'll wonder how you've ever managed without. |
| k3d       | https://k3d.io | Gets your local kubernetes cluster up and running fast! Includes some quality of life features such as a container registry, local path provisioner, load balancer and ingress controller. |

## TODO

- [ ] add shellcheck ci job
- [ ] add full integration test between as much features as possible
- [ ] figure out arm64 github actions ci
