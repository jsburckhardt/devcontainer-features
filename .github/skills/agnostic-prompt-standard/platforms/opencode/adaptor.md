<instructions>
Generate artifacts for the OpenCode agent runtime using the constants in this adapter.
OpenCode uses AGENTS.md and JSONC configuration files.
Configuration supports JSON with comments (JSONC).
</instructions>

<constants>
PLATFORM_ID: "opencode"
DISPLAY_NAME: "OpenCode"
ADAPTER_VERSION: "2.0.0"
LAST_UPDATED: "2026-02-19"

INSTRUCTION_FILE_PATHS: ["AGENTS.md", ".opencode/instructions.md"]
CONFIG_FILE_PATHS: [".opencode/opencode.jsonc", ".opencode/opencode.json", "opencode.json", "opencode.jsonc", ".opencode.json"]

DETECTION_MARKERS: [".opencode", ".opencode/opencode.jsonc", ".opencode/opencode.json", "opencode.json", "opencode.jsonc", ".opencode.json"]

DOCS_OFFICIAL_URL: "https://opencode.ai/docs"
DOCS_CONFIG_URL: "https://opencode.ai/docs/config"
</constants>

<formats>
</formats>
