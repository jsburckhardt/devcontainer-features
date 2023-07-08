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
check "zarf" zarf version
check "azd" azd version

reportResults
