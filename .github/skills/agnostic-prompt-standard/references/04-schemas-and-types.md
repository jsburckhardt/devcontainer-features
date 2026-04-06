# 04 Schemas and types

This document defines the **schemas** and reusable **type contracts** used by APS.

## Formats registry

The `<formats>` section centralizes all human-readable output contracts that a prompt may ask the
agent to render. This ensures outputs are verifiable, stable, and machine-checkable.

### Requirements

- All format contracts used anywhere in `<instructions>`, `<triggers>`, or `<processes>` MUST be
  declared inside a single `<formats>` section using one-or-more `<format>` tags.
- Each `<format>` MUST have a globally unique `id` within the prompt; `name` and `purpose`
  attributes are RECOMMENDED.
- The body of each `<format>` MUST describe the contract unambiguously (headers, columns,
  wrappers, markers, row grammar, allowed values).
- Rendered output MUST be a single fenced block starting with the exact fence label:

  ```
  ```format:<FORMAT_ID>
  ```

  (No spaces around the colon.)

- No explanatory prose MAY appear outside the fenced block for a step that demands a format.
- If a step references a format id that is not present in `<formats>` → `AG-039`.
- If the rendered block does not satisfy the contract → `AG-036`.
- If the block is not wrapped with the required ```format:<ID> fence → `AG-040`.

### Structure

Tag syntax:

```text
<format id="ID" [name="..."...] [purpose="..."]>
  …
</format>
```

Newline rules apply to `<formats>` and each `<format>` (see **02 Linting and formatting**).

### Placeholders and WHERE

Placeholders and WHERE sections are normative (see also **02 Linting and formatting**):

- Placeholders that appear in the contract body MUST be written as `<UPPER_SNAKE>` using ASCII and
  `UPPER_SNAKE` case.
- Every `<format>` body MUST end with a `WHERE:` section that defines each placeholder exactly
  once.
- Each WHERE definition line MUST begin with `- <PLACEHOLDER> …` and normatively constrain the
  placeholder (e.g., “is …”, “∈ { … }”, “matches …”, “example: …”).
- No placeholder may appear in the body if it is not defined in WHERE → `AG-042`.
- No placeholder may be defined in WHERE if it does not appear in the body → `AG-042`.
- Any non-`<…>` placeholder notation (e.g., `{placeholder}`, `$PLACEHOLDER`) is forbidden →
  `AG-043`.
- The literal keyword `WHERE:` MUST be uppercase and followed by a newline; inline WHERE text is
  forbidden → `AG-041`.

### Expression guidance inside WHERE (RECOMMENDED)

- Type: `is <type>` where `<type>` ∈ { String, Integer, Number, Boolean, ISO8601, Markdown, URI,
  Path }.
- Choice: `∈ { V1, V2, … }` or `is one of: V1, V2, …`.
- Shape: `format: "## <TITLE> …"`, `table columns: | A | B | … |`, `regex: ^…$`.
- Cardinality: `is non-empty`, `is ≤ N chars`, `is comma-separated list of UpperSym`.

### References and phrasing

Prompts SHOULD phrase requirements in `<instructions>` like:

> You MUST conform human-readable outputs to `<formats>` by rendering a single fenced block
> ```format:<ID>```.

### Enforcement

- WHERE presence/quality and placeholder discipline are enforced at lint time.
- Violations map to `AG-041` / `AG-042` / `AG-043` or `AG-036` as applicable.

## Result process pattern

Intent: provide a standard **results** process that summarizes execution across processes in a
pre-defined table for deterministic post-hoc analysis and artifact linking.

Prompts that adopt this pattern MUST:

1. Define `TABLE_PROCESS_RESULTS_V1` inside `<formats>`.
2. Include a terminal process (RECOMMENDED id: `results` or short `res`) that emits exactly one
   fenced block ```format:TABLE_PROCESS_RESULTS_V1``` summarizing all processes in lexical order.
3. Record, at minimum: ProcessId, Name, Status, StartedAt, EndedAt, DurationMs, Outcome,
   Artifacts, Errors.

Status values MUST be one of: PENDING, RUNNING, OK, WARN, ERROR.

Timestamps MUST be ISO 8601 with "Z" or explicit offset.

Artifacts MUST list symbol names (comma-separated) that were RETURNed or CAPTUREd as outputs.

## Supporting files (external)

These files are **external** and MUST NOT appear in the prompt:

- `config.json`: ALIAS only (see schema).
- `predefinedTools.json`: tool signatures for lint/IDE help (replaces schema.json).
- `units.json`: unit catalog used by STE layer.

Policies:

- If a host provides tools/config via higher-level system instructions, the engine MUST ignore any
  duplicate local definitions to avoid prompt bloat.
- Embedding `<config>` or `<import>` tags in a prompt is a hard error (`AG-035`).

Style guidelines:

- For `predefinedTools.json`, prefer one tool object per line to improve diffs/merges (best
  practice; not enforced).
- Engines that emit `predefinedTools.json` SHOULD preserve or adopt the one-line-per-tool layout;
  engines MUST accept any valid JSON layout.

## MCP tool declaration pattern (external)

Intent: let an engine import MCP tool signatures into `predefinedTools.json` without putting host
config inside the prompt.

When an engine imports an MCP `Tool` from `tools/list`, it SHOULD:

1. Create one canonical tool entry per MCP tool.
2. Use `Tool.name` as the canonical APS tool id unless a platform adapter requires a different
   stable id.
3. Preserve `inputSchema` as the primary parameter contract.
4. Preserve `outputSchema` when it is present.
5. Derive the display label in this order: `title`, `annotations.title`, `name`.
6. Treat `readOnlyHint`, `destructiveHint`, `idempotentHint`, and `openWorldHint` as advisory
   metadata only.
7. Record MCP origin metadata such as the server id and original tool name.

If a host exposes decorated runtime names (for example `mcp__server__tool`), the engine SHOULD:

- keep one canonical tool object in `predefinedTools.json`
- map the decorated runtime name to the canonical APS tool id with `config.json` ALIAS entries
- avoid duplicate tool objects that differ only by host wrapper syntax.

A collision between a host tool name, an MCP-imported tool name, or an ALIAS target/source MUST
raise `AG-034`.

### Recommended object shape for `predefinedTools.json`

This shape is RECOMMENDED for imported MCP tools. Engines MAY add extra fields.

```json
{
  "name": "search_docs",
  "displayName": "Search Docs",
  "description": "Search the documentation site.",
  "inputSchema": { "type": "object", "properties": { "query": { "type": "string" } }, "required": ["query"] },
  "outputSchema": { "type": "object", "properties": { "matches": { "type": "array" } } },
  "hints": {
    "readOnly": true,
    "destructive": false,
    "idempotent": true,
    "openWorld": true
  },
  "source": {
    "kind": "mcp",
    "server": "docs",
    "toolName": "search_docs"
  }
}
```

Notes:

- `name` is the canonical APS tool id.
- `displayName` is for humans and UI only.
- `hints` do not change the true behavior of a tool. They are advisory.
- `source` gives provenance for lint, IDE help, and debug output.

## Example format contracts

- Minimal error contract: [../assets/formats/format-error-v1.0.0.example.md](../assets/formats/format-error-v1.0.0.example.md)
- API coverage table: [../assets/formats/format-table-api-coverage-v1.0.0.example.md](../assets/formats/format-table-api-coverage-v1.0.0.example.md)
- Code map: [../assets/formats/format-code-map-v1.0.0.example.md](../assets/formats/format-code-map-v1.0.0.example.md)
- Ideation list: [../assets/formats/format-ideation-list-v1.0.0.example.md](../assets/formats/format-ideation-list-v1.0.0.example.md)
- Hierarchical outline: [../assets/formats/format-hierarchical-outline-v1.0.0.example.md](../assets/formats/format-hierarchical-outline-v1.0.0.example.md)
- Markdown table: [../assets/formats/format-markdown-table-v1.0.0.example.md](../assets/formats/format-markdown-table-v1.0.0.example.md)
- Code changes full: [../assets/formats/format-code-changes-full-v1.0.0.example.md](../assets/formats/format-code-changes-full-v1.0.0.example.md)
- SMEAC plan: [../assets/formats/format-smeac-plan-v1.0.0.example.md](../assets/formats/format-smeac-plan-v1.0.0.example.md)

- MCP tool bridge example: [../assets/composites/mcp-tool-bridge-v1.0.0.example.md](../assets/composites/mcp-tool-bridge-v1.0.0.example.md)

## Example constants

- JSON block constant example: [../assets/constants/constants-json-block-v1.0.0.example.md](../assets/constants/constants-json-block-v1.0.0.example.md)
- TEXT block constant example: [../assets/constants/constants-text-block-v1.0.0.example.md](../assets/constants/constants-text-block-v1.0.0.example.md)
- CSV block constant example: [../assets/constants/constants-csv-block-v1.0.0.example.md](../assets/constants/constants-csv-block-v1.0.0.example.md)
