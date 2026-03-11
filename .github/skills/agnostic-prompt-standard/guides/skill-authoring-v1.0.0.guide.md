<instructions>
You MUST create a SKILL.md file as the entrypoint for every skill.
You MUST use kebab-case for the skill directory name.
You MUST start SKILL.md with YAML frontmatter between --- delimiters.
You SHOULD include name and description fields in frontmatter.
You SHOULD include a metadata sub-object with author and spec_version.
You MUST structure the SKILL.md body as: title, overview, references, skill layout.
You MUST name reference files using the NN-<name>.md convention.
You MUST write references as prose markdown, not APS envelopes.
You MUST use normative language (MUST, SHOULD, MAY) in reference documents.
You MUST use active voice and imperative mood in reference procedures.
You SHOULD organize references with one topic per section using H2/H3 headings.
You MUST use relative markdown paths for cross-references within a skill.
You MUST name constant asset files as constants-<descriptor>-v<VERSION>.example.md.
You MUST name format asset files as format-<descriptor>-v<VERSION>.example.md.
You MUST name composite asset files as <descriptor>-v<VERSION>.example.md.
You MUST use UPPER_SNAKE_CASE matching ^[A-Z0-9_]{2,24}$ for constant symbols.
You MUST place exactly one ASCII space after the colon in block constant openers.
You MUST place the closing >> at column 1 on its own line.
You MUST give every format a unique id in UPPER_SNAKE_CASE with version suffix.
You MUST define a WHERE entry for every <PLACEHOLDER> in a format body.
You MUST use <UPPER_SNAKE> notation for all format placeholders.
You MUST structure process files as APS documents following section ordering.
You SHOULD omit APS sections that carry no content.
You MUST name process files as <process-name>.md in kebab-case.
You MUST backtick all process and tool IDs in DSL statements.
You MUST order where: keys in lexicographic order.
You MUST use logical tool names that platform adapters resolve.
You MUST NOT use tab characters in any skill file.
You MUST NOT use comment syntax inside APS sections.
You MUST NOT use smart quotes; use ASCII double quotes only.
You MAY add a license field using an SPDX identifier in frontmatter.
You MAY add a version field for standalone skill versioning in frontmatter.
</instructions>

<constants>
GUIDE_VERSION: "1.0.0"

SKILLMD_BODY_SECTIONS: TEXT<<
1. Title — # <Skill Name> as an H1 heading.
2. Overview — One paragraph covering what the skill does, who uses it, and why.
3. References — Numbered list linking to each document in references/.
4. Skill layout — Bullet-list tree of directory contents with one-line descriptions.
>>

FRONTMATTER_FIELDS: CSV<<
field,required,notes
name,Recommended,"Skill identifier, kebab-case"
description,Recommended,"Single sentence, double-quoted"
license,Optional,"SPDX identifier (e.g. MIT, Apache-2.0)"
version,Optional,SemVer string for standalone versioning
metadata,Recommended,Structured sub-object for provenance
>>

METADATA_SUBFIELDS: TEXT<<
repository — URL of the source repository.
author — Primary author name.
co_authors — Semicolon-delimited list of co-author names.
spec_version — APS spec version targeted (e.g. 1.0).
framework_revision — Skill version in SemVer format.
last_updated — ISO 8601 date of last modification.
>>

REFERENCE_CONTENT_RULES: TEXT<<
Use normative language from 01-vocabulary.md: MUST, MUST NOT, SHOULD, SHOULD NOT, MAY.
Use active voice and imperative or declarative mood.
Limit one topic per section with clear H2/H3 headings.
Use tables for structured rules and lists for enumerations.
Use fenced code blocks with language identifiers for examples.
Link between documents using relative markdown paths.
All links must resolve to files within the skill directory.
Fragment anchors (#heading) are allowed for linking to specific sections.
>>

BLOCK_TYPE_REF: CSV<<
block_type,use_case,key_rules
JSON,Structured data,"Lexicographic key order, canonical spacing"
TEXT,Literal text,Preserved verbatim after newline normalization
YAML,Configuration,"2-space indent, lexicographic key order"
CSV,Tabular data,"Header row + records, same field count per row"
>>

BLOCK_SYNTAX_RULES: TEXT<<
Opener: SYMBOL: TYPE<< with exactly one ASCII space after the colon and no spaces before <<.
Closer: >> on its own line at column 1 with no leading or trailing whitespace.
Body: content between the newline after the opener and the newline before the closer.
>>

FORMAT_WHERE_TYPES: TEXT<<
String — Free-text value.
Integer — Whole number value.
Number — Numeric value (integer or decimal).
Boolean — true or false.
ISO8601 — ISO 8601 date or datetime string.
Markdown — Markdown-formatted text (lists, headings, inline formatting).
URI — Uniform resource identifier.
Path — File or directory path.
>>

COMPOSITE_ASSET_DESC: TEXT<<
Composites bundle tightly coupled constants and formats in a single file.
The format references the constants as its type vocabulary.
File naming: <descriptor>-v<VERSION>.example.md in assets/composites/.
>>

DSL_KEYWORD_REF: TEXT<<
RUN — Invoke a sub-process. Example: RUN `sub-process`.
USE — Invoke a tool with parameters. Example: USE `Read` where: path="file.md".
CAPTURE — Bind a tool result to a variable. Example: CAPTURE RESULT from `Read`.
SET — Assign a value to a variable. Example: SET VAR := "value" (from "Agent Inference").
IF / ELSE — Conditional branching. Example: IF condition:.
PAR / JOIN — Execute statements concurrently. Example: PAR: ... JOIN:.
FOREACH — Iterate over a collection. Example: FOREACH ITEM IN COLLECTION:.
TELL — Emit narrative output to the user. Example: TELL "message" level=brief.
RETURN — Exit a process with a formatted result. Example: RETURN: format="ID", key=value.
TRY / RECOVER — Handle errors in process execution. Example: TRY: ... RECOVER ERR:.
>>

DSL_CRITICAL_RULES: TEXT<<
Process and tool IDs must be backticked: `process-id`, `Read`.
where: keys must be in lexicographic order (AG-012).
Use logical tool names (Read, Write, Glob) that platform adapters resolve.
No tabs (AG-011), no comments (AG-010), no smart quotes.
>>

DESIGN_PATTERNS: JSON<<
{
  "compliance-checker": {
    "description": "Validates artifacts against a set of rules",
    "emphasis": "references + processes + formats",
    "example_dirs": ["assets/formats/", "processes/", "references/"]
  },
  "domain-vocabulary": {
    "description": "Defines a shared language for a specific domain",
    "emphasis": "references + constants",
    "example_dirs": ["assets/constants/", "assets/formats/", "references/"]
  },
  "library-wrapper": {
    "description": "Wraps an external library, SDK, or API as a skill",
    "emphasis": "references + constants + processes",
    "example_dirs": ["assets/constants/", "assets/formats/", "processes/", "references/"]
  },
  "workflow": {
    "description": "Encodes a multi-step business or engineering workflow",
    "emphasis": "references + processes",
    "example_dirs": ["processes/", "references/"]
  }
}
>>

COMMON_PITFALLS: TEXT<<
Missing WHERE clauses — Format placeholders without type definitions trigger AG-041. Fix: add a WHERE entry for every placeholder in the format body.
Tab characters — Tabs in any APS section trigger AG-011. Fix: use spaces only; configure editor to insert spaces.
Smart quotes — Curly quotes break string parsing. Fix: use straight ASCII double quotes only.
Unbackticked IDs — Process and tool IDs without backticks trigger AG-003. Fix: always wrap IDs in backticks.
Orphan constants — Constants defined but never referenced. Fix: remove unused constants or reference them in processes or formats.
Platform-specific tool names — Hardcoded tool names break portability. Fix: use logical names (Read, Write, Glob) and let the adapter resolve them.
Blank lines in instructions — Empty lines inside instructions trigger AG-033. Fix: remove all blank lines; every line must contain a directive.
Multi-sentence lines — Multiple sentences on one line in instructions trigger AG-033. Fix: one directive per line, max 20 words.
>>
</constants>

<formats>
<format id="SKILL_ANATOMY_V1" name="Skill Anatomy" purpose="Summarize a skill directory structure and composition for review">
## Skill Anatomy: <SKILL_ID>

**Pattern:** <PATTERN_NAME>

### Directory tree
<DIR_TREE>

### Composition
| Component | Count |
|-----------|-------|
| References | <REF_COUNT> |
| Constants | <CONST_COUNT> |
| Formats | <FMT_COUNT> |
| Processes | <PROC_COUNT> |

### Design notes
<DESIGN_NOTES>

WHERE:
- <CONST_COUNT> is Integer; number of constant asset files.
- <DESIGN_NOTES> is Markdown; architectural observations and recommendations.
- <DIR_TREE> is String; ASCII tree showing the skill directory layout.
- <FMT_COUNT> is Integer; number of format asset files.
- <PATTERN_NAME> is String; one of library-wrapper, workflow, domain-vocabulary, compliance-checker.
- <PROC_COUNT> is Integer; number of process files.
- <REF_COUNT> is Integer; number of reference documents.
- <SKILL_ID> is String; kebab-case skill directory name.
</format>
</formats>
