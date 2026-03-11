# 01 Vocabulary

This document defines the **normative language** and the authoring vocabulary constraints used
throughout APS.

## Normative terms

RFC 2119 terms **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, **MAY** are normative.

## Text types

The following text types are normative and MAY be used to classify prose within a prompt or its
supporting documentation:

```yaml
text_types:
  - Procedure
  - Description
  - Safety
  - Observation
  - Requirement
  - Definition
  - Declaration
  - Constraint
  - Conditional
```

## Tense and voice

```yaml
tense_voice:
  allowed_verbs:
    - infinitive
    - imperative
    - simple_present
    - simple_past
    - simple_future_will
  disallowed:
    - progressive
    - perfect
    - going_to_future
  procedures: active_only
  descriptions: passive_only_if_agent_unknown
```

## Dictionary and terminology

- Authors SHOULD use approved words from a Dictionary with approved POS/meaning.
- Technical terms are allowed if defined on first use and linked by `term_id` and `lexicon_edition`.
- Multi-word nouns MUST be ≤ 3 words unless explicitly whitelisted.

## Identifiers

In general, specification identifiers SHOULD be short, ASCII, and consistent.

```yaml
identifiers:
  # Applies to glossary / lexicon identifiers and similar spec IDs.
  spec_ids:
    style: UpperCamel_Segments
    ascii_only: true
    no_hyphens: true
    max_length: 30
```

> NOTE: Process/tool identifiers, symbols, and placeholders used by the agentic control DSL have
> their own stricter patterns; see **03 Agentic control**.

## Sentence, paragraph, and list limits

```yaml
sentence_limits:
  procedures: 20
  descriptions: 25

paragraph_limits:
  sentences_max: 6
  one_topic: true

lists:
  steps_numbered: true
  supportive_bullets: true
```

## Numbers, units, and time

```yaml
numbers_units_time:
  numbers:
    decimals: "."
    thousands: "U+2009 (thin space)"

  units:
    format: "<number><space><unit>"
    percent: "50 %"
    temperature: "60 °C"
    symbols: middle_dot_between_compounds # U+00B7
    catalog: units.json (project)

  time:
    iso8601: true
    default_tz: "Z"
    local_times_require_offset_or_iana: true
```

## Safety vocabulary

```yaml
safety:
  taxonomy: [WARNING, CAUTION, NOTICE]
  wrapper: SAF
  imperative_required: true
```

## `<instructions>` line discipline

Inside `<instructions>`:

- Instructions MUST use **one directive per line**.
- Each line MUST be a single imperative or declarative that changes system behavior.
- Multiple sentences per line are forbidden.
- Blank lines inside `<instructions>` are forbidden.

The engine/LSP MUST raise `AG-033` when this policy is violated.
