# 00 Structure

This document defines the **required top-level prompt envelope** and the structural rules for
`<triggers>` and `<processes>`.

## Top-level sections

A conforming prompt MUST be composed of the following top-level sections in this exact order:

1. `<instructions>…</instructions>`
2. `<constants>…</constants>`
3. `<formats>…</formats>`
4. `<runtime>…</runtime>`
5. `<triggers>…</triggers>`
6. `<processes>…</processes>`
7. `<input>…</input>`

Normative structural config (informative to engines, but requirements above are authoritative):

```yaml
prompt_sections:
  order: [instructions, constants, formats, runtime, triggers, processes, input]
  tags:
    - <instructions>…</instructions>
    - <constants>…</constants>
    - <formats>…</formats>
    - <runtime>…</runtime>
    - <triggers>…</triggers>
    - <processes>…</processes>
    - <input>…</input>
```

### General rules

- Each top-level section MUST appear **at most once**.
- The `<triggers>` and `<processes>` sections are **executable**.
- Comments (`//`) are forbidden in all sections (see **02 Linting and formatting**).
- `<constants>` are **read-only** and MUST be resolved before any tool invocation.
- `<constants>` take precedence over `<runtime>` if the same symbol is defined in both.
- Engines SHOULD raise an error or warning when a symbol is defined in both `<constants>` and
  `<runtime>`, as this indicates a prompt authoring mistake. If both exist, `<constants>` takes
  precedence.

## `<constants>` section

The `<constants>` block MAY include read-only constant bindings.

Constants MUST use one of the following forms:

1. Inline constant: `SYMBOL: VALUE` where `VALUE` is `String | Number | Boolean | JSON`.
2. Block constant: `SYMBOL: <BLOCK_TYPE><<` then BODY lines then a closing delimiter line `>>`.

`<BLOCK_TYPE>` MUST be one of: `JSON`, `TEXT`, `YAML`, `CSV`.

Block constant opening lines MUST:

- Use exactly one ASCII space after `:`
- Contain no spaces before `<<`

Valid openers:

- `SYMBOL: JSON<<`
- `SYMBOL: TEXT<<`
- `SYMBOL: YAML<<`
- `SYMBOL: CSV<<`

Block constant closing delimiter MUST be a line whose content is exactly `>>` starting at column 1
(no leading/trailing whitespace).

### JSON block constants

- BODY MUST parse as `JsonValue` per **05 Grammar**; invalid JSON → `AG-007`.
- Any `UpperSym` that appears inside a JSON block constant BODY MUST resolve from `<constants>`
  before execution; unresolved → `AG-006`.
- Engines MUST compile JSON block constants to canonical JSON that conforms to `json_spacing` and
  lexicographic key order (see **02 Linting and formatting**).

### TEXT block constants

- BODY is a literal String; engines MUST preserve BODY verbatim after newline normalization
  (CRLF→LF).
- BODY is the exact text between the newline after the opening line and the newline before the
  closing delimiter line.
- Leading/trailing whitespace inside BODY is significant.

### YAML block constants

- BODY MUST parse as valid YAML; invalid YAML → `AG-047`.
- Any `UpperSym` that appears inside a YAML block constant BODY MUST resolve from `<constants>`
  before execution; unresolved → `AG-006`.
- Engines MUST compile YAML block constants to canonical YAML with lexicographic key ordering and
  consistent indentation (see **02 Linting and formatting**).

### CSV block constants

CSV blocks are for compact tabular data.

- BODY MUST parse as CSV (comma-separated values) using the rules below; invalid CSV → `AG-048`.
- Separator is `,` (comma).
- Quote character is `"` (double quote).
- First record is the header row.
  - Header fields MUST be unquoted.
  - Header fields MUST match `JsonKey` per **05 Grammar**.
  - Header fields MUST be unique.
- Each subsequent record MUST have the same number of fields as the header row (ragged rows are
  forbidden).
- Quoted cell values:
  - MUST follow RFC 4180 quoting (`""` escapes `"`).
  - Are always treated as `String` (no constant substitution).
- Unquoted cell values are parsed in this order:
  1. If the full cell matches `UpperSym`, it denotes a constant symbol reference.
     - Engines MUST resolve it from `<constants>` before execution; unresolved → `AG-006`.
     - The referenced constant MUST be a scalar (`String | Number | Boolean | null`) or the engine
       MUST raise `AG-048`.
  2. If the cell matches JSON scalars (`Number`, `true`, `false`, `null`), it becomes that JSON
     scalar.
  3. Otherwise the cell is a `String` (no trimming).
- Engines MUST compile CSV block constants to canonical JSON as a `JsonArr` of `JsonObj` rows using
  header fields as keys (see **02 Linting and formatting**).
  - Record order MUST be preserved.
  - Row object keys MUST be emitted in lexicographic order in canonical JSON form.

### Block type selection guidance

Prefer CSV blocks for compact tabular data with a header row and consistent columns.

Prefer YAML blocks for structured data unless JSON has a specific advantage (e.g., the constant
represents an actual JSON payload or JSON Schema).

Prefer TEXT blocks only when the constant must remain opaque (verbatim).

## `<processes>` section

The `<processes>` block MUST contain one or more `<process>` tags.

### `<process>` tag

Tag syntax:

```text
<process id="PROCESS_ID" [name="..."] [args="ARG: TYPE, ..."]>
  …
</process>
```

Example:

```text
<process id="calc_tax" args="amount: Number, region: String">
  …
</process>
```

Rules:

- The content of `<process>` MUST conform to **05 Grammar**.
- Variables defined via `SET` inside a process are local to that process unless explicitly
  `RETURN`ed.
- The engine/LSP MUST raise `AG-044` if a `RUN` statement fails to provide arguments matching the
  signature.

## `<triggers>` section

Purpose: maps external events to the execution of a specific `process_id`.

Trigger syntax:

```text
<trigger event="EVENT_TYPE" [pattern="REGEX"] target="PROCESS_ID" />
```

Validation:

- `target` MUST resolve to a valid `<process id="…">` (`AG-004`).
