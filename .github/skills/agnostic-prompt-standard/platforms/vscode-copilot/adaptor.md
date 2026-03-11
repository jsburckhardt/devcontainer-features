<instructions>
Generate artifacts for VS Code + GitHub Copilot using the constants and format contracts in this adapter.
Tool names use a three-tier naming system: toolSet, qualifiedName (toolSet/camelCaseName), and functionName (snake_case).
In chat, tools are mentioned with # prefix (e.g., #codebase, #problems).
In frontmatter, tools are listed as YAML arrays without # prefix.
Agents are stored in .github/agents/*.agent.md with YAML frontmatter.
Prompt files are stored in .github/prompts/*.prompt.md with YAML frontmatter.
Instructions are in .github/copilot-instructions.md and .github/instructions/*.instructions.md.
Skills are at .github/skills/<skill-id>/SKILL.md.
Use toolSet name to include all tools in a set, or qualifiedName for individual tools.
The functionName is resolved automatically at runtime.
Generated frontmatter MUST NOT contain YAML comments.
Description MUST be a single-line quoted string (avoid YAML block scalars).
</instructions>

<constants>
PLATFORM_ID: "vscode-copilot"
DISPLAY_NAME: "VS Code + GitHub Copilot"
ADAPTER_VERSION: "2.0.0"
LAST_UPDATED: "2026-02-19"

INSTRUCTION_FILE_PATHS: [".github/copilot-instructions.md", ".github/instructions/*.instructions.md"]
AGENT_FILE_PATHS: [".github/agents/*.agent.md"]
PROMPT_FILE_PATHS: [".github/prompts/*.prompt.md"]
SKILL_FILE_PATHS: [".github/skills/<skill-id>/SKILL.md", "~/.copilot/skills/<skill-id>/SKILL.md"]

DETECTION_MARKERS: [".github/copilot-instructions.md", ".github/agents", ".github/prompts", ".github/instructions", ".github/skills"]

TOOL_NAMING_STYLE: "three-tier: toolSet / qualifiedName / functionName"
TOOL_NAMING_QUALIFICATION: "qualifiedName for individual tools, toolSet for all tools in a set"
TOOL_CHAT_MENTION_PREFIX: "#"
TOOL_FRONTMATTER_SYNTAX: "YAML array (no # prefix)"

TOOLS: CSV<<
name,toolset,qualified_name,function_name,mention,risk,side_effects,description
semantic_search,search,search/codebase,semantic_search,#codebase,low,reads,"Search workspace for relevant code or documentation."
get_changed_files,search,search/changes,get_changed_files,#changes,low,reads,"Get git diffs of current file changes."
list_code_usages,search,search/usages,list_code_usages,#usages,low,reads,"List usages of a function/class/variable."
file_search,search,search/fileSearch,file_search,#fileSearch,low,reads,"Search for files by glob pattern."
grep_search,search,search/textSearch,grep_search,#textSearch,low,reads,"Fast text search with exact string or regex."
get_search_view_results,search,search/searchResults,get_search_view_results,#searchResults,low,reads,"Get results from the Search view."
read_file,read,read/readFile,read_file,#readFile,low,reads,"Read contents of a file (1-indexed line range)."
get_errors,read,read/problems,get_errors,#problems,low,reads,"Get compile or lint errors."
terminal_last_command,read,read/terminalLastCommand,terminal_last_command,#terminalLastCommand,low,reads,"Get last command run in active terminal."
terminal_selection,read,read/terminalSelection,terminal_selection,#terminalSelection,low,reads,"Get current selection in active terminal."
copilot_getNotebookSummary,read,read/notebookSummary,copilot_getNotebookSummary,#notebookSummary,low,reads,"Get list of Notebook cells with metadata."
read_notebook_cell_output,read,read/notebookCellOutput,read_notebook_cell_output,#notebookCellOutput,low,reads,"Retrieve output for a notebook cell."
create_directory,edit,edit/createDirectory,create_directory,#createDirectory,medium,writes,"Create a new directory structure (like mkdir -p)."
create_file,edit,edit/createFile,create_file,#createFile,medium,writes,"Create a new file with specified content."
replace_string_in_file,edit,edit/editFiles,replace_string_in_file,#editFiles,high,writes,"Replace a unique string in an existing file."
multi_replace_string_in_file,edit,edit/multiEditFiles,multi_replace_string_in_file,#multiEditFiles,high,writes,"Apply multiple replacements in a single call."
edit_notebook_file,edit,edit/editNotebook,edit_notebook_file,#editNotebook,high,writes,"Edit an existing Notebook file."
create_new_jupyter_notebook,edit,edit/createNotebook,create_new_jupyter_notebook,#createNotebook,medium,writes,"Generate a new Jupyter Notebook."
run_in_terminal,execute,execute/runInTerminal,run_in_terminal,#runInTerminal,high,executes,"Execute shell commands in a persistent terminal."
get_terminal_output,execute,execute/getTerminalOutput,get_terminal_output,#getTerminalOutput,low,reads,"Get output of a terminal command."
run_task,execute,execute/runTask,run_task,#runTask,high,executes,"Run an existing VS Code task."
create_and_run_task,execute,execute/createAndRunTask,create_and_run_task,#createAndRunTask,high,executes,"Create and run a build/run/custom task."
get_task_output,execute,execute/getTaskOutput,get_task_output,#getTaskOutput,low,reads,"Get the output of a task."
run_notebook_cell,execute,execute/runNotebookCell,run_notebook_cell,#runNotebookCell,high,executes,"Run a code cell in a notebook."
test_failure,execute,execute/testFailure,test_failure,#testFailure,low,reads,"Include test failure information."
fetch_webpage,web,web/fetch,fetch_webpage,#fetch,medium,network,"Fetch main content from web pages."
github_repo,web,web/githubRepo,github_repo,#githubRepo,medium,network,"Search a GitHub repository for source code."
run_vscode_command,vscode,vscode/runCommand,run_vscode_command,#runVscodeCommand,high,mixed,"Run a VS Code command."
vscode_searchExtensions_internal,vscode,vscode/extensions,vscode_searchExtensions_internal,#extensions,low,network,"Browse VS Code Extensions Marketplace."
install_extension,vscode,vscode/installExtension,install_extension,#installExtension,high,writes,"Install a VS Code extension."
get_project_setup_info,vscode,vscode/getProjectSetupInfo,get_project_setup_info,#getProjectSetupInfo,low,none,"Get project setup info for scaffolding."
open_simple_browser,vscode,vscode/openSimpleBrowser,open_simple_browser,#openSimpleBrowser,medium,none,"Preview a website in Simple Browser."
create_new_workspace,vscode,vscode/newWorkspace,create_new_workspace,#newWorkspace,high,writes,"Get setup steps to create project structures."
get_vscode_api,vscode,vscode/vscodeAPI,get_vscode_api,#VSCodeAPI,low,none,"Get VS Code API documentation."
runSubagent,agent,agent/runSubagent,runSubagent,#runSubagent,high,mixed,"Launch a new agent for complex multi-step tasks."
get_selection,,selection,get_selection,#selection,low,reads,"Get current editor selection."
manage_todo_list,,todo,manage_todo_list,#todo,low,none,"Manage a structured todo list."
>>

RECOMMENDED_PLANNER_TOOLS: ["search/codebase", "search/fileSearch", "search/textSearch", "search/changes", "search/usages", "read/readFile", "read/problems", "todo", "web/fetch", "web/githubRepo"]
RECOMMENDED_IMPLEMENTER_TOOLS: ["search/codebase", "search/fileSearch", "search/textSearch", "read/readFile", "read/problems", "edit/createDirectory", "edit/createFile", "edit/editFiles", "execute/runInTerminal", "execute/getTerminalOutput", "todo", "web/fetch", "web/githubRepo", "agent/runSubagent"]

AGENT_MODELS: ["Claude Haiku 4.5 (copilot)", "Claude Opus 4.5 (copilot)", "Claude Sonnet 4 (copilot)", "Claude Sonnet 4.5 (copilot)", "Gemini 2.5 Pro (copilot)", "GPT-4.1 (copilot)"]

AGENT_VERSIONING: JSON<<
{
  "templates": [
    {
      "path": "templates/.github/agents/aps-v{major}.{minor}.{patch}.agent.md",
      "current_path": "templates/.github/agents/aps-v1.1.16.agent.md",
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
DOCS_CUSTOM_AGENTS_URL: "https://code.visualstudio.com/docs/copilot/customization/custom-agents"
DOCS_TOOLS_IN_CHAT_URL: "https://code.visualstudio.com/docs/copilot/chat/chat-tools"
DOCS_TOOLS_REFERENCE_URL: "https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features"
DOCS_CUSTOM_INSTRUCTIONS_URL: "https://code.visualstudio.com/docs/copilot/customization/custom-instructions"
</constants>

<formats>
<format id="VSCODE_AGENT_FRONTMATTER_V1" name="VS Code Agent Frontmatter" purpose="YAML frontmatter contract for .github/agents/*.agent.md custom agent files.">
---
name: <AGENT_NAME>
description: "<AGENT_DESCRIPTION>"
tools: <TOOLS_ARRAY>
user-invocable: <USER_INVOCABLE>
disable-model-invocation: <DISABLE_MODEL_INVOCATION>
target: <TARGET>
---

WHERE:
- <AGENT_NAME> is String; the agent identifier shown in UI.
- <AGENT_DESCRIPTION> is String; single-line quoted string describing agent purpose.
- <TOOLS_ARRAY> is YAML array of tool qualified names or toolset names from TOOLS constant.
- <USER_INVOCABLE> is Boolean; true if agent appears in the agents dropdown; default true.
- <DISABLE_MODEL_INVOCATION> is Boolean; true to prevent invocation as subagent; default false.
- <TARGET> is one of: "vscode", "github-copilot"; default "vscode".
</format>

<format id="VSCODE_PROMPT_FRONTMATTER_V1" name="VS Code Prompt Frontmatter" purpose="YAML frontmatter contract for .github/prompts/*.prompt.md prompt files.">
---
name: <PROMPT_NAME>
description: "<PROMPT_DESCRIPTION>"
tools: <TOOLS_ARRAY>
---

WHERE:
- <PROMPT_NAME> is String; the prompt name shown in UI.
- <PROMPT_DESCRIPTION> is String; single-line quoted string describing what the prompt does.
- <TOOLS_ARRAY> is YAML array of tool qualified names or toolset names from TOOLS constant.
</format>

<format id="VSCODE_INSTRUCTIONS_FRONTMATTER_V1" name="VS Code Instructions Frontmatter" purpose="YAML frontmatter contract for .github/instructions/*.instructions.md files.">
---
applyTo: "<GLOB_PATTERN>"
description: "<INSTRUCTIONS_DESCRIPTION>"
---

WHERE:
- <GLOB_PATTERN> is String; comma-separated glob patterns (e.g., "**/*.ts,**/*.tsx").
- <INSTRUCTIONS_DESCRIPTION> is String; describes the coding conventions in this file.
</format>

<format id="VSCODE_SKILL_FRONTMATTER_V1" name="VS Code Skill Frontmatter" purpose="YAML frontmatter contract for .github/skills/<id>/SKILL.md files.">
---
name: <SKILL_NAME>
description: "<SKILL_DESCRIPTION>"
---

WHERE:
- <SKILL_NAME> is String; lowercase hyphenated skill identifier (e.g., "webapp-testing").
- <SKILL_DESCRIPTION> is String; specific description so Copilot can auto-load the skill when relevant.
</format>
</formats>
