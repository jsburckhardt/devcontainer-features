# 03 Agentic control

This document defines the **agentic control DSL** used inside `<process>` bodies.

## Keywords

```yaml
keywords:
  control: [GIVEN, WHEN, THEN, IF, ELSE IF, ELSE, IN]
  actions: [RUN, USE, CAPTURE, SET, UNSET, RETURN, ASSERT]
  story: [TELL, SNAP, MILESTONE]
  blocks: [WITH, PAR, JOIN, TRY, FOREACH, RECOVER]
  modifiers: [atomic, timeout_ms, retry]
```

## Identifiers and reserved tokens

```yaml
identifiers:
  symbol:
    regex: "^[A-Z0-9_]{2,24}$"
    unique: true

  process_id:
    regex: "^[a-z][a-z0-9_-]{1,63}$"
    unique: true

  tool_name:
    regex: "^[a-z][a-z0-9_-]{1,63}$"
    registered_by_engine: true

  placeholder:
    syntax: "<UPPER_SNAKE>"
    charset: "A-Z0-9_"
    resolvable: true

  reserved:
    - GIVEN
    - WHEN
    - THEN
    - IF
    - ELSE
    - FOREACH
    - IN
    - TRY
    - RECOVER
    - RUN
    - USE
    - SET
    - CAPTURE
    - RETURN
    - ASSERT
    - SHOULD
    - MAY
    - AND
    - OR
    - NOT
    - WITH
    - PAR
    - JOIN
    - TELL
    - SNAP
    - MILESTONE
```

Reserved words cannot be used as ids/keys/symbols (`AG-002`).

## GIVEN / WHEN / THEN (BDD pattern)

These keywords support Behavior-Driven Design (BDD) style specifications:

- `GIVEN`: establishes preconditions or context that must hold before execution.
- `WHEN`: describes a trigger, event, or condition that initiates action.
- `THEN`: specifies expected outcomes or postconditions after execution.

Each keyword opens a block with `:` (Python-style). The block body contains statements that execute
when the condition is satisfied. Engines SHOULD evaluate conditions in lexical order.

## Strings, booleans, and numbers

```yaml
strings_booleans_numbers:
  strings:
    quote: double_only
  booleans: [true, false]
  numbers:
    grammar: JSON_number
    thousands: forbidden
```

## Determinism

- External `USE` invocations SHOULD be idempotent; engines MAY deduplicate based on a stable hash
  of inputs.
- `CAPTURE` is the binding point; `USE` does not mutate the symbol table by itself.

## Storytelling

These statements produce narrative/logging events and are not allowed to change program state
except as explicitly defined by the engine:

- `TELL`: emits a narrative event (what/why/outcome/level).
- `SNAP`: snapshots selected symbols; supports delta and redact lists.
- `MILESTONE`: semantic checkpoint message (sugar for `TELL` with `type="milestone"`).

## WITH block

- `WITH {defaults}:` applies key/value defaults (e.g., `endpoint=...`) to enclosed `RUN`/`USE`/
  `CAPTURE` until the block end.
- Nested `WITH` blocks shadow outer defaults; scope does not leak across the closing boundary.

## PAR / JOIN concurrency

`PAR` and `JOIN` define deterministic concurrency:

- `PAR:` launches one-or-more `USE` statements concurrently in **lexical order**; each child gets
  index `[0..n-1]`.
- `JOIN:` is the first legal point to `CAPTURE` results of prior PAR tools.
- `CAPTURE` order MUST follow the **lexical order** of the corresponding `USE` statements,
  regardless of completion time.
- If any child fails hard, `JOIN` raises a composite error including the first hard error and
  aggregates others as `suppressed`.

Engines SHOULD log deterministic span indices and MUST NOT perform speculative execution.

## FOREACH iteration

`FOREACH` provides deterministic iteration over symbol arrays:

- `FOREACH item IN ITEMS:` iterates over each element in the `ITEMS` array in **index order**.
- The loop variable (`item`) is bound to the current element for each iteration.
- Loop body statements execute sequentially; the engine MUST NOT parallelize unless explicitly
  wrapped in `PAR`.
- If `ITEMS` is empty, the loop body is skipped entirely.
- The loop variable is scoped to the block; it is undefined after the closing boundary.

Engines SHOULD expose the current index via a deterministic mechanism (e.g., `_INDEX` symbol).

## TRY / RECOVER error handling

`TRY` and `RECOVER` define structured error handling:

- `TRY:` begins a guarded block; statements execute until completion or first hard error.
- `RECOVER (err):` binds the error to the named variable (`err`) and executes recovery statements.
- If no error occurs, the `RECOVER` block is skipped.
- Recovery statements MAY access the error variable to inspect type, message, or context.
- Nested `TRY` blocks are permitted; inner handlers take precedence.

Error binding follows engine-defined schema; at minimum, engines MUST expose `err.type` and
`err.message`.

## Invocation syntax (normative)

The following describes statement syntax at a human-readable level. The authoritative grammar is
in **05 Grammar**.

```text
RUN `process_id` [where: k1=V1, ...]

USE `tool_name` [where: k1=V1, ...] [(atomic[, timeout_ms=NUM][, retry=NUM])]

CAPTURE S1[, S2 ...] from `tool_name` [map: "path1"→S1, "path2?"→S2 ...]
  - Optional field via suffix '?'; no error if missing; symbol unchanged.

SET SYMBOL := VALUE [(from SOURCE)]
  - SOURCE ∈ { `tool`, INP, UpperSym, "Agent Inference" }

UNSET SYMBOL

RETURN: SYMBOL[, SYMBOL...]
RETURN: key=VALUE[, key=VALUE ...]
  - VALUE may be an artifact reference: {"$artifact":"SYMBOL","hash":"sha256:..."}.

ASSERT <condition>
ASSERT ALL: [ <condition>, <condition>, ... ]

TELL "message" [why:SYMBOL] [level={brief|full}] [outcome:"text"]
MILESTONE "title"

SNAP [SYM1, SYM2 ...] [delta=true|false] [redact=[SYM_A, SYM_B ...]]
```

## Arguments and values

```yaml
arguments:
  allowed_values:
    - String
    - Number
    - Boolean
    - JSON
    - UpperSym
    - <PLACEHOLDER>
    - enum(V1,V2,...)

  choice_sets: "{V1|V2|...} allowed in spec text where indicated; engine turns into enum() at compile time."
  const_refs: "UpperSym MAY appear inside JSON objects/arrays and are resolved from <constants>."
  enums: "enum(A,B,...) becomes a choice set for validation."
```

## Placeholder resolution

```yaml
placeholder_resolution:
  order: [INP, CONSTANTS, RUNTIME, Agent Inference (only if allowed)]
  allow_agent_inference_placeholders: false
```

Rules:

- Unresolved placeholder → `AG-006`.
- If inference occurs under a non-strict policy, the engine MUST emit `AG-W03` with the inferred
  value and a deterministic input hash in the invocation log.

## Naming policy

- IDs/keys MUST be lowercase.
- Symbols MUST be `UPPER_SNAKE`.
- Reserved words cannot be used as IDs/keys/symbols (`AG-002`).

## Safety policy

```yaml
safety_policy:
  defaults: { THR: 0.90, HARM_THR: 0.40 }
  predicate: HARM := (HSC ≥ HARM_THR) OR (STY_JSON.policy_violation = true)
  decision:
    IF TS ≥ THR AND HARM=false: REC := "PROCEED"
    ELSE IF NPR != "": REC := "PROCEED_WITH_CAUTION"
    ELSE: REC := "HOLD_FOR_REVIEW"
  log_thresholds: true
  randomness: forbidden unless seed provided; otherwise AG-022 (RandomnessPolicy) if policy enabled.
```