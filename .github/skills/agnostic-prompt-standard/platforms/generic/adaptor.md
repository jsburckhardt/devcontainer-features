<instructions>
Generate artifacts for tool-agnostic APS usage or for runtimes that use external tools only.
You MUST load `guides/subagent-architecture-v1.0.0.guide.md` before authoring coordinator or worker contracts.
You MUST keep the APS coordinator as the single dispatch owner unless the host documents nested delegation.
You MUST define worker `<input>` as the interface into the worker and mirror it in the caller dispatch process.
You MUST define worker `<format>` outputs and capture them in the caller before the next step.
You MUST isolate host-specific tool or routing names in config files instead of APS process text.
Use this adapter when a host has no stable native tool registry, when tools come only from MCP or an equivalent external declaration file, or when you want one neutral tool layer across hosts.
Do not assume host-specific file names, frontmatter, or native tool naming.
Declare external tools in `predefinedTools.json` with canonical APS tool ids.
If a host exposes decorated runtime names, map them with `config.json` ALIAS entries instead of duplicating tool objects.
</instructions>

<constants>
PLATFORM_ID: "generic"
DISPLAY_NAME: "Generic / External Tools"
ADAPTER_VERSION: "1.1.0"
LAST_UPDATED: "2026-03-12"

SUBAGENT_AUTHORING_GUIDE: "guides/subagent-architecture-v1.0.0.guide.md"

SUBAGENT_ARCHITECTURE: JSON<<
{
  "coordinator_role": "Host-defined or manual APS coordinator",
  "worker_role": "Host-defined, external, or user-mediated worker",
  "depth_policy": "unknown-use-depth-1-by-default",
  "invocation_surface": "host-defined",
  "request_contract_rule": "Define the worker <input> as the public interface and mirror it in the caller dispatch process args.",
  "response_contract_rule": "Define a typed worker result and capture it before the caller continues.",
  "fallback_pattern": "If the host has no native subagent surface, model delegation as explicit APS processes or user-mediated steps."
}
>>

INSTRUCTION_FILE_PATHS: []
DETECTION_MARKERS: []
MCP_CONFIG_PATHS: []
TOOL_SOURCES: ["native", "mcp", "mixed", "none"]
HOST_CAPABILITY_STATES: ["unknown", "depth-1", "nested", "manual"]
EXTERNAL_TOOL_DECLARATION_FILES: ["predefinedTools.json", "config.json"]

DOCS_MCP_URL: "https://modelcontextprotocol.io/specification/2025-06-18/schema"
</constants>

<formats>
<format id="GENERIC_COORDINATOR_WORKER_MAP_V1" name="Generic Coordinator Worker Map" purpose="Document host-neutral worker routing and contract mapping.">
# Generic Coordinator Worker Map

| Worker | Input contract | Invocation surface | Output contract | Notes |
|--------|----------------|--------------------|-----------------|-------|
| <WORKER_NAME> | <INPUT_CONTRACT_ID> | <INVOCATION_SURFACE> | <OUTPUT_CONTRACT_ID> | <NOTES> |

## Caller mapping
<REQUEST_RESPONSE_MAP>

WHERE:
- <INPUT_CONTRACT_ID> is String; worker request contract id or label.
- <INVOCATION_SURFACE> is String; host-defined invocation mechanism or `manual APS process`.
- <NOTES> is String; routing, policy, or fallback notes.
- <OUTPUT_CONTRACT_ID> is String; worker response contract id or label.
- <REQUEST_RESPONSE_MAP> is Markdown; explicit mapping from caller args to worker input and from worker output to caller capture.
- <WORKER_NAME> is String; worker identifier.
</format>
</formats>
