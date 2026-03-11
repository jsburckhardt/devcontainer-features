<format id="TABLE_PROCESS_RESULTS_V1" name="Process Results Table" purpose="Summarize process execution across processes in lexical order.">
- Output wrapper starts with a fenced block whose info string is exactly `format:TABLE_PROCESS_RESULTS_V1`.
- Header row MUST be:
  | ProcessId | Name | Status | StartedAt | EndedAt | DurationMs | Outcome | Artifacts | Errors |
- Example row:
  | <PROCESS_ID> | <PROCESS_NAME> | <STATUS> | <STARTED_AT> | <ENDED_AT> | <DURATION_MS> | <OUTCOME> | <ARTIFACTS> | <ERRORS> |
WHERE:
- <PROCESS_ID> is String.
- <PROCESS_NAME> is String.
- <STATUS> is one of: PENDING, RUNNING, OK, WARN, ERROR.
- <STARTED_AT> is ISO8601.
- <ENDED_AT> is ISO8601.
- <DURATION_MS> is Integer.
- <OUTCOME> is String.
- <ARTIFACTS> is String.
- <ERRORS> is String.
</format>
