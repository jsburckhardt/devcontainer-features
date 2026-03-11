# 07 Error taxonomy

This document defines the normative error and warning codes.

## Errors

```yaml
errors:
  hard:
    - { code: AG-001, name: UndefinedSymbol, desc: Symbol not defined in <constants> or <runtime>. }
    - { code: AG-002, name: ReservedTokenMisuse, desc: Reserved word used as ID/Key/Symbol. }
    - { code: AG-003, name: InvalidId, desc: Process/tool/key not matching naming regex. }
    - { code: AG-004, name: ProcessIdMismatch, desc: RUN references missing <process id="…">. }
    - { code: AG-006, name: UnresolvedPlaceholder, desc: Placeholder could not be resolved. }
    - { code: AG-007, name: BadJSON, desc: Invalid JSON value or pair. }
    - { code: AG-008, name: CaptureMissing, desc: CAPTURE references unknown/never-executed tool. }
    - { code: AG-009, name: TagMismatch, desc: Unbalanced or wrong closing tag. }
    - { code: AG-010, name: CommentDetected, desc: Comment present in any section. }
    - { code: AG-011, name: TabDetected, desc: Tab characters present. }
    - { code: AG-012, name: KeyOrder, desc: Keys in where: not lexicographic. }
    - { code: AG-013, name: DuplicateSymbol, desc: Symbol redefined with incompatible type/origin. }
    - { code: AG-014, name: TimeFormat, desc: Non-ISO 8601 time/offset where required. }
    - { code: AG-015, name: CasePolicy, desc: Non-lowercase booleans or non-double-quoted strings. }
    - { code: AG-016, name: ProcessNameAttrMismatch, desc: <process> Name attr missing/malformed. }
    - { code: AG-017, name: ToolPolicy, desc: Tools used in <triggers>. }
    - { code: AG-018, name: ConcurrencyPolicy, desc: PAR/JOIN misuse or nondeterministic ordering. }
    - { code: AG-019, name: ForbiddenSymbolOrigin, desc: SET origin missing/invalid. }
    - { code: AG-021, name: STEValidationFailed, desc: ste=true text failed STE lints. }
    - { code: AG-022, name: RandomnessPolicy, desc: Randomness used without seed where policy forbids. }
    - { code: AG-023, name: WithScopeError, desc: WITH defaults malformed or leaked across scope boundary. }
    - { code: AG-024, name: AliasMapError, desc: ALIAS mapping invalid or collides with symbol names. }
    - { code: AG-027, name: TimeoutRetryPolicy, desc: timeout_ms/retry invalid type/range. }
    - { code: AG-028, name: CapturePathError, desc: CAPTURE map path invalid or type coercion failed. }
    - { code: AG-029, name: AssertInvalid, desc: ASSERT expression invalid or unsafely side-effecting. }
    - { code: AG-030, name: SemicolonDetected, desc: Semicolon ';' used where newline termination is required. }
    - { code: AG-031, name: PaddingWhitespace, desc: Excess inter-token spaces detected; exactly one ASCII space required in compiled form. }
    - { code: AG-032, name: SensitiveInLog, desc: Secrets/PII leaked in logs or errors. }
    - { code: AG-033, name: InstructionsLinePolicy, desc: Multiple sentences per line, blank lines, or non-directive lines present in <instructions>. }
    - { code: AG-034, name: PredefinedToolCollision, desc: Conflicting tool signatures across host and predefinedTools.json. }
    - { code: AG-035, name: InPromptConfigOrImports, desc: Presence of <config> or <import> tags in prompt. }
    - { code: AG-036, name: FormatContractViolation, desc: Output does not match the referenced <format id="…"> template (missing headers/columns/markers/placeholders not resolved). }
    - { code: AG-037, name: DictReferenceForbidden, desc: DICT-style reference @"…" used; constants must be defined in <constants>. }
    - { code: AG-038, name: DictInConfigForbidden, desc: config.json contains a DICT key; migrate constants to <constants>. }
    - { code: AG-039, name: FormatUndefined, desc: A step references a format id that is not defined in <formats>. }
    - { code: AG-040, name: FormatFenceError, desc: Missing or malformed ```format:<ID> fenced block; multiple format blocks or surrounding prose where a single block is required. }
    - { code: AG-041, name: FormatWhereMissing, desc: WHERE: section missing or not uppercase when placeholders are present (or required by policy). }
    - { code: AG-042, name: PlaceholderMismatch, desc: Placeholder appears in body but not in WHERE, or defined in WHERE but not present in body. }
    - { code: AG-043, name: PlaceholderStyleError, desc: Placeholder not in <UPPER_SNAKE> form or not wrapped in angle brackets. }
    - { code: AG-044, name: ProcessArgsMismatch, desc: RUN statement arguments do not match the target process signature (missing, extra, or type-incompatible arguments). }
    - { code: AG-045, name: BlockConstantUnterminated, desc: Block constant missing closing delimiter line >>. }
    - { code: AG-046, name: BlockConstantTypeUnknown, desc: Block constant uses unknown <BLOCK_TYPE>; expected JSON, TEXT, YAML, or CSV. }
    - { code: AG-047, name: BadYAML, desc: Invalid YAML block constant body. }
    - { code: AG-048, name: BadCSV, desc: Invalid CSV block constant body (parse failure, invalid header, ragged rows, or invalid cell). }

  warnings:
    - { code: AG-W01, name: SymbolNotUsed, desc: Defined but never used. }
    - { code: AG-W02, name: LaxTime, desc: Step without explicit time where policy requires. }
    - { code: AG-W03, name: HeuristicInference, desc: Placeholder resolved by Agent Inference under strict policy. }
```

## Required behaviors

- Engines MUST treat all `errors.hard` codes as fatal for the current compile/run.
- Engines MAY continue on `warnings`, but MUST surface them to the caller.
