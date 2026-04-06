<instructions>
Generate artifacts for Claude Code CLI using the constants and format contracts in this adapter.
Tool names are PascalCase and used directly without qualification or prefixes.
MCP tools use the pattern: mcp__<server>__<tool>.
Subagents are stored in .claude/agents/*.md with YAML frontmatter.
Rules are stored in .claude/rules/*.md with optional path-scoped YAML frontmatter.
File imports use @path syntax (e.g., @README.md, @docs/guide.md, @~/.claude/shared-rules.md).
Hooks execute shell commands at lifecycle events and are configured in .claude/settings.json.
Permissions use Tool(specifier) with allow/deny/ask arrays in .claude/settings.json.
Claude Code stores project-scoped MCP servers in .mcp.json at the project root and user/local MCP servers in ~/.claude.json.
Tools in frontmatter are comma-separated strings (e.g., tools: Read, Write, Edit).
You MUST load `guides/subagent-architecture-v1.0.0.guide.md` before authoring coordinator or worker agents.
You MUST treat `.claude/agents/*.md` worker agents as leaf workers because Claude subagents cannot spawn subagents.
You MUST map worker APS `<input>` fields to caller dispatch process args one-for-one.
</instructions>

<constants>
PLATFORM_ID: "claude-code"
DISPLAY_NAME: "Claude Code CLI"
ADAPTER_VERSION: "2.1.0"
LAST_UPDATED: "2026-03-12"

ARTIFACT_TYPES: CSV<<
type,file_pattern,config_format
agent,.claude/agents/*.md,CC_AGENT_FRONTMATTER_V1
rules,.claude/rules/*.md,CC_RULES_FRONTMATTER_V1
hooks,.claude/settings.json,CC_HOOKS_CONFIG_V1
permissions,.claude/settings.json,CC_PERMISSIONS_CONFIG_V1
>>

SUBAGENT_AUTHORING_GUIDE: "guides/subagent-architecture-v1.0.0.guide.md"

SUBAGENT_ARCHITECTURE: JSON<<
{
  "coordinator_role": "Main-thread agent only",
  "worker_role": "Markdown-defined subagent in .claude/agents/*.md",
  "depth_policy": "depth-1-only",
  "documented_limit": "Subagents cannot spawn other subagents.",
  "invocation_tool": "Agent",
  "invocation_aliases": ["Task"],
  "allowlist_surface": "tools: Agent(worker, reviewer)",
  "definition_paths": ["./.claude/agents/*.md", "~/.claude/agents/*.md"],
  "defaults": {
    "model": "inherit when omitted",
    "tools": "inherit all tools when omitted",
    "skills": "do not inherit; list explicitly",
    "permissionMode": "inherits current permission context unless overridden"
  },
  "request_contract_rule": "Author each worker <input> as the public request interface and mirror it in the caller dispatch process args.",
  "response_contract_rule": "Return a typed result and capture it in the caller before the next step.",
  "portability_rule": "Author Claude workers as leaf workers. Keep all platform-specific Agent wiring in the caller dispatch layer."
}
>>

INSTRUCTION_FILE_PATHS: ["./CLAUDE.md", "./.claude/CLAUDE.md", "./.claude/rules/*.md", "./CLAUDE.local.md", "~/.claude/CLAUDE.md", "~/.claude/rules/*.md"]
AGENT_FILE_PATHS: ["./.claude/agents/*.md", "~/.claude/agents/*.md"]
MCP_CONFIG_PATHS: ["./.mcp.json", "~/.claude.json"]
SETTINGS_FILE_PATHS: ["./.claude/settings.json", "./.claude/settings.local.json", "~/.claude/settings.json"]
MEMORY_LOAD_ORDER: [INSTRUCTION_FILE_PATHS, AGENT_FILE_PATHS, MCP_CONFIG_PATHS, SETTINGS_FILE_PATHS]

DETECTION_MARKERS: [".claude", "CLAUDE.md", "CLAUDE.local.md", ".mcp.json", ".claude/settings.json", ".claude/agents", ".claude/rules"]

CONFIG_SCOPES: ["managed", "user", "project", "local"]
SUBAGENT_MEMORY_SCOPES: ["user", "project", "local"]
SUBAGENT_RUN_MODES: ["foreground", "background"]

MEMORY_LEVEL_ENTERPRISE: "Managed by organization admins."
MEMORY_LEVEL_PROJECT: ["./CLAUDE.md", "./.claude/CLAUDE.md"]
MEMORY_LEVEL_RULES: ["./.claude/rules/*.md"]
MEMORY_LEVEL_USER: ["~/.claude/CLAUDE.md", "./CLAUDE.local.md"]
MEMORY_OVERRIDE_ORDER: [MEMORY_LEVEL_ENTERPRISE, MEMORY_LEVEL_PROJECT, MEMORY_LEVEL_RULES, MEMORY_LEVEL_USER]

HOOK_EVENTS: ["PreToolUse", "PostToolUse", "PermissionRequest", "Stop", "SubagentStart", "SubagentStop", "UserPromptSubmit", "SessionStart", "SessionEnd", "PreCompact", "Notification"]
HOOK_CONFIG_PATH: ".claude/settings.json"

TOOL_NAMING_STYLE: "PascalCase"
TOOL_NAMING_QUALIFICATION: "none"
MCP_TOOL_PATTERN: "mcp__<server>__<tool>"
TOOL_FRONTMATTER_SYNTAX: "comma-separated strings (e.g., tools: Read, Write, Edit, Bash)"

TOOLS: CSV<<
name,toolset,risk,side_effects,description,params
Read,filesystem,low,reads,"Read file contents. Supports text, images, PDFs, and notebooks.","[file_path:string:required, offset:integer:optional, limit:integer:optional, pages:string:optional]"
Write,filesystem,medium,writes,"Create or overwrite files. Read first if the file exists. Prefer Edit for localized changes.","[file_path:string:required, content:string:required]"
Edit,filesystem,medium,writes,"Exact string replacement. old_string must be unique unless replace_all is true.","[file_path:string:required, old_string:string:required, new_string:string:required, replace_all:boolean:optional]"
Glob,filesystem,low,reads,"Find files by glob pattern.","[pattern:string:required, path:string:optional]"
Grep,filesystem,low,reads,"Search file contents using regex.","[pattern:string:required, path:string:optional, glob:string:optional, type:string:optional, output_mode:enum(content|files_with_matches|count):optional]"
NotebookEdit,filesystem,medium,writes,"Replace, insert, or delete notebook cells.","[notebook_path:string:required, new_source:string:required, cell_id:string:optional, cell_type:enum(code|markdown):optional, edit_mode:enum(replace|insert|delete):optional]"
Bash,execution,high,executes,"Execute bash commands. Use for git, npm, docker, and test runs.","[command:string:required, description:string:optional, timeout:integer:optional, run_in_background:boolean:optional]"
Agent,execution,medium,mixed,"Launch specialized subagents from a main-thread agent.","[description:string:required, prompt:string:required, subagent_type:string:required, model:enum(sonnet|opus|haiku|inherit):optional, run_in_background:boolean:optional, max_turns:integer:optional]"
Task,execution,medium,mixed,"Deprecated alias for Agent.","[description:string:required, prompt:string:required, subagent_type:string:required, model:enum(sonnet|opus|haiku|inherit):optional, run_in_background:boolean:optional, max_turns:integer:optional]"
TaskOutput,execution,low,reads,"Retrieve output from a running or completed background task.","[task_id:string:required, block:boolean:optional, timeout:integer:optional]"
TaskStop,execution,low,executes,"Stop a running background task by ID.","[task_id:string:required]"
TaskCreate,execution,low,none,"Create a new task in the structured task list.","[subject:string:required, description:string:required, activeForm:string:optional]"
TaskUpdate,execution,low,none,"Update task status, details, or dependencies.","[taskId:string:required, status:enum(pending|in_progress|completed|deleted):optional, subject:string:optional, description:string:optional]"
TaskList,execution,low,reads,"List all structured tasks.",""
TaskGet,execution,low,reads,"Get full details for a structured task.","[taskId:string:required]"
TodoWrite,execution,low,none,"Create and manage structured todo items for session progress.","[subject:string:required, description:string:required, activeForm:string:optional]"
MCPSearch,execution,low,reads,"Search for and load MCP tools.",""
WebFetch,web,medium,network,"Fetch URL content and process it with a prompt.","[url:string:required, prompt:string:required]"
WebSearch,web,medium,network,"Search the web.","[query:string:required, allowed_domains:array:optional, blocked_domains:array:optional]"
AskUserQuestion,interaction,low,none,"Ask the user structured questions.","[questions:array:required]"
Skill,skills,medium,mixed,"Execute a skill within the conversation.","[skill:string:required, args:string:optional]"
EnterPlanMode,planning,low,none,"Transition to plan mode.",""
ExitPlanMode,planning,low,none,"Signal plan completion and request approval.","[allowedPrompts:array:optional, pushToRemote:boolean:optional]"
LSP,code_intelligence,low,reads,"Code intelligence via Language Server Protocol.",""
>>

RECOMMENDED_PLANNER_TOOLS: ["Read", "Glob", "Grep", "WebFetch", "WebSearch", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "AskUserQuestion", "Agent"]
RECOMMENDED_IMPLEMENTER_TOOLS: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "Agent", "NotebookEdit"]

PERMISSION_MODES: ["default", "acceptEdits", "dontAsk", "bypassPermissions", "plan"]
AGENT_MODELS: ["sonnet", "opus", "haiku", "inherit"]

AGENT_VERSIONING: JSON<<
{
  "templates": [
    {
      "path": "templates/.claude/agents/aps-v{major}.{minor}.{patch}.md",
      "current_path": "templates/.claude/agents/aps-v1.2.1.md",
      "frontmatter": {
        "name_pattern": "aps-v{major}-{minor}-{patch}",
        "description_pattern": "Generate APS v{major}.{minor}.{patch} agent files for any platform: load APS skill + target platform adapter, extract intent, then generate+write+lint."
      }
    }
  ]
}
>>

SKILL_AUTHORING_RESOURCES: JSON<<
{
  "guide": "guides/skill-authoring-v1.0.0.guide.md",
  "template": "_template/",
  "build_process": "processes/build-skill.md"
}
>>

DOCS_MEMORY_URL: "https://code.claude.com/docs/en/memory"
DOCS_SETTINGS_URL: "https://code.claude.com/docs/en/settings"
DOCS_HOOKS_URL: "https://code.claude.com/docs/en/hooks"
DOCS_MCP_URL: "https://code.claude.com/docs/en/mcp"
DOCS_TOOLS_URL: "https://code.claude.com/docs/en/cli-reference"
DOCS_SUBAGENTS_URL: "https://code.claude.com/docs/en/sub-agents"
</constants>

<formats>
<format id="CC_AGENT_FRONTMATTER_V1" name="Claude Code Agent Frontmatter" purpose="YAML frontmatter contract for coordinator or worker files in .claude/agents/*.md.">
---
name: <AGENT_NAME>
description: "<AGENT_DESCRIPTION>"
tools: <TOOLS_LIST>
disallowedTools: <DISALLOWED_TOOLS>
model: <MODEL>
permissionMode: <PERMISSION_MODE>
maxTurns: <MAX_TURNS>
skills:
  - <SKILL_NAME>
mcpServers:
  - <MCP_SERVER_NAME>
memory: <MEMORY_SCOPE>
background: <BACKGROUND>
hooks:
  <HOOK_EVENT>:
    - matcher: "<MATCHER_PATTERN>"
      hooks:
        - type: command
          command: "<HOOK_COMMAND>"
---

WHERE:
- <AGENT_DESCRIPTION> is String; single-line double-quoted string that says what the agent does and when to invoke it.
- <AGENT_NAME> is String; regex: ^[a-z][a-z0-9-]{1,63}$; unique across all loaded agents.
- <BACKGROUND> is Boolean; true to always run the worker as a background task.
- <DISALLOWED_TOOLS> is String; comma-separated names from TOOLS; omit if no denylist is needed.
- <HOOK_COMMAND> is String; shell command to execute; receives tool context via environment variables.
- <HOOK_EVENT> is one of HOOK_EVENTS.
- <MATCHER_PATTERN> is String; tool name or regex pattern to match.
- <MAX_TURNS> is Integer; maximum number of agentic turns before the agent stops.
- <MCP_SERVER_NAME> is String; preconfigured MCP server name; repeat or replace the list with inline server objects when needed.
- <MEMORY_SCOPE> is one of SUBAGENT_MEMORY_SCOPES; omit if no persistent memory is needed.
- <MODEL> is one of AGENT_MODELS; omit to inherit the parent model.
- <PERMISSION_MODE> is one of PERMISSION_MODES; omit to inherit the current permission context.
- <SKILL_NAME> is String; skill id to preload into the agent context; omit the list if no skills are needed.
- <TOOLS_LIST> is String; comma-separated PascalCase names from TOOLS. For main-thread coordinators use `Agent` or `Agent(worker, reviewer)`. For leaf workers omit `Agent`.
</format>

<format id="CC_RULES_FRONTMATTER_V1" name="Claude Code Rules Frontmatter" purpose="YAML frontmatter contract for .claude/rules/*.md path-scoped rules.">
---
paths:
  - "<GLOB_PATTERN>"
---

WHERE:
- <GLOB_PATTERN> is String; standard glob syntax such as "src/**/*.ts", "**/*.test.ts", or "docs/**/*.md".
</format>

<format id="CC_HOOKS_CONFIG_V1" name="Claude Code Hooks Config" purpose="JSON structure for hooks in .claude/settings.json.">
{
  "hooks": {
    "<HOOK_EVENT>": [
      {
        "matcher": "<MATCHER_PATTERN>",
        "command": "<HOOK_COMMAND>"
      }
    ]
  }
}

WHERE:
- <HOOK_EVENT> is one of HOOK_EVENTS.
- <MATCHER_PATTERN> is String; tool or agent matcher; omit matcher for unconditional hooks.
- <HOOK_COMMAND> is String; shell command to execute at the lifecycle event.
</format>

<format id="CC_PERMISSIONS_CONFIG_V1" name="Claude Code Permissions Config" purpose="JSON structure for permissions in .claude/settings.json.">
{
  "permissions": {
    "allow": ["<TOOL_NAME>"],
    "deny": ["<TOOL_SPECIFIER>"],
    "ask": ["<TOOL_NAME>"]
  }
}

WHERE:
- <TOOL_NAME> is String; exact PascalCase tool name from TOOLS, for example "Read", "Glob", "Grep", or "Agent(worker)".
- <TOOL_SPECIFIER> is String; tool name with optional argument restriction, for example "Bash(rm -rf *)" or "Agent(my-custom-agent)".
</format>
</formats>
