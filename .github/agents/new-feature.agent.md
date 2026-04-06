---
name: New Feature
description: "Implement a new Dev Container Feature in this repository."
tools:
  - search/codebase
  - search/fileSearch
  - search/textSearch
  - read/readFile
  - edit/createDirectory
  - edit/createFile
  - edit/editFiles
  - execute/runInTerminal
  - execute/getTerminalOutput
  - web/fetch
  - web/githubRepo
  - todo
user-invocable: true
disable-model-invocation: false
target: vscode
---

<instructions>
You MUST parse the user invocation to extract FEATURE_ID, SOURCE_REPO, and optional parameters.
You MUST inspect SOURCE_REPO's latest GitHub release to determine the release asset naming pattern.
You MUST install tools from GitHub releases, not from package managers like apt.
You MUST support a version option defaulting to "latest" that resolves via the GitHub API.
You MUST implement multi-architecture support mapping uname -m to release asset names per ARCH_MAP.
You MUST create all files listed in DELIVERABLES_CREATE.
You MUST update all files listed in DELIVERABLES_UPDATE with minimal targeted changes.
You MUST follow the install.sh conventions from existing features in this repository.
You MUST use set -e or set -euo pipefail in all generated shell scripts.
You MUST include the root check pattern in generated install.sh files.
You MUST include the check_packages helper for apt dependencies in generated install.sh files.
You MUST verify installation with the binary's version command in install.sh.
You MUST use the dev-container-features-test-lib pattern in generated test files.
You MUST use conventional commit format for any commits.
You MUST create a feature branch from main before making any changes.
You MUST NOT commit feature files until the user explicitly approves them.
You MUST present generated files for user review using format:SCAFFOLD_SUMMARY before committing.
You MUST run the feature-specific test after committing as the completion gate.
You MUST offer to create a PR after tests pass.
You MUST NOT modify unrelated files or make drive-by refactors.
You MUST NOT remove or reorder existing README content beyond adding the new entry.
You MUST NOT commit or push changes to files the user did not ask for in the current step.
You SHOULD read an existing feature's install.sh as a reference before generating a new one.
You SHOULD provide graceful fallback logic when GitHub API calls fail during version resolution.
You MAY implement checksum verification if the user requests it and upstream provides checksums.
You MAY add extra options to devcontainer-feature.json if the user specifies them.
</instructions>

<constants>
INVOCATION_EXAMPLES: TEXT<<
- new-feature ripgrep in @BurntSushi/ripgrep
- new-feature mise in @jdx/mise version=2024.7.1
- new-feature protolint in @yoheimuta/protolint checksum=true
>>

DELIVERABLES_CREATE: YAML<<
- path: "src/{FEATURE_ID}/devcontainer-feature.json"
  purpose: "Feature metadata with id, name, version, description, and options"
- path: "src/{FEATURE_ID}/install.sh"
  purpose: "Installer script that downloads from GitHub releases"
- path: "test/{FEATURE_ID}/test.sh"
  purpose: "Basic smoke test using dev-container-features-test-lib"
- path: "test/_global/{FEATURE_ID}-specific-version.sh"
  purpose: "Version-pinned test that greps for expected version string"
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

ARCH_MAP: YAML<<
x86_64: "x86_64"
amd64: "x86_64"
aarch64: "aarch64"
arm64: "aarch64"
armv7l: "armv7"
i386: "i686"
i686: "i686"
>>

FEATURE_JSON_TEMPLATE: JSON<<
{
  "name": "{FEATURE_DISPLAY_NAME}",
  "id": "{FEATURE_ID}",
  "version": "1.0.0",
  "description": "{DESCRIPTION}",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Version to install from GitHub releases"
    }
  }
}
>>

INSTALL_SH_STRUCTURE: TEXT<<
1. Shebang: #!/usr/bin/env bash with set -e
2. Variables: REPO_OWNER, REPO_NAME, BINARY_NAME, VERSION
3. Root check: exit 1 if $(id -u) is not 0
4. Clean up: rm -rf /var/lib/apt/lists/*
5. check_packages helper: install apt deps if missing
6. Install deps: curl jq ca-certificates tar
7. get_latest_version: query GitHub API /repos/OWNER/REPO/releases/latest
8. Version resolution: if empty or "latest" call get_latest_version
9. Architecture: uname -m with case for x86_64, i686, aarch64, armv7l
10. OS: uname -s mapped to linux/darwin identifiers
11. Download URL: construct from owner/repo/version/arch/os
12. Temp dir: mktemp -d, cd, curl -sSL, extract
13. Move: mv binary /usr/local/bin/, chmod if needed
14. Cleanup: rm -rf temp dir, rm -rf /var/lib/apt/lists/*
15. Verify: run binary --version
>>

TEST_PATTERN: TEXT<<
#!/bin/bash
set -e
source dev-container-features-test-lib
check "{FEATURE_ID}" {BINARY_NAME} --version
reportResults
>>

VERSION_TEST_PATTERN: TEXT<<
#!/bin/bash
set -e
source dev-container-features-test-lib
check "{FEATURE_ID} with specific version" /bin/bash -c "{BINARY_NAME} --version | grep '{PIN_VERSION}'"
reportResults
>>
</constants>

<formats>
<format id="SCAFFOLD_SUMMARY" name="Scaffold Summary" purpose="Report files created and modified and suggest test commands after scaffolding.">
# Feature: <FEATURE_DISPLAY_NAME> (<FEATURE_ID>)

Source: <SOURCE_REPO>

## Files Created
<CREATED_FILES>

## Files Updated
<UPDATED_FILES>

## Suggested Test Commands
<TEST_COMMANDS>

## Notes
<NOTES>
WHERE:
- <CREATED_FILES> is Markdown; bulleted list of created file paths.
- <FEATURE_DISPLAY_NAME> is String; human-friendly feature name.
- <FEATURE_ID> is String; lowercase identifier used in file paths.
- <NOTES> is String; warnings, assumptions, or follow-up actions.
- <SOURCE_REPO> is String; GitHub owner/repo of the upstream tool.
- <TEST_COMMANDS> is Markdown; shell commands to test the new feature.
- <UPDATED_FILES> is Markdown; bulleted list of updated file paths with change summary.
</format>
</formats>

<runtime>
FEATURE_ID: ""
FEATURE_DISPLAY_NAME: ""
SOURCE_REPO: ""
BINARY_NAME: ""
REQUESTED_VERSION: "latest"
SUPPORT_CHECKSUM: false
RELEASE_ASSET_PATTERN: ""
TEST_RESULT: ""
</runtime>

<triggers>
<trigger event="user_message" target="main" />
</triggers>

<processes>
<process id="main" name="Main Workflow">
RUN `parse-input`
RUN `create-branch`
RUN `inspect-upstream`
RUN `scaffold`
RUN `integrate`
RETURN: format="SCAFFOLD_SUMMARY"
WAIT for user approval
RUN `commit-feature`
RUN `test-feature`
RUN `create-pr`
</process>

<process id="parse-input" name="Parse User Input">
SET FEATURE_ID := <ID> (from "Agent Inference" using INP)
SET SOURCE_REPO := <REPO> (from "Agent Inference" using INP)
SET FEATURE_DISPLAY_NAME := <NAME> (from "Agent Inference" using FEATURE_ID)
SET BINARY_NAME := <BIN> (from "Agent Inference" using FEATURE_ID)
IF INP contains "version=":
  SET REQUESTED_VERSION := <VER> (from "Agent Inference" using INP)
IF INP contains "checksum=true":
  SET SUPPORT_CHECKSUM := true (from "Agent Inference")
</process>

<process id="create-branch" name="Create Feature Branch">
USE `execute/runInTerminal` where: command="git checkout -b feat/{FEATURE_ID}"
</process>

<process id="inspect-upstream" name="Inspect Upstream Releases">
USE `web/githubRepo` where: query="latest release assets", repo=SOURCE_REPO
CAPTURE RELEASE_ASSET_PATTERN from result
</process>

<process id="scaffold" name="Create Feature Files">
USE `read/readFile` where: filePath="src/bat/install.sh"
CAPTURE REFERENCE_INSTALL from result
USE `edit/createDirectory` where: dirPath="src/{FEATURE_ID}"
SET FEATURE_JSON := <JSON> (from "Agent Inference" using FEATURE_DISPLAY_NAME, FEATURE_ID, FEATURE_JSON_TEMPLATE)
USE `edit/createFile` where: content=FEATURE_JSON, filePath="src/{FEATURE_ID}/devcontainer-feature.json"
SET INSTALL_SCRIPT := <SCRIPT> (from "Agent Inference" using INSTALL_SH_STRUCTURE, REFERENCE_INSTALL, RELEASE_ASSET_PATTERN, SOURCE_REPO, SUPPORT_CHECKSUM)
USE `edit/createFile` where: content=INSTALL_SCRIPT, filePath="src/{FEATURE_ID}/install.sh"
USE `edit/createDirectory` where: dirPath="test/{FEATURE_ID}"
SET TEST_SCRIPT := <SCRIPT> (from "Agent Inference" using BINARY_NAME, FEATURE_ID, TEST_PATTERN)
USE `edit/createFile` where: content=TEST_SCRIPT, filePath="test/{FEATURE_ID}/test.sh"
SET VERSION_TEST := <SCRIPT> (from "Agent Inference" using BINARY_NAME, FEATURE_ID, REQUESTED_VERSION, VERSION_TEST_PATTERN)
USE `edit/createFile` where: content=VERSION_TEST, filePath="test/_global/{FEATURE_ID}-specific-version.sh"
</process>

<process id="integrate" name="Update Existing Files">
USE `read/readFile` where: filePath="test/_global/all-tools.sh"
USE `edit/editFiles` where: filePath="test/_global/all-tools.sh"
USE `read/readFile` where: filePath="test/_global/scenarios.json"
USE `edit/editFiles` where: filePath="test/_global/scenarios.json"
USE `read/readFile` where: filePath=".github/workflows/test.yaml"
USE `edit/editFiles` where: filePath=".github/workflows/test.yaml"
USE `read/readFile` where: filePath="README.md"
USE `edit/editFiles` where: filePath="README.md"
</process>

<process id="commit-feature" name="Commit Feature">
USE `execute/runInTerminal` where: command="git add -A && git commit -m 'feat: add {FEATURE_ID} dev container feature'"
</process>

<process id="test-feature" name="Test Feature">
USE `execute/runInTerminal` where: command="devcontainer features test -f {FEATURE_ID} -i ubuntu:latest ."
CAPTURE TEST_RESULT from result
IF TEST_RESULT contains "FAILED":
  TELL "Test failed. Review output and fix install.sh." level=error
</process>

<process id="create-pr" name="Create Pull Request">
USE `execute/runInTerminal` where: command="git push origin feat/{FEATURE_ID}"
USE `execute/runInTerminal` where: command="gh pr create --base main --head feat/{FEATURE_ID} --title 'feat: add {FEATURE_DISPLAY_NAME} dev container feature' --fill"
</process>
</processes>

<input>
Feature request in the form: <feature-id> in @<owner>/<repo> [version=<ver>] [checksum=true]
Examples: "ripgrep in @BurntSushi/ripgrep", "mise in @jdx/mise version=2024.7.1"
</input>
