# 02 Linting and formatting

This document defines the **compile-time and lint-time** formatting rules.

## Newlines and XML-like tags

Newline rule (normative):

- There MUST be exactly one newline after an opening XML-like tag.
- There MUST be exactly one newline before a closing XML-like tag.

This applies to top-level sections (`<instructions>`, `<constants>`, `<formats>`, `<runtime>`,
`<triggers>`, `<processes>`, `<input>`) and to nested tags like `<format>` and `<process>`.

## Tabs and whitespace

- Tab characters (`\t`) are forbidden anywhere in a prompt. Tabs MUST raise `AG-011`.
- Engines MUST treat excessive inter-token padding whitespace as a compile error (`AG-031`) when
  compiled/normalized form requires exactly one ASCII space.

## Comments

Comments (`//`) are forbidden in all sections of a conforming prompt. Any line whose first two
non-whitespace characters are `//` MUST raise `AG-010`.

## Unicode and quotes

- Prompts MUST be NFC normalized.
- Strings MUST use ASCII double quotes (`"`) only. Smart quotes are forbidden.

## Canonical JSON spacing

Engines that compile or canonicalize JSON MUST emit **canonical JSON** using the rules below:

- After `:`, exactly one ASCII space.
- After `,`, exactly one ASCII space.
- No interior spaces immediately inside `{` `}` `[` `]`.
  - Empty containers are `{}` and `[]`.
- Keys in objects MUST be in lexicographic order.

Source form inside JSON block constants MAY contain arbitrary newlines/indentation, but engines
MUST parse and re-emit canonical JSON at compile time.

## Canonical YAML formatting

Engines that compile or canonicalize YAML MUST emit **canonical YAML** using the rules below:

- Keys in mappings MUST be in lexicographic order.
- Indentation MUST use exactly two ASCII spaces per nesting level.
- No trailing whitespace on any line.
- Strings MUST only be quoted when required by YAML syntax (e.g., values containing `:`, `#`, or
  leading/trailing whitespace).
- Empty mappings are `{}` and empty sequences are `[]`.

Source form inside YAML block constants MAY contain arbitrary formatting, but engines MUST parse
and re-emit canonical YAML at compile time.

## Canonical CSV compilation

Engines that compile CSV block constants MUST:

- Parse CSV per **00 Structure** (header row rules, quoting rules, row width rules).
- Compile the result to canonical JSON using the rules in **Canonical JSON spacing**.
- Preserve CSV record order in the compiled JSON array.

If an engine also emits canonical CSV (informative), it SHOULD:

- Use `,` as the separator and `"` as the quote character.
- Quote a field only when required (contains `,`, `"`, or newline, or has leading/trailing space).
- Escape `"` as `""` inside quoted fields.
- Use LF newlines and emit no trailing whitespace.

## `where:` key ordering

In `where:` parameter lists, keys MUST appear in lexicographic order. Violation → `AG-012`.

## Backticked ids

Process and tool ids in statements MUST be wrapped in backticks.

Examples:

- `RUN \`process_id\``
- `USE \`tool_name\``

Violation → `AG-003` (InvalidId).

## Constants inside JSON values

An `UpperSym` appearing inside JSON objects/arrays denotes a **constant symbol reference**.
Engines MUST resolve it from `<constants>` before execution or raise `AG-006`.

## Constants inside YAML values

An `UpperSym` appearing inside YAML mappings/sequences/scalars denotes a **constant symbol
reference**.

Engines MUST resolve it from `<constants>` before execution or raise `AG-006`.

## Constants inside CSV values

In a CSV block constant, an unquoted cell whose full content matches `UpperSym` denotes a
**constant symbol reference**.

- Engines MUST resolve it from `<constants>` before execution or raise `AG-006`.
- The referenced constant MUST resolve to a scalar (`String | Number | Boolean | null`) or the
  engine MUST raise `AG-048`.

## Block constants

Block constants are allowed only inside `<constants>` (see **00 Structure**).

Rules:

- Block constant opening line MUST be `SYMBOL: JSON<<`, `SYMBOL: TEXT<<`, `SYMBOL: YAML<<`, or
  `SYMBOL: CSV<<` (exactly one ASCII space after `:`).
- Block constant BODY is line-oriented and terminates at the first line whose content is exactly
  `>>` starting at column 1.
- Unknown `<BLOCK_TYPE>` → `AG-046`.
- Missing closing delimiter `>>` → `AG-045`.
- Invalid JSON block constant BODY → `AG-007`.
- Invalid YAML block constant BODY → `AG-047`.
- Invalid CSV block constant BODY → `AG-048`.

## Format blocks

Rendered format outputs MUST be wrapped in a fenced code block whose info string is exactly
`format:<ID>` where `<ID>` matches a defined `<format id="...">`.

Rules:

- The fence MUST start at column 1.
- For any step that requires a format, the agent MUST emit exactly one `format:<ID>` fenced block.
  Multiple blocks or surrounding prose → `AG-040`.

### WHERE discipline (format contracts)

Every rendered format block MUST include a terminating `WHERE:` section.

Each `<PLACEHOLDER>` token that appears in the body MUST have exactly one definition line in
`WHERE:`. No extra definitions are allowed.

- Missing/extra/mismatched definitions → `AG-041` / `AG-042`.
- Placeholders MUST be `<UPPER_SNAKE>`; any other style → `AG-043`.

## RETURN values

`RETURN` supports:

- Symbol lists
- `key=value` pairs
- Artifact references of the form:

```json
{"$artifact":"SYMBOL","hash":"sha256:..."}
```

See **03 Agentic control** and **05 Grammar** for executable syntax.
