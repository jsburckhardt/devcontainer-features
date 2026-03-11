<instructions>
Generate artifacts for Claude Code CLI using the constants and format contracts in this adapter.
Tool names are PascalCase and used directly without qualification or prefixes.
MCP tools use the pattern: mcp__<server>__<tool>.
Subagents are stored in .claude/agents/*.md with YAML frontmatter.
Rules are stored in .claude/rules/*.md with optional path-scoped YAML frontmatter.
File imports use @path syntax (e.g., @README.md, @docs/guide.md, @~/.claude/shared-rules.md).
Hooks execute shell commands at lifecycle events and are configured in .claude/settings.json.
Permissions use Tool(specifier) with allow/deny/ask arrays in .claude/settings.json.
Tools in frontmatter are comma-separated strings (e.g., tools: Read, Write, Edit).
</instructions>

<constants>
PLATFORM_ID: "claude-code"
DISPLAY_NAME: "Claude Code CLI"
ADAPTER_VERSION: "2.0.0"
LAST_UPDATED: "2026-02-19"

INSTRUCTION_FILE_PATHS: ["./CLAUDE.md", "./.claude/CLAUDE.md", "./.claude/rules/*.md", "./CLAUDE.local.md", "~/.claude/CLAUDE.md", "~/.claude/rules/*.md"]
AGENT_FILE_PATHS: ["./.claude/agents/*.md", "~/.claude/agents/*.md"]
MCP_CONFIG_PATHS: ["./.mcp.json"]
SETTINGS_FILE_PATHS: ["./.claude/settings.json", "./.claude/settings.local.json", "~/.claude/settings.json"]
MEMORY_LOAD_ORDER: [INSTRUCTION_FILE_PATHS, AGENT_FILE_PATHS, MCP_CONFIG_PATHS, SETTINGS_FILE_PATHS]

DETECTION_MARKERS: [".claude", "CLAUDE.md", "CLAUDE.local.md", ".mcp.json", ".claude/settings.json", ".claude/agents", ".claude/rules"]

MEMORY_LEVEL_ENTERPRISE: "Managed by organization admins."
MEMORY_LEVEL_PROJECT: ["./CLAUDE.md", "./.claude/CLAUDE.md"]
MEMORY_LEVEL_RULES: ["./.claude/rules/*.md"]
MEMORY_LEVEL_USER: ["~/.claude/CLAUDE.md", "./CLAUDE.local.md"]
MEMORY_OVERRIDE_ORDER: [MEMORY_LEVEL_ENTERPRISE, MEMORY_LEVEL_PROJECT, MEMORY_LEVEL_RULES, MEMORY_LEVEL_USER]

HOOK_EVENTS: ["PreToolUse", "PostToolUse", "PermissionRequest", "Stop", "SubagentStop", "UserPromptSubmit", "SessionStart", "SessionEnd", "PreCompact", "Notification"]
HOOK_CONFIG_PATH: ".claude/settings.json"

TOOL_NAMING_STYLE: "PascalCase"
TOOL_NAMING_QUALIFICATION: "none"
MCP_TOOL_PATTERN: "mcp__<server>__<tool>"
TOOL_FRONTMATTER_SYNTAX: "comma-separated strings (e.g., tools: Read, Write, Edit, Bash)"

TOOLS: CSV<<
name,toolset,risk,side_effects,description,params
Read,filesystem,low,reads,"Read file contents. Supports text/images/PDFs/notebooks.","[file_path:string:required, offset:integer:optional, limit:integer:optional, pages:string:optional]"
Write,filesystem,medium,writes,"Create or overwrite files. Read first if exists. Prefer Edit.","[file_path:string:required, content:string:required]"
Edit,filesystem,medium,writes,"Exact string replacement. old_string must be unique.","[file_path:string:required, old_string:string:required, new_string:string:required, replace_all:boolean:optional]"
Glob,filesystem,low,reads,"Find files by glob pattern. Returns paths sorted by modification time.","[pattern:string:required, path:string:optional]"
Grep,filesystem,low,reads,"Search file contents using regex (ripgrep). Use glob/type for filtering.","[pattern:string:required, path:string:optional, glob:string:optional, type:string:optional, output_mode:enum(content|files_with_matches|count):optional]"
NotebookEdit,filesystem,medium,writes,"Replace/insert/delete cells in Jupyter notebooks.","[notebook_path:string:required, new_source:string:required, cell_id:string:optional, cell_type:enum(code|markdown):optional, edit_mode:enum(replace|insert|delete):optional]"
Bash,execution,high,executes,"Execute bash commands. Use for git/npm/docker. Avoid for file ops.","[command:string:required, description:string:optional, timeout:integer:optional, run_in_background:boolean:optional]"
Task,execution,medium,mixed,"Launch specialized subagents for complex multi-step tasks.","[description:string:required, prompt:string:required, subagent_type:string:required, model:enum(sonnet|opus|haiku):optional, run_in_background:boolean:optional, max_turns:integer:optional]"
TaskOutput,execution,low,reads,"Retrieve output from running or completed background task.","[task_id:string:required, block:boolean:optional, timeout:integer:optional]"
TaskStop,execution,low,executes,"Stop a running background task by ID.","[task_id:string:required]"
TaskCreate,execution,low,none,"Create a new task in the structured task list.","[subject:string:required, description:string:required, activeForm:string:optional]"
TaskUpdate,execution,low,none,"Update task status/details/dependencies.","[taskId:string:required, status:enum(pending|in_progress|completed|deleted):optional, subject:string:optional, description:string:optional]"
TaskList,execution,low,reads,"List all tasks with status and dependencies.",""
TaskGet,execution,low,reads,"Get full details of a specific task by ID.","[taskId:string:required]"
TodoWrite,execution,low,none,"Create and manage structured task/todo items for tracking session progress.","[subject:string:required, description:string:required, activeForm:string:optional]"
MCPSearch,execution,low,reads,"Search for and load MCP tools. Requires MCP servers configured.",""
WebFetch,web,medium,network,"Fetch URL content and process with prompt. 15-min cache. Fails for auth URLs.","[url:string:required, prompt:string:required]"
WebSearch,web,medium,network,"Search the web. Must include Sources section with URLs.","[query:string:required, allowed_domains:array:optional, blocked_domains:array:optional]"
AskUserQuestion,interaction,low,none,"Ask user questions. 1-4 questions with 2-4 options each.","[questions:array:required]"
Skill,skills,medium,mixed,"Execute a skill (slash command) within the conversation.","[skill:string:required, args:string:optional]"
EnterPlanMode,planning,low,none,"Transition to plan mode for implementation approaches.",""
ExitPlanMode,planning,low,none,"Signal plan completion and request user approval.","[allowedPrompts:array:optional, pushToRemote:boolean:optional]"
LSP,code_intelligence,low,reads,"Code intelligence via Language Server Protocol. IDE-only.",""
>>

RECOMMENDED_PLANNER_TOOLS: ["Read", "Glob", "Grep", "WebFetch", "WebSearch", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "AskUserQuestion", "Task"]
RECOMMENDED_IMPLEMENTER_TOOLS: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "Task", "NotebookEdit"]

PERMISSION_MODES: ["default", "acceptEdits", "dontAsk", "bypassPermissions", "plan"]
AGENT_MODELS: ["sonnet", "opus", "haiku", "inherit"]

AGENT_VERSIONING: JSON<<
{
  "templates": [
    {
      "path": "templates/.claude/agents/aps-v{major}.{minor}.{patch}.md",
      "current_path": "templates/.claude/agents/aps-v1.1.16.md",
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

DOCS_MEMORY_URL: "https://docs.anthropic.com/en/docs/claude-code/memory"
DOCS_SETTINGS_URL: "https://docs.anthropic.com/en/docs/claude-code/settings"
DOCS_HOOKS_URL: "https://docs.anthropic.com/en/docs/claude-code/hooks"
DOCS_MCP_URL: "https://docs.anthropic.com/en/docs/claude-code/mcp"
DOCS_TOOLS_URL: "https://docs.anthropic.com/en/docs/claude-code/cli-reference"
DOCS_SUBAGENTS_URL: "https://docs.anthropic.com/en/docs/claude-code/sub-agents"
</constants>

<formats>
<format id="CC_AGENT_FRONTMATTER_V1" name="Claude Code Agent Frontmatter" purpose="YAML frontmatter contract for .claude/agents/*.md subagent files.">
---
name: <AGENT_NAME>
description: "<AGENT_DESCRIPTION>"
model: <MODEL>
tools: <TOOLS_LIST>
disallowedTools: <DISALLOWED_TOOLS>
permissionMode: <PERMISSION_MODE>
skills: <SKILLS>
hooks:
  <HOOK_EVENT>:
    - matcher: "<MATCHER_PATTERN>"
      hooks:
        - type: command
          command: "<HOOK_COMMAND>"
---

WHERE:
- <AGENT_NAME> is String; regex: ^[a-z][a-z0-9-]{1,63}$; unique across all loaded subagents.
- <AGENT_DESCRIPTION> is String; describes what the subagent does and when to invoke it.
- <MODEL> is one of AGENT_MODELS; default inherit; omit to use default.
- <TOOLS_LIST> is String; comma-separated names from TOOLS; omit if no allowlist needed.
- <DISALLOWED_TOOLS> is String; comma-separated names from TOOLS; omit if no denylist needed.
- <PERMISSION_MODE> is one of PERMISSION_MODES; default default; omit to use default.
- <SKILLS> is String; comma-separated skill names; omit if no skills needed.
- <HOOK_EVENT> is one of: "PreToolUse", "PostToolUse", "Stop"; subset of HOOK_EVENTS.
- <MATCHER_PATTERN> is String; tool name to match (e.g., "Bash", "Write").
- <HOOK_COMMAND> is String; shell command to execute; receives tool context via environment variables.
</format>

<format id="CC_RULES_FRONTMATTER_V1" name="Claude Code Rules Frontmatter" purpose="YAML frontmatter contract for .claude/rules/*.md path-scoped rules.">
---
paths:
  - "<GLOB_PATTERN>"
---

WHERE:
- <GLOB_PATTERN> is String; standard glob syntax (e.g., "src/**/*.ts", "**/*.test.ts", "docs/**/*.md"); ** for recursive matching, * for single directory.
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
- <MATCHER_PATTERN> is String; tool name to match (e.g., "Bash"); omit matcher for unconditional hooks.
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
- <TOOL_NAME> is String; exact tool name from TOOLS (e.g., "Read", "Glob", "Grep").
- <TOOL_SPECIFIER> is String; tool name with optional argument restriction (e.g., "Bash(rm -rf *)").
</format>
</formats>
