
# zarf (zarf)

Zarf eliminates the complexity of air gap software delivery for Kubernetes clusters and cloud native workloads using a declarative packaging strategy to support DevSecOps in offline and semi-connected environments

## Example Usage

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/zarf:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Zarf to install. Accepts versions with 'v' prefix. | string | latest |
| initfile | flag to download the init package into /tmp folder | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jsburckhardt/devcontainer-features/blob/main/src/zarf/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
