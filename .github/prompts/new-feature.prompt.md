---
mode: 'agent'
description: 'Implement a new Dev Container Feature in this repository.'
---

# New Devcontainer Feature Generator

## Purpose
Implement a new Dev Container Feature in this repository.

## Invocation Pattern (Human Usage Examples)
- `/new-feature just in @casey/just`
- `/new-feature ripgrep in @BurntSushi/ripgrep`
- `/new-feature mise in @jdx/mise version=2024.7.1`
- `/new-feature protolint in @yoheimuta/protolint checksum=true`

Copilot: Parse the user’s invocation to fill the Variables section below before generating changes.

## Variables (to be derived or defaulted)
Extract from user command or infer:
- FEATURE_ID: Lowercase id (no spaces). Example: `just`, `ripgrep`, `mise`.
- FEATURE_DISPLAY_NAME: Human-friendly (capitalize if appropriate). Example: `Just`, `Ripgrep`.
- SOURCE_REPO: GitHub `owner/name` the binary/tool comes from. Example: `casey/just`.
- BINARY_NAME: Name of the installed executable (often equals FEATURE_ID; override if different).
- REQUESTED_VERSION: Explicit version if user supplied `version=...`; else "latest".
- SUPPORT_CHECKSUM: Boolean if user included `checksum=true`; default false.
- EXTRA_OPTIONS: Optional structured options (e.g. additional feature options) if user appended `opt:key=value` pairs.
- INITIAL_FEATURE_VERSION: Always start at `1.0.0` (Feature’s internal semver, NOT the tool upstream version).
- ARCH_LIST: Default `[x86_64, i686, aarch64, armv7]` (omit unsupported ones if known).
- RELEASE_ASSET_PATTERN: Infer typical asset naming scheme once you inspect the SOURCE_REPO’s latest release assets (handle suffix variations like `linux-x86_64.tar.gz`, `.zip`, plain binary, etc.).

If inference is ambiguous, favor adding commented fallback logic rather than guessing incorrectly.

## High-Level Task
Create a new Feature at `src/FEATURE_ID` that:
1. Installs the tool from GitHub releases (or alternative upstream if tool uses another distribution method).
2. Supports a `version` option (default `"latest"`) resolving to the latest stable release (exclude pre-releases unless user explicitly requests one).
3. Implements multi-architecture support mapping `uname -m` to release asset names.
4. Provides graceful fallback if GitHub API calls fail (e.g. rate limit / firewall) by:
   - Trying API first (`https://api.github.com/repos/SOURCE_REPO/releases/latest`)
   - Falling back to parsing HTML of `https://github.com/SOURCE_REPO/releases/latest` or using a lightweight strategy (document what you did).
5. (Optional) Performs checksum verification if SUPPORT_CHECKSUM is true AND the upstream provides checksums (e.g. `SHA256SUMS` file).
6. Adds tests: basic install + pinned version test; checksum test if applicable.
7. Updates root README to list the feature with usage examples.
8. Integrates tests into existing CI matrix (mirroring the just feature pattern).
9. Uses consistent shell style and safety (`set -euo pipefail`, traps for cleanup).
10. Leaves unrelated files untouched (NO incidental formatting changes, NO kyverno/zarf edits, NO drive-by refactors).

## File/Directory Deliverables
Create:
- `src/FEATURE_ID/devcontainer-feature.json`
- `src/FEATURE_ID/install.sh`
- `test/FEATURE_ID/test.sh`
- `test/_global/FEATURE_ID-specific-version.sh`
update
- `test/_global/all-tools.sh`
- `test/_global/scenarios.json`
- `.github/workflows/test.yaml`

Modify minimally:
- Root `README.md` (add new feature entry & examples)

## devcontainer-feature.json Requirements
- `id`: FEATURE_ID
- `version`: INITIAL_FEATURE_VERSION
- `name`: FEATURE_DISPLAY_NAME
- `description`: Concise summary of what the tool does
- `documentationURL`: Link to this feature’s README
- `options.version`: string, default "latest"
- Add any EXTRA_OPTIONS (preserve ordering)
- `instantiationMode`: "onCreate"

## install.sh Requirements
1. `#!/usr/bin/env bash`
2. `set -euo pipefail`
3. Parse inputs: `VERSION=$VERSION` (from feature option) -> treat "latest" specially.
4. Architecture map example (adjust names per RELEASE_ASSET_PATTERN):
   - `x86_64` or `amd64` -> `x86_64`
   - `aarch64` or `arm64` -> `aarch64`
   - `armv7l` -> `armv7`
   - `i386` or `i686` -> `i686`
5. Resolve version:
   - If VERSION == "latest":
     - Try GitHub API → extract tag_name minus leading `v` if present
     - Fallback to scraping or light pattern detection from releases page HTML
   - Else trust user-supplied
6. Construct download URL (document pattern).
7. Download to temp dir. Use curl with retry/backoff flags similar to just feature style.
8. Extract / move binary:
   - If archive: detect extension (.tar.gz, .zip), extract accordingly.
   - Ensure final binary path: `/usr/local/bin/BINARY_NAME` and `chmod 0755`.
9. (Optional) Checksum:
   - Download checksums file, grep the asset, verify via `sha256sum -c -`
10. Verification:
   - Run `${BINARY_NAME} --version` or fallback command; ensure it prints something containing resolved version if version != "latest".
11. Output a success message.


## CI Integration
- Update workflow to include FEATURE_ID in matrix if that’s how others are integrated.
- Keep ordering logical (append near similar tooling features).
- Avoid reorganizing unrelated entries.

## Commit / PR Conventions
Suggested (may auto-squash):
1. `chore: scaffold FEATURE_ID feature`
2. `feat: implement FEATURE_ID install logic`
3. `test: add tests for FEATURE_ID`
4. `docs: add FEATURE_ID feature documentation`

PR Title:
`feat: add FEATURE_ID devcontainer feature`

PR Body Should Include:
- Summary
- Version handling strategy
- Architecture support
- Checksum support (yes/no)
- Usage examples
- Tests added
- Statement: “No unrelated changes; excludes kyverno/zarf fixes.”

## Constraints & Non-Goals
- Do NOT refactor global scripts.
- Do NOT adjust unrelated workflow triggers.
- Do NOT rename existing features.
- Do NOT remove or reorder existing README content beyond adding new entry.

## Acceptance Criteria
- All new tests pass in CI.
- Feature listed in root README.
- `install.sh` resilient to GitHub API failure with fallback.
- Pinning a version works.
- Latest resolution works.
- No unrelated file diffs (confirm with `git diff` scope).
- If checksum requested and available upstream, verification implemented (skip gracefully if not).

## Output Format Instruction for Copilot
When generating the PR:
1. Create new branch (named `feature/FEATURE_ID`).
2. Add/modify files exactly as specified.
3. Open a pull request with the defined title and body.
4. Include only relevant changes.

## Post-Generation Self-Check (Copilot)
Before finalizing:
- Re-open each new file; ensure placeholders replaced.
- Ensure executable bits on `install.sh` and test scripts.
- Ensure JSON is valid (no trailing commas).
- Ensure shell uses POSIX-compatible constructs (or justify bash usage).
- Verify version extraction logic with both “latest” and pinned flows (mentally or via test design).
- Confirm absence of kyverno/zarf references / modifications.
