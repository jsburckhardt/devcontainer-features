# General Instructions

- Ensure any code you produce is correct.
- for commit messages use conventional commit format, e.g. `feat: add new feature`, `fix: correct a bug`, `docs: update documentation`, etc. https://www.conventionalcommits.org/en/v1.0.0/

## New Feature Instructions

When creating a new feature, follow these steps:
- Update the README.md to include the new feature in the list of features.
- Each feature should be implemented under src/feature-name. Include a devcontainer-feature.json and install.sh file.
- The install.sh file should install the package from the source repository. Not using a package manager like apt.
- Each feature should have a test under test/feature-name/test.sh
- Each feature should include a global test under test/_global/feature-name-specific-version.sh if a specific version can be installed.
- Update the ../../test/_global/all-tools.sh to validate the new feature is installed.
- Update the ../../test/_global/scenarios.json to include the new feature.
- include the feature in the workflows
