<instructions>
Generate artifacts for VS Code + GitHub Copilot using the constants and format contracts in this adapter.
Tool names use a three-tier naming system: toolSet, qualifiedName (toolSet/camelCaseName), and functionName (snake_case).
In chat, tools are mentioned with # prefix (e.g., #codebase, #problems).
In frontmatter, tools are listed as YAML arrays without # prefix.
Agents are stored in .github/agents/*.agent.md with YAML frontmatter.
Prompt files are stored in .github/prompts/*.prompt.md with YAML frontmatter.
Instructions are in .github/copilot-instructions.md and .github/instructions/*.instructions.md.
Skills are at .github/skills/<skill-id>/SKILL.md.
Workspace MCP servers are configured in .vscode/mcp.json.
Use toolSet name to include all tools in a set, or qualifiedName for individual tools.
The functionName is resolved automatically at runtime.
Generated frontmatter MUST NOT contain YAML comments.
Description MUST be a single-line quoted string (avoid YAML block scalars).
You MUST load `guides/subagent-architecture-v1.0.0.guide.md` before authoring coordinator or worker agents.
You SHOULD treat custom-agent subagents as leaf workers for portable APS authoring because nested delegation is not documented.
You MUST map worker APS `<input>` fields to caller dispatch process args one-for-one.
</instructions>

<constants>
PLATFORM_ID: "vscode-copilot"
DISPLAY_NAME: "VS Code + GitHub Copilot"
ADAPTER_VERSION: "2.1.0"
LAST_UPDATED: "2026-03-12"

ARTIFACT_TYPES: CSV<<
type,scope,file_pattern,frontmatter_format
agent,project,.github/agents/*.agent.md,VSCODE_AGENT_FRONTMATTER_V1
agent,project,.claude/agents/*.md,VSCODE_AGENT_FRONTMATTER_V1
agent,user,~/.copilot/agents/*.agent.md,VSCODE_AGENT_FRONTMATTER_V1
prompt,project,.github/prompts/*.prompt.md,VSCODE_PROMPT_FRONTMATTER_V1
instructions,project,.github/copilot-instructions.md,
scoped-instructions,project,.github/instructions/*.instructions.md,VSCODE_INSTRUCTIONS_FRONTMATTER_V1
skill,project,.github/skills/<skill-id>/SKILL.md,VSCODE_SKILL_FRONTMATTER_V1
skill,personal,~/.copilot/skills/<skill-id>/SKILL.md,VSCODE_SKILL_FRONTMATTER_V1
mcp-config,project,.vscode/mcp.json,
>>

SUBAGENT_AUTHORING_GUIDE: "guides/subagent-architecture-v1.0.0.guide.md"

SUBAGENT_ARCHITECTURE: JSON<<
{
  "coordinator_role": "Main chat agent or prompt that can call agent/runSubagent",
  "worker_role": "Built-in subagent or custom .agent.md agent used as a subagent",
  "depth_policy": "portable-depth-1",
  "documented_limit": "Custom-agent subagents are experimental and nested delegation is not documented.",
  "invocation_tools": ["agent", "runSubagent"],
  "definition_paths": [".github/agents/*.agent.md", ".claude/agents/*.md", "~/.copilot/agents/*.agent.md"],
  "default_inheritance": {
    "agent": "inherits the main agent",
    "model": "inherits the main session unless overridden",
    "tools": "inherits the main session unless overridden"
  },
  "controls": {
    "subagent_allowlist": "agents",
    "visible_in_picker": "user-invocable",
    "subagent_disable": "disable-model-invocation",
    "handoff_chain": "handoffs"
  },
  "request_contract_rule": "Define the worker <input> as the interface and mirror it in the caller dispatch process args.",
  "response_contract_rule": "The worker returns a summary or typed result that the main agent incorporates before continuing.",
  "portability_rule": "Keep coordinator-owned dispatch and leaf workers. Use handoffs for sequential flows."
}
>>

AGENT_FILE_PATHS: [".github/agents/*.agent.md", ".claude/agents/*.md", "~/.copilot/agents/*.agent.md"]
DETECTION_MARKERS: [".github/copilot-instructions.md", ".github/agents", ".claude/agents", ".github/prompts", ".github/instructions", ".github/skills", ".vscode/mcp.json"]

MCP_CONFIG_PATHS: [".vscode/mcp.json"]

TOOL_NAMING_STYLE: "three-tier: toolSet / qualifiedName / functionName"
TOOL_NAMING_QUALIFICATION: "qualifiedName for individual tools, toolSet for all tools in a set"
TOOL_CHAT_MENTION_PREFIX: "#"
TOOL_FRONTMATTER_SYNTAX: "YAML array (no # prefix)"

TOOLS: CSV<<
name,toolset,qualified_name,function_name,mention,risk,side_effects,description
semantic_search,search,search/codebase,semantic_search,#codebase,low,reads,"Search the workspace for relevant code or documentation."
get_changed_files,search,search/changes,get_changed_files,#changes,low,reads,"Get git diffs of current file changes."
list_code_usages,search,search/usages,list_code_usages,#usages,low,reads,"List usages of a function, class, or variable."
file_search,search,search/fileSearch,file_search,#fileSearch,low,reads,"Search for files by glob pattern."
grep_search,search,search/textSearch,grep_search,#textSearch,low,reads,"Fast exact or regex text search."
get_search_view_results,search,search/searchResults,get_search_view_results,#searchResults,low,reads,"Get results from the Search view."
read_file,read,read/readFile,read_file,#readFile,low,reads,"Read contents of a file."
get_errors,read,read/problems,get_errors,#problems,low,reads,"Get compile or lint errors."
terminal_last_command,read,read/terminalLastCommand,terminal_last_command,#terminalLastCommand,low,reads,"Get the last command run in the active terminal."
terminal_selection,read,read/terminalSelection,terminal_selection,#terminalSelection,low,reads,"Get the current terminal selection."
copilot_getNotebookSummary,read,read/notebookSummary,copilot_getNotebookSummary,#notebookSummary,low,reads,"Get notebook cells with metadata."
read_notebook_cell_output,read,read/notebookCellOutput,read_notebook_cell_output,#notebookCellOutput,low,reads,"Read notebook cell output."
create_directory,edit,edit/createDirectory,create_directory,#createDirectory,medium,writes,"Create a directory structure."
create_file,edit,edit/createFile,create_file,#createFile,medium,writes,"Create a new file with content."
replace_string_in_file,edit,edit/editFiles,replace_string_in_file,#editFiles,high,writes,"Replace a unique string in a file."
multi_replace_string_in_file,edit,edit/multiEditFiles,multi_replace_string_in_file,#multiEditFiles,high,writes,"Apply multiple replacements in one call."
edit_notebook_file,edit,edit/editNotebook,edit_notebook_file,#editNotebook,high,writes,"Edit an existing notebook file."
create_new_jupyter_notebook,edit,edit/createNotebook,create_new_jupyter_notebook,#createNotebook,medium,writes,"Create a new notebook."
run_in_terminal,execute,execute/runInTerminal,run_in_terminal,#runInTerminal,high,executes,"Execute shell commands in a persistent terminal."
get_terminal_output,execute,execute/getTerminalOutput,get_terminal_output,#getTerminalOutput,low,reads,"Get terminal command output."
run_task,execute,execute/runTask,run_task,#runTask,high,executes,"Run an existing VS Code task."
create_and_run_task,execute,execute/createAndRunTask,create_and_run_task,#createAndRunTask,high,executes,"Create and run a task."
get_task_output,execute,execute/getTaskOutput,get_task_output,#getTaskOutput,low,reads,"Get task output."
run_notebook_cell,execute,execute/runNotebookCell,run_notebook_cell,#runNotebookCell,high,executes,"Run a notebook cell."
test_failure,execute,execute/testFailure,test_failure,#testFailure,low,reads,"Include test failure information."
fetch_webpage,web,web/fetch,fetch_webpage,#fetch,medium,network,"Fetch main content from web pages."
github_repo,web,web/githubRepo,github_repo,#githubRepo,medium,network,"Search a GitHub repository for source code."
run_vscode_command,vscode,vscode/runCommand,run_vscode_command,#runVscodeCommand,high,mixed,"Run a VS Code command."
vscode_searchExtensions_internal,vscode,vscode/extensions,vscode_searchExtensions_internal,#extensions,low,network,"Browse the VS Code Extensions Marketplace."
install_extension,vscode,vscode/installExtension,install_extension,#installExtension,high,writes,"Install a VS Code extension."
get_project_setup_info,vscode,vscode/getProjectSetupInfo,get_project_setup_info,#getProjectSetupInfo,low,none,"Get project setup info for scaffolding."
open_simple_browser,vscode,vscode/openSimpleBrowser,open_simple_browser,#openSimpleBrowser,medium,none,"Preview a website in Simple Browser."
create_new_workspace,vscode,vscode/newWorkspace,create_new_workspace,#newWorkspace,high,writes,"Create a new workspace structure."
get_vscode_api,vscode,vscode/vscodeAPI,get_vscode_api,#VSCodeAPI,low,none,"Get VS Code API documentation."
runSubagent,agent,agent/runSubagent,runSubagent,#runSubagent,high,mixed,"Launch a new agent for isolated subagent work."
get_selection,,selection,get_selection,#selection,low,reads,"Get the current editor selection."
manage_todo_list,,todo,manage_todo_list,#todo,low,none,"Manage a structured todo list."
>>

RECOMMENDED_PLANNER_TOOLS: ["search/codebase", "search/fileSearch", "search/textSearch", "search/changes", "search/usages", "read/readFile", "read/problems", "todo", "web/fetch", "web/githubRepo"]
RECOMMENDED_IMPLEMENTER_TOOLS: ["search/codebase", "search/fileSearch", "search/textSearch", "read/readFile", "read/problems", "edit/createDirectory", "edit/createFile", "edit/editFiles", "execute/runInTerminal", "execute/getTerminalOutput", "todo", "web/fetch", "web/githubRepo", "agent", "agent/runSubagent"]

AGENT_MODELS: ["Claude Haiku 4.5 (copilot)", "Claude Opus 4.5 (copilot)", "Claude Sonnet 4 (copilot)", "Claude Sonnet 4.5 (copilot)", "Gemini 2.5 Pro (copilot)", "GPT-4.1 (copilot)", "GPT-5 (copilot)", "GPT-5.2 (copilot)"]

AGENT_VERSIONING: JSON<<
{
  "templates": [
    {
      "path": "templates/.github/agents/aps-v{major}.{minor}.{patch}.agent.md",
      "current_path": "templates/.github/agents/aps-v1.2.1.agent.md",
      "frontmatter": {
        "name_pattern": "APS v{major}.{minor}.{patch} Agent",
        "description_pattern": "Generate APS v{major}.{minor}.{patch} .agent.md or .prompt.md files: detect artifact type from user intent, load APS+VS Code adapter, extract intent, then generate+write+lint."
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

DOCS_AGENT_SKILLS_URL: "https://code.visualstudio.com/docs/copilot/customization/agent-skills"
DOCS_PROMPT_FILES_URL: "https://code.visualstudio.com/docs/copilot/customization/prompt-files"
DOCS_MCP_URL: "https://code.visualstudio.com/docs/copilot/reference/mcp-configuration"
DOCS_CUSTOM_AGENTS_URL: "https://code.visualstudio.com/docs/copilot/customization/custom-agents"
DOCS_SUBAGENTS_URL: "https://code.visualstudio.com/docs/copilot/agents/subagents"
DOCS_TOOLS_IN_CHAT_URL: "https://code.visualstudio.com/docs/copilot/chat/chat-tools"
DOCS_TOOLS_REFERENCE_URL: "https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features"
DOCS_CUSTOM_INSTRUCTIONS_URL: "https://code.visualstudio.com/docs/copilot/customization/custom-instructions"
</constants>

<formats>
<format id="VSCODE_AGENT_FRONTMATTER_V1" name="VS Code Agent Frontmatter" purpose="YAML frontmatter contract for .github/agents/*.agent.md custom agent files.">
---
name: <AGENT_NAME>
description: "<AGENT_DESCRIPTION>"
argument-hint: "<ARGUMENT_HINT>"
tools: <TOOLS_ARRAY>
agents: <AGENTS_ARRAY>
model: <MODEL_OR_MODEL_ARRAY>
user-invocable: <USER_INVOCABLE>
disable-model-invocation: <DISABLE_MODEL_INVOCATION>
target: <TARGET>
handoffs:
  - label: "<HANDOFF_LABEL>"
    agent: <HANDOFF_AGENT>
    prompt: "<HANDOFF_PROMPT>"
    send: <HANDOFF_SEND>
    model: <HANDOFF_MODEL>
mcp-servers: <MCP_SERVERS_ARRAY>
---

WHERE:
- <AGENT_DESCRIPTION> is String; single-line double-quoted description shown in chat.
- <AGENT_NAME> is String; custom agent name. If omitted in a real file, the filename is used.
- <AGENTS_ARRAY> is YAML array of agent names, `*`, or `[]`. If present, include `agent` or `agent/runSubagent` in <TOOLS_ARRAY>.
- <ARGUMENT_HINT> is String; optional hint shown in the chat input field.
- <DISABLE_MODEL_INVOCATION> is Boolean; true to prevent this agent from being invoked as a subagent.
- <HANDOFF_AGENT> is String; target agent identifier for the handoff.
- <HANDOFF_LABEL> is String; button label shown after the response completes.
- <HANDOFF_MODEL> is String; qualified model name such as `GPT-5.2 (copilot)`; omit to reuse the current model.
- <HANDOFF_PROMPT> is String; prompt text sent to the next agent.
- <HANDOFF_SEND> is Boolean; true to auto-submit the handoff prompt.
- <MCP_SERVERS_ARRAY> is YAML array of MCP server config objects; only applicable for target `github-copilot`.
- <MODEL_OR_MODEL_ARRAY> is String or YAML array; use qualified model names in the format `Model Name (vendor)`.
- <TARGET> is one of: `vscode`, `github-copilot`; default `vscode`.
- <TOOLS_ARRAY> is YAML array of qualified names or tool set values from TOOLS; no `#` prefix.
- <USER_INVOCABLE> is Boolean; true if the agent appears in the picker.
</format>

<format id="VSCODE_PROMPT_FRONTMATTER_V1" name="VS Code Prompt Frontmatter" purpose="YAML frontmatter contract for .github/prompts/*.prompt.md prompt files.">
---
name: <PROMPT_NAME>
description: "<PROMPT_DESCRIPTION>"
tools: <TOOLS_ARRAY>
---

WHERE:
- <PROMPT_DESCRIPTION> is String; single-line double-quoted description of what the prompt does.
- <PROMPT_NAME> is String; prompt name shown in the UI.
- <TOOLS_ARRAY> is YAML array of qualified names or tool set values from TOOLS. Include `agent` or `agent/runSubagent` when the prompt invokes a subagent.
</format>

<format id="VSCODE_INSTRUCTIONS_FRONTMATTER_V1" name="VS Code Instructions Frontmatter" purpose="YAML frontmatter contract for .github/instructions/*.instructions.md files.">
---
applyTo: "<GLOB_PATTERN>"
description: "<INSTRUCTIONS_DESCRIPTION>"
---

WHERE:
- <GLOB_PATTERN> is String; comma-separated glob patterns such as `**/*.ts,**/*.tsx`.
- <INSTRUCTIONS_DESCRIPTION> is String; single-line double-quoted description of the coding conventions in this file.
</format>

<format id="VSCODE_SKILL_FRONTMATTER_V1" name="VS Code Skill Frontmatter" purpose="YAML frontmatter contract for .github/skills/<id>/SKILL.md files.">
---
name: <SKILL_NAME>
description: "<SKILL_DESCRIPTION>"
---

WHERE:
- <SKILL_DESCRIPTION> is String; single-line double-quoted string so Copilot can auto-load the skill when relevant.
- <SKILL_NAME> is String; lowercase hyphenated skill identifier such as `webapp-testing`.
</format>
</formats>
