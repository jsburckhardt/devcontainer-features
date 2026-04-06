<instructions>
Generate artifacts for the OpenCode agent runtime using the constants and format contracts in this adapter.
You MUST load `guides/subagent-architecture-v1.0.0.guide.md` before authoring primary agents or subagents.
You MUST treat `mode: primary` agents as coordinators and `mode: subagent` agents as workers.
You SHOULD treat OpenCode workers as leaf workers for portable APS authoring because nested delegation is not documented.
You MUST map worker APS `<input>` fields to caller dispatch process args one-for-one.
You MUST keep host-specific `Task` and command `subtask` wiring in the caller dispatch layer.
</instructions>

<constants>
PLATFORM_ID: "opencode"
DISPLAY_NAME: "OpenCode"
ADAPTER_VERSION: "2.1.0"
LAST_UPDATED: "2026-03-12"

ARTIFACT_TYPES: CSV<<
type,scope,file_pattern,config_format
agent,project,.opencode/agents/*.md,OPENCODE_AGENT_FRONTMATTER_V1
agent,user,~/.config/opencode/agents/*.md,OPENCODE_AGENT_FRONTMATTER_V1
config,project,.opencode/opencode.json,OPENCODE_AGENT_CONFIG_JSON_V1
config,project,.opencode/opencode.jsonc,OPENCODE_AGENT_CONFIG_JSON_V1
config,project,opencode.json,OPENCODE_AGENT_CONFIG_JSON_V1
config,project,opencode.jsonc,OPENCODE_AGENT_CONFIG_JSON_V1
>>

SUBAGENT_AUTHORING_GUIDE: "guides/subagent-architecture-v1.0.0.guide.md"

SUBAGENT_ARCHITECTURE: JSON<<
{
  "coordinator_role": "Primary agent",
  "worker_role": "Subagent configured with mode: subagent",
  "depth_policy": "portable-depth-1",
  "documented_limit": "Primary and subagent roles are documented, but nested delegation is not documented.",
  "invocation_tool": "Task",
  "manual_invocation": "@mention",
  "definition_paths": [".opencode/agents/*.md", "~/.config/opencode/agents/*.md"],
  "allowlist_surface": "permission.task",
  "visibility_surface": "hidden",
  "mode_surface": "mode",
  "defaults": {
    "model": "subagent inherits the invoking primary model when omitted",
    "todo_tools": "todoread and todowrite are disabled for subagents by default"
  },
  "request_contract_rule": "Define the worker <input> as the public request interface and mirror it in the caller dispatch process args.",
  "response_contract_rule": "Return a typed or tightly bounded result and capture it in the primary process before the next step.",
  "command_rule": "If a command targets a subagent it triggers a subagent invocation by default. Use subtask:true to force subagent invocation."
}
>>

INSTRUCTION_FILE_PATHS: ["AGENTS.md", ".opencode/instructions.md"]
AGENT_FILE_PATHS: [".opencode/agents/*.md", "~/.config/opencode/agents/*.md"]
CONFIG_FILE_PATHS: [".opencode/opencode.json", ".opencode/opencode.jsonc", "opencode.json", "opencode.jsonc", ".opencode.json"]
MCP_CONFIG_PATHS: [".opencode/opencode.json", ".opencode/opencode.jsonc", "opencode.json", "opencode.jsonc", ".opencode.json"]
DETECTION_MARKERS: [".opencode", ".opencode/agents", ".opencode/opencode.json", ".opencode/opencode.jsonc", "opencode.json", "opencode.jsonc", ".opencode.json"]

AGENT_MODES: ["primary", "subagent", "all"]
COMMAND_SUBTASK_RULE: "If a command sets agent to a subagent, it triggers subagent invocation by default. Use subtask:false to disable. Use subtask:true to force subagent invocation."
SUBAGENT_TODO_DEFAULT: "todoread and todowrite are disabled for subagents by default."

DOCS_OFFICIAL_URL: "https://opencode.ai/docs"
DOCS_AGENTS_URL: "https://opencode.ai/docs/agents/"
DOCS_COMMANDS_URL: "https://opencode.ai/docs/commands/"
DOCS_PERMISSIONS_URL: "https://opencode.ai/docs/permissions/"
DOCS_TOOLS_URL: "https://opencode.ai/docs/tools/"
DOCS_MCP_URL: "https://opencode.ai/docs/mcp-servers/"
</constants>

<formats>
<format id="OPENCODE_AGENT_FRONTMATTER_V1" name="OpenCode Agent Frontmatter" purpose="YAML frontmatter contract for markdown agent files in .opencode/agents/*.md or ~/.config/opencode/agents/*.md.">
---
description: <DESCRIPTION>
mode: <MODE>
model: <MODEL>
temperature: <TEMPERATURE>
steps: <STEPS>
tools:
  <TOOL_NAME>: <TOOL_ENABLED>
permission:
  <PERMISSION_NAME>: <PERMISSION_VALUE>
  task:
    "<AGENT_GLOB>": <TASK_PERMISSION>
hidden: <HIDDEN>
disable: <DISABLE>
---

WHERE:
- <AGENT_GLOB> is String; glob pattern matched against subagent names in permission.task.
- <DESCRIPTION> is String; required description of what the agent does and when to use it.
- <DISABLE> is Boolean; true to disable the agent.
- <HIDDEN> is Boolean; only applicable to mode `subagent`; hides the worker from `@` autocomplete.
- <MODE> is one of AGENT_MODES.
- <MODEL> is String; provider/model-id. Omit it on workers to inherit the invoking primary model.
- <PERMISSION_NAME> is String; permission key such as `edit`, `bash`, `webfetch`, `todoread`, or `todowrite`.
- <PERMISSION_VALUE> is String; one of `allow`, `ask`, or `deny`.
- <STEPS> is Integer; maximum number of agentic steps; prefer `steps` over the deprecated `maxSteps`.
- <TASK_PERMISSION> is String; one of `allow`, `ask`, or `deny`.
- <TEMPERATURE> is Number; typical range 0.0 to 1.0.
- <TOOL_ENABLED> is Boolean; true or false.
- <TOOL_NAME> is String; tool id or wildcard such as `write`, `edit`, `bash`, or `mymcp_*`.
- The markdown filename becomes the agent name.
</format>

<format id="OPENCODE_AGENT_CONFIG_JSON_V1" name="OpenCode Agent Config JSON" purpose="JSON fragment for agent configuration in opencode.json or opencode.jsonc.">
{
  "agent": {
    "<AGENT_NAME>": {
      "description": "<DESCRIPTION>",
      "mode": "<MODE>",
      "model": "<MODEL>",
      "steps": <STEPS>,
      "tools": {
        "<TOOL_NAME>": <TOOL_ENABLED>
      },
      "permission": {
        "<PERMISSION_NAME>": "<PERMISSION_VALUE>",
        "task": {
          "<AGENT_GLOB>": "<TASK_PERMISSION>"
        }
      },
      "hidden": <HIDDEN>,
      "disable": <DISABLE>
    }
  }
}

WHERE:
- <AGENT_GLOB> is String; glob pattern matched against subagent names in permission.task.
- <AGENT_NAME> is String; agent id.
- <DESCRIPTION> is String; required description of what the agent does and when to use it.
- <DISABLE> is Boolean; true to disable the agent.
- <HIDDEN> is Boolean; only applies to mode `subagent`.
- <MODE> is one of AGENT_MODES.
- <MODEL> is String; provider/model-id.
- <PERMISSION_NAME> is String; permission key such as `edit`, `bash`, or `webfetch`.
- <PERMISSION_VALUE> is String; one of `allow`, `ask`, or `deny`.
- <STEPS> is Integer; maximum number of agentic steps.
- <TASK_PERMISSION> is String; one of `allow`, `ask`, or `deny`.
- <TOOL_ENABLED> is Boolean; true or false.
- <TOOL_NAME> is String; tool id or wildcard pattern.
</format>

<format id="OPENCODE_COMMAND_CONFIG_JSON_V1" name="OpenCode Command Config JSON" purpose="JSON fragment for command-driven subagent routing in opencode.json or opencode.jsonc.">
{
  "command": {
    "<COMMAND_NAME>": {
      "agent": "<AGENT_NAME>",
      "subtask": <SUBTASK>,
      "model": "<MODEL>"
    }
  }
}

WHERE:
- <AGENT_NAME> is String; agent id that executes the command.
- <COMMAND_NAME> is String; command id.
- <MODEL> is String; optional model override for the command execution.
- <SUBTASK> is Boolean; true to force subagent invocation and isolate context.
</format>
</formats>
