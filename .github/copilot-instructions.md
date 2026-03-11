<instructions>
You MUST use conventional commit format for all commits.
You MUST use the @new-feature agent when scaffolding a new feature.
You MUST install tools from GitHub releases, not package managers like apt.
You MUST treat skopeo as the sole exception to the GitHub releases rule.
You MUST follow the install.sh pattern in INSTALL_SH_STEPS for new features.
You MUST use dev-container-features-test-lib in test scripts per TEST_PATTERN.
You MUST create all files in DELIVERABLES_CREATE when adding a new feature.
You MUST update all files in DELIVERABLES_UPDATE when adding a new feature.
You MUST NOT modify unrelated files when making changes.
You SHOULD read an existing feature's install.sh as reference before writing a new one.
You SHOULD verify changes pass devcontainer features test before submitting.
</instructions>

<constants>
REPO_DESCRIPTION: "Dev Container Features published to ghcr.io/jsburckhardt/devcontainer-features. Each feature installs a CLI tool into a dev container."

FEATURE_STRUCTURE: TEXT<<
src/<feature-id>/
  devcontainer-feature.json   metadata: id, name, version, description, options
  install.sh                  installer runs as root inside the container
test/<feature-id>/
  test.sh                     basic install validation
test/_global/
  scenarios.json              global test scenarios (all-tools + per-feature version pins)
  all-tools.sh                smoke test verifying every feature binary works
  <feature-id>-specific-version.sh   version-pinned test
>>

CI_WORKFLOWS: YAML<<
- file: ".github/workflows/test.yaml"
  purpose: "Matrix tests each feature against debian:latest, ubuntu:latest, mcr.microsoft.com/devcontainers/base:ubuntu; also runs global scenarios"
- file: ".github/workflows/release.yaml"
  purpose: "Manually triggered; publishes features to GHCR and opens a docs PR"
>>

TEST_PREREQUISITE: "npm install -g @devcontainers/cli"

TEST_COMMANDS: TEXT<<
devcontainer features test -f <feature-id> -i ubuntu:latest
make test-matrix feature=<feature-id>
make test
devcontainer features test --global-scenarios-only --filter <scenario-name> .
>>

INSTALL_SH_STEPS: TEXT<<
1. Shebang: #!/usr/bin/env bash with set -e or set -euo pipefail
2. Root check: exit 1 if $(id -u) is not 0
3. Clean up: rm -rf /var/lib/apt/lists/*
4. check_packages helper: install apt deps if missing
5. Install deps: curl jq ca-certificates tar
6. get_latest_version: query GitHub API /repos/OWNER/REPO/releases/latest
7. Version resolution: if empty or "latest" call get_latest_version
8. Architecture: uname -m with case for x86_64, i686, aarch64, armv7l
9. OS: uname -s mapped to unknown-linux-gnu or apple-darwin
10. Download URL: construct from owner/repo/version/arch/os
11. Temp dir: mktemp -d, cd, curl -sSL, extract
12. Move: mv binary to /usr/local/bin/
13. Cleanup: rm -rf temp dir and apt lists
14. Verify: run binary --version
>>

TEST_PATTERN: TEXT<<
#!/bin/bash
set -e
source dev-container-features-test-lib
check "<label>" <command>
reportResults
>>

VERSION_TEST_PATTERN: TEXT<<
#!/bin/bash
set -e
source dev-container-features-test-lib
check "<feature> with specific version" /bin/bash -c "<binary> --version | grep '<version>'"
reportResults
>>

DELIVERABLES_CREATE: YAML<<
- path: "src/<feature-id>/devcontainer-feature.json"
  purpose: "Feature metadata with id, name, version 1.0.0, description, options.version default latest"
- path: "src/<feature-id>/install.sh"
  purpose: "Installer script following INSTALL_SH_STEPS"
- path: "test/<feature-id>/test.sh"
  purpose: "Basic smoke test"
- path: "test/_global/<feature-id>-specific-version.sh"
  purpose: "Version-pinned test"
>>

DELIVERABLES_UPDATE: YAML<<
- path: "test/_global/all-tools.sh"
  action: "Add a check line for the new binary before reportResults"
- path: "test/_global/scenarios.json"
  action: "Add feature to all-tools.features and add a version-pinned scenario"
- path: ".github/workflows/test.yaml"
  action: "Add feature id to matrix.features array"
- path: "README.md"
  action: "Add row to features table and add usage section"
>>
</constants>
