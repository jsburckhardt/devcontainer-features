<instructions>
You MUST load the target platform adapter from PLATFORMS_REL before generating any output.
You MUST derive tool names, file paths, and frontmatter format from the loaded adapter.
You MUST NOT embed platform-specific tool names, paths, or conventions in generated skill content.
You MUST elicit domain, purpose, and audience before scaffolding any files.
You MUST determine the source mode before proceeding: from-scratch, from-docs, or from-codebase.
You MUST load the skill template from TEMPLATE_REL_PATH as the scaffolding seed.
You MUST load the authoring guide from GUIDE_REL_PATH for reference during generation.
You MUST load APS references 00-structure, 01-vocabulary, and 02-linting from APS_REFERENCES_REL.
You MUST generate a valid SKILL.md with complete frontmatter as the first file.
You MUST create at least one reference document in the skill.
You SHOULD create constants and formats only when the domain requires structured data or output contracts.
You MUST validate all generated files against the VALIDATION_CHECKLIST.
You MUST ask no more than two blocking questions per turn.
You SHOULD write files directly when the target path has no existing files and scope is unambiguous.
You MUST present the skill plan for approval when scope is ambiguous or the target directory has existing files.
You MUST use NAMING_RULES for all generated file and symbol names.
You MUST use logical tool names that the platform adapter resolves to actual implementations.
You MUST follow DIRECTORY_STRUCTURE for the generated skill layout.
You SHOULD generate process files only when the skill encodes executable workflows.
You MUST report validation results and offer fixes for any issues found.
</instructions>

<constants>
TEMPLATE_REL_PATH: "_template/"
GUIDE_REL_PATH: "guides/skill-authoring-v1.0.0.guide.md"
APS_REFERENCES_REL: "references/"
PLATFORMS_REL: "platforms/"

SOURCE_MODES: JSON<<
{
  "from-codebase": {
    "description": "Analyze existing code to extract domain knowledge",
    "required_inputs": ["codebase_path"],
    "tools": ["Glob", "Grep", "Read"]
  },
  "from-docs": {
    "description": "Build skill from existing documentation or specifications",
    "required_inputs": ["doc_paths"],
    "tools": ["Read"]
  },
  "from-scratch": {
    "description": "Build skill from user-described domain knowledge",
    "required_inputs": ["domain_description"],
    "tools": []
  }
}
>>

SKILL_FRONTMATTER_TEMPLATE: TEXT<<
---
name: <skill-id>
description: "<One-sentence skill description>"
license: MIT
metadata:
  author: "<Author Name>"
  spec_version: "1.0"
  framework_revision: "1.0.0"
  last_updated: "<YYYY-MM-DD>"
---
>>

NAMING_RULES: TEXT<<
Skill IDs: kebab-case, unique within installation scope.
Reference files: NN-<name>.md (zero-padded sequence, kebab-case name).
Constant symbols: UPPER_SNAKE_CASE matching ^[A-Z0-9_]{2,24}$.
Format IDs: UPPER_SNAKE_CASE with version suffix (e.g., REPORT_V1).
Process IDs: kebab-case matching ^[a-z][a-z0-9_-]{1,63}$.
Process files: <process-name>.md in processes/ directory.
Asset files: <category>-<descriptor>-v<VERSION>.example.md.
Guide files: <descriptor>-v<VERSION>.guide.md in guides/ directory.
>>

VALIDATION_CHECKLIST: TEXT<<
1. SKILL.md exists with valid YAML frontmatter.
2. Frontmatter contains name and description fields.
3. Reference files follow NN-<name>.md naming convention.
4. No tab characters in any generated file (AG-011).
5. No comment syntax in APS sections (AG-010).
6. All format placeholders have WHERE definitions (AG-041).
7. Placeholder count in body matches WHERE count (AG-042).
8. Placeholders use <UPPER_SNAKE> format (AG-043).
9. All where: keys in lexicographic order (AG-012).
10. Process and tool IDs are backticked (AG-003).
11. APS sections appear in correct order when present (00-structure).
>>

DIRECTORY_STRUCTURE: TEXT<<
<skill-id>/
  SKILL.md
  references/
    00-<name>.md
  assets/
    constants/
    formats/
  processes/
  guides/
  scripts/
>>
</constants>

<formats>
<format id="SKILL_PLAN_V1" name="Skill Plan" purpose="Present the proposed skill structure for approval">
## Skill Plan: <SKILL_NAME>

**Domain:** <DOMAIN>
**Purpose:** <PURPOSE>
**Source mode:** <MODE>

### Proposed files
<FILE_LIST>

### Directory structure
<DIR_TREE>

WHERE:
- <DIR_TREE> is String; ASCII tree showing the proposed directory layout.
- <DOMAIN> is String; the knowledge domain the skill covers.
- <FILE_LIST> is Markdown numbered list; each entry has path and one-line description.
- <MODE> is String; one of from-scratch, from-docs, from-codebase.
- <PURPOSE> is String; one sentence describing what the skill enables.
- <SKILL_NAME> is String; human-readable skill name.
</format>

<format id="SKILL_FILE_V1" name="Skill File Output" purpose="Report on a single generated file">
### <FILE_PATH>
**Status:** <VALIDATION_STATUS>
<ISSUES>

WHERE:
- <FILE_PATH> is Path; relative path from the skill root.
- <ISSUES> is String; validation issues found, or empty if none.
- <VALIDATION_STATUS> is String; one of pass, warn, fail.
</format>

<format id="SKILL_SUMMARY_V1" name="Skill Build Summary" purpose="Summarize the completed skill build">
## Skill Build Complete: <SKILL_NAME>

### Files created
<FILES_CREATED>

### Validation
**Result:** <OVERALL_STATUS>
<VALIDATION_DETAILS>

### Next steps
<NEXT_STEPS>

WHERE:
- <FILES_CREATED> is Markdown numbered list; paths of all generated files.
- <NEXT_STEPS> is Markdown bullet list; recommended follow-up actions.
- <OVERALL_STATUS> is String; one of pass, warn, fail.
- <SKILL_NAME> is String; human-readable skill name.
- <VALIDATION_DETAILS> is String; summary of validation results per file.
</format>
</formats>

<runtime>
SOURCE_MODE: ""
SKILL_ID: ""
SKILL_DOMAIN: ""
SKILL_PURPOSE: ""
PLAN_APPROVED: false
FILES_GENERATED: 0
VALIDATION_RESULT: ""
</runtime>

<triggers>
<trigger event="user_message" target="build-router" />
</triggers>

<processes>
<process id="build-router" name="Build Router">
TELL "Routing skill build request" level=brief
IF SOURCE_MODE = "":
  RUN `init-context`
  RUN `elicit-domain`
IF PLAN_APPROVED = false:
  RUN `plan-skill`
IF PLAN_APPROVED = true:
  RUN `generate-skill`
  RUN `validate-skill`
</process>

<process id="init-context" name="Initialize Context">
TELL "Loading authoring context from APS skill" level=brief
PAR:
  USE `Read` where: path=GUIDE_REL_PATH
  USE `Read` where: path=APS_REFERENCES_REL + "00-structure.md"
  USE `Read` where: path=APS_REFERENCES_REL + "01-vocabulary.md"
  USE `Read` where: path=APS_REFERENCES_REL + "02-linting-and-formatting.md"
JOIN:
  CAPTURE GUIDE from `Read`
  CAPTURE STRUCTURE_REF from `Read`
  CAPTURE VOCABULARY_REF from `Read`
  CAPTURE LINTING_REF from `Read`
TELL "Loaded authoring guide and APS references" level=brief
SET PLATFORM_ADAPTER := "" (from "Agent Inference")
IF PLATFORM_ADAPTER != "":
  USE `Read` where: path=PLATFORMS_REL + PLATFORM_ADAPTER + "/adaptor.md"
  CAPTURE ADAPTER from `Read`
  TELL "Loaded platform adapter" level=brief
USE `Read` where: path=TEMPLATE_REL_PATH + "SKILL.md"
CAPTURE TEMPLATE from `Read`
TELL "Context initialization complete" level=brief
</process>

<process id="elicit-domain" name="Elicit Domain">
TELL "Gathering skill requirements" level=brief
SET SKILL_DOMAIN := "" (from "Agent Inference")
SET SKILL_PURPOSE := "" (from "Agent Inference")
SET SKILL_ID := "" (from "Agent Inference")
SET SOURCE_MODE := "" (from "Agent Inference")
IF SOURCE_MODE = "from-docs":
  TELL "Reading source documents" level=brief
  SET DOC_PATHS := "" (from "Agent Inference")
  FOREACH DOC IN DOC_PATHS:
    USE `Read` where: path=DOC
    CAPTURE DOC_CONTENT from `Read`
IF SOURCE_MODE = "from-codebase":
  TELL "Analyzing codebase for domain extraction" level=brief
  SET CODEBASE_PATH := "" (from "Agent Inference")
  PAR:
    USE `Glob` where: path=CODEBASE_PATH, pattern="**/*"
    USE `Grep` where: path=CODEBASE_PATH, pattern="class|interface|function|def"
  JOIN:
    CAPTURE FILE_LIST from `Glob`
    CAPTURE CODE_PATTERNS from `Grep`
TELL "Domain elicitation complete" level=brief
</process>

<process id="plan-skill" name="Plan Skill">
TELL "Planning skill structure" level=brief
USE `Read` where: path=TEMPLATE_REL_PATH + "SKILL.md"
CAPTURE TEMPLATE from `Read`
SET PLANNED_FILES := "" (from "Agent Inference")
SET PLANNED_STRUCTURE := "" (from "Agent Inference")
RETURN: format="SKILL_PLAN_V1", dir_tree=PLANNED_STRUCTURE, domain=SKILL_DOMAIN, file_list=PLANNED_FILES, mode=SOURCE_MODE, purpose=SKILL_PURPOSE, skill_name=SKILL_ID
SET PLAN_APPROVED := true (from "Agent Inference")
</process>

<process id="generate-skill" name="Generate Skill">
TELL "Generating skill files" level=brief
SET FILE_COUNT := 0 (from "Agent Inference")
SET CURRENT_FILE := "" (from "Agent Inference")
FOREACH FILE IN PLANNED_FILES:
  SET CURRENT_FILE := FILE (from "Agent Inference")
  SET FILE_CONTENT := "" (from "Agent Inference")
  USE `Write` where: content=FILE_CONTENT, path=CURRENT_FILE
  SET FILE_COUNT := FILE_COUNT + 1 (from "Agent Inference")
  TELL "Generated file" level=detail
SET FILES_GENERATED := FILE_COUNT (from "Agent Inference")
TELL "File generation complete" level=brief
</process>

<process id="validate-skill" name="Validate Skill">
TELL "Validating generated skill" level=brief
SET ISSUES := "" (from "Agent Inference")
SET OVERALL := "pass" (from "Agent Inference")
FOREACH FILE IN PLANNED_FILES:
  USE `Read` where: path=FILE
  CAPTURE CONTENT from `Read`
  SET FILE_STATUS := "pass" (from "Agent Inference")
  SET FILE_ISSUES := "" (from "Agent Inference")
  RETURN: format="SKILL_FILE_V1", file_path=FILE, issues=FILE_ISSUES, validation_status=FILE_STATUS
  IF FILE_STATUS != "pass":
    SET OVERALL := FILE_STATUS (from "Agent Inference")
SET VALIDATION_RESULT := OVERALL (from "Agent Inference")
RETURN: format="SKILL_SUMMARY_V1", files_created=PLANNED_FILES, next_steps=ISSUES, overall_status=OVERALL, skill_name=SKILL_ID, validation_details=ISSUES
</process>
</processes>

<input>
USER_INPUT is the user message describing the skill to build or providing answers to elicitation questions.
SKILL_DOMAIN is extracted from USER_INPUT representing the knowledge domain.
SKILL_PURPOSE is extracted from USER_INPUT representing the intended use.
</input>
