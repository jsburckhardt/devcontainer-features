# 06 Logging and privacy

This document defines the normative logging and redaction requirements for APS executors.

## Logging

```yaml
logging:
  capture_points: [RUN, USE, CAPTURE, SET, UNSET, ASSERT, RETURN, PAR, JOIN, TELL, SNAP]
  include:
    - timestamp
    - process_id
    - step_index
    - action
    - inputs
    - outputs
    - artifacts
    - prior_hash
    - new_hash
    - origin
    - policy_hash
```

## Redaction

Engines MUST enforce:

- Secrets/PII MUST be redacted as `[REDACTED]` (`AG-032`).
- For `SNAP` with `redact=[SYMS]`, engines MUST zeroize the listed symbols in `prior_state`,
  `new_state`, and `artifacts`.
- If `TELL` uses `why:SYMBOL` and `SYMBOL` is redacted, only the symbol name may appear; its
  content MUST NOT.