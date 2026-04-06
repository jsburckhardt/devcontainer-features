<instructions>
You MUST load this guide before you author coordinator and worker agents.
You MUST model portable multi-agent systems as one coordinator and one or more leaf workers.
You MUST define the worker <input> block as the public request contract into the worker.
You MUST mirror each worker <input> field in the caller dispatch process arguments.
You MUST define a worker response contract in <formats> and capture it in the caller.
You MUST keep platform-specific invocation syntax inside the caller dispatch layer only.
You MUST use explicit allowlists for worker selection and tool access.
You MUST keep worker results task-bounded, typed, and brief.
You SHOULD use handoffs instead of nested worker spawning when a platform supports handoffs.
You SHOULD treat undocumented nested delegation as unsupported for portable APS authoring.
You MUST treat Claude Code workers as leaf workers.
You SHOULD treat VS Code Copilot and OpenCode workers as leaf workers for portable APS authoring.
</instructions>

<constants>
GUIDE_VERSION: "1.0.0"

PLATFORM_CAPABILITY_MATRIX: CSV<<
platform,coordinator_role,worker_role,documented_depth_policy,invocation_surface,notes
claude-code,main-thread agent only,markdown subagent,depth-1-only,Agent,"Workers cannot spawn workers."
vscode-copilot,main chat agent or prompt,subagent or custom agent worker,portable-depth-1,agent/runSubagent,"Custom-agent subagents are experimental and nested delegation is not documented."
opencode,primary agent,mode=subagent worker,portable-depth-1,Task,"Primary/subagent roles are documented and nested delegation is not documented."
generic,host-defined or manual APS coordinator,host-defined or external worker,host-defined,host-defined,"Use explicit APS dispatch processes when host behavior is unclear."
>>

REQUEST_INTERFACE_RULES: TEXT<<
1. The worker <input> block is the public interface into the worker.
2. The caller dispatch process MUST accept the same fields, names, and meanings.
3. If a platform needs renamed fields, keep the rename in the dispatch layer only.
4. Do not hide required worker inputs inside free-form prompt text.
5. Keep request types stable across platforms.
>>

RESPONSE_INTERFACE_RULES: TEXT<<
1. The worker MUST return a typed result that matches a <format> contract.
2. The caller MUST capture the worker result before the next step starts.
3. Keep summaries brief and task-bounded.
4. Do not leak platform-only metadata unless the caller explicitly asks for it.
>>

PORTABLE_PATTERNS: JSON<<
{
  "coordinator_worker": {
    "description": "One coordinator dispatches one worker and integrates the worker result.",
    "best_for": ["single specialty task", "strong contract boundaries"]
  },
  "fan_out_review": {
    "description": "One coordinator dispatches multiple leaf workers in parallel and then compares typed results.",
    "best_for": ["research", "review", "verification"]
  },
  "sequential_handoff": {
    "description": "One worker finishes, returns a typed result, and the coordinator hands off the next step to a different worker.",
    "best_for": ["plan -> implement", "implement -> review"]
  }
}
>>

ANTI_PATTERNS: TEXT<<
- Worker-to-worker recursion without a documented host contract.
- Free-form worker prompts with hidden required fields.
- Caller processes that rename or reshape worker inputs in multiple places.
- Worker outputs that mix summary text, hidden state, and untyped data.
- Broad tool access for narrow workers.
>>

APS_INTERFACE_EXAMPLE: TEXT<<
Worker contract:
<input>
TICKET_ID: String
TARGET_PATHS: String[]
</input>

Caller dispatch process:
<process id="dispatch-review" name="Dispatch review" args="TICKET_ID: String, TARGET_PATHS: String[]">
USE `Agent` where: description="Review the requested files", prompt="Review the requested files", worker="reviewer"
SET WORKER_REQUEST := { TICKET_ID: TICKET_ID, TARGET_PATHS: TARGET_PATHS }
CAPTURE REVIEW_RESULT from `reviewer`
RETURN: REVIEW_RESULT
</process>

Rule:
- The caller args are the same interface as the worker input.
- The caller is responsible for the platform-specific call surface.
- The worker returns a typed result that the caller captures.
>>

BIDIRECTIONAL_CONTRACT_RULE: TEXT<<
Request flow: caller process args -> worker <input>.
Response flow: worker <format> result -> caller capture variables.
The contract is bidirectional only when the caller defines both mappings explicitly.
>>
</constants>

<formats>
<format id="SUBAGENT_ARCHITECTURE_SPEC_V1" name="Subagent Architecture Spec" purpose="Describe a coordinator plus worker architecture with explicit request and response contracts.">
# Subagent Architecture Spec: <ARCHITECTURE_NAME>

## Coordinator
- Role: <COORDINATOR_ROLE>
- Dispatch surface: <DISPATCH_SURFACE>
- Depth policy: <DEPTH_POLICY>

## Workers
| Worker | Role | Input contract | Output contract | Allowed tools | Notes |
|--------|------|----------------|-----------------|---------------|-------|
| <WORKER_NAME> | <WORKER_ROLE> | <INPUT_CONTRACT_ID> | <OUTPUT_CONTRACT_ID> | <ALLOWED_TOOLS> | <WORKER_NOTES> |

## Request and response mapping
<REQUEST_RESPONSE_MAP>

## Failure policy
<FAILURE_POLICY>

WHERE:
- <ALLOWED_TOOLS> is String; comma-separated logical or host tool ids allowed for the worker.
- <ARCHITECTURE_NAME> is String; descriptive name for the coordinator/worker design.
- <COORDINATOR_ROLE> is String; the coordinator responsibility statement.
- <DEPTH_POLICY> is String; one of depth-1-only, portable-depth-1, host-defined.
- <DISPATCH_SURFACE> is String; host invocation surface such as Agent, agent/runSubagent, Task, or manual APS process.
- <FAILURE_POLICY> is Markdown; what the coordinator does when a worker fails, times out, or returns invalid data.
- <INPUT_CONTRACT_ID> is String; id or label of the worker request contract.
- <OUTPUT_CONTRACT_ID> is String; id or label of the worker response contract.
- <REQUEST_RESPONSE_MAP> is Markdown; explicit mapping from caller args to worker input and from worker result to caller capture.
- <WORKER_NAME> is String; worker identifier.
- <WORKER_NOTES> is String; short notes about visibility, allowlists, or platform limits.
- <WORKER_ROLE> is String; worker responsibility statement.
</format>

<format id="SUBAGENT_CONTRACT_CHECKLIST_V1" name="Subagent Contract Checklist" purpose="Review checklist for portable coordinator/worker authoring.">
# Subagent Contract Checklist

- [ ] The coordinator is the single dispatch owner.
- [ ] Each worker has an explicit APS <input> contract.
- [ ] Each caller dispatch process mirrors the worker input fields one-for-one.
- [ ] Each worker returns a typed <format> result.
- [ ] The caller captures the worker result before the next step starts.
- [ ] Nested delegation is either documented by the host or avoided.
- [ ] Worker tool access uses least privilege.
- [ ] Worker visibility and allowlists are explicit.
- [ ] Platform-only routing details stay outside the portable contract.

WHERE:
- This checklist is a fixed review format with no placeholders.
</format>
</formats>
