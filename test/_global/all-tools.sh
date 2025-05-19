#!/bin/bash

set -e
source dev-container-features-test-lib
check "flux" flux version --client
check "notation" notation version
check "crane" crane version
check "skopeo" skopeo --version
check "kyverno" kyverno version
check "cyclonedx" cyclonedx --version
check "gitleaks" gitleaks version
check "gic" gic --version
check "uv" uv --version
check "ruff" ruff --version
check "jnv" jnv -V
check "zarf" zarf version
check "codex" codex --version

reportResults
