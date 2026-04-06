<instructions>
Replace this section with platform-specific generation instructions.
Describe tool naming conventions, file locations, frontmatter rules, and MCP config surfaces when applicable.
Document how a coordinator invokes workers on this host.
Map each worker APS `<input>` field to the caller dispatch args.
If nested delegation is undocumented, default to portable depth-1 authoring.
</instructions>

<constants>
PLATFORM_ID: "your-platform-id"
DISPLAY_NAME: "Your Platform"
ADAPTER_VERSION: "0.2.0"
LAST_UPDATED: "YYYY-MM-DD"

SUBAGENT_AUTHORING_GUIDE: "guides/subagent-architecture-v1.0.0.guide.md"

SUBAGENT_ARCHITECTURE: JSON<<
{
  "coordinator_role": "Describe the coordinator artifact or surface.",
  "worker_role": "Describe the worker artifact or surface.",
  "depth_policy": "host-defined-or-portable-depth-1",
  "documented_limit": "Describe documented nesting limits or say not documented.",
  "invocation_surface": "Describe the tool, command, handoff, or API that invokes the worker.",
  "request_contract_rule": "Worker <input> is the public request interface and the caller mirrors it in dispatch args.",
  "response_contract_rule": "Worker returns a typed result and the caller captures it before the next step.",
  "portability_rule": "Keep host-specific routing in the caller dispatch layer only."
}
>>

INSTRUCTION_FILE_PATHS: [".github/copilot-instructions.md"]
DETECTION_MARKERS: [".github/agents/", "path/to/marker.file"]
MCP_CONFIG_PATHS: []

DOCS_HOME_URL: "https://example.com/docs"
</constants>

<formats>
</formats>
