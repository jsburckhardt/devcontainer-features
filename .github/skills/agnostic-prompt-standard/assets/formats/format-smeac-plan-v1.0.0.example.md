```markdown
<format id="SMEAC_PLAN_V1" name="SMEAC Plan" purpose="Structured planning brief covering situation, mission, execution phases, logistics, and command.">
# <PLAN_TITLE>

**Prepared:** <TIMESTAMP>
**Classification:** <CLASSIFICATION>

---

## 1. Situation

### Operating Environment
<OPERATING_ENVIRONMENT>

### Current State
<CURRENT_STATE>

### Challenges & Obstacles
- <OBSTACLE>: <OBSTACLE_ASSESSMENT>
…

### Supporting Factors
- **Higher intent:** <HIGHER_INTENT>
- **Adjacent efforts:** <ADJACENT_EFFORTS>
- **Supporting resources:** <SUPPORTING_RESOURCES>

### Assumptions
- <ASSUMPTION>
…

### Constraints & Limitations
- **Constraint:** <CONSTRAINT>
- **Limitation:** <LIMITATION>
…

---

## 2. Mission

<MISSION_STATEMENT>

### Task
<TASK>

### Purpose
<PURPOSE>

### End State
<END_STATE>

---

## 3. Execution

### Leader's Intent
<LEADERS_INTENT>

### Concept of Operations
<CONCEPT_OF_OPERATIONS>

### Phases

#### Phase <PHASE_NUMBER>: <PHASE_NAME>
- **Objective:** <PHASE_OBJECTIVE>
- **Key tasks:**
  - <PHASE_TASK>
  …
- **Success criteria:** <PHASE_SUCCESS_CRITERIA>
- **Transition trigger:** <TRANSITION_TRIGGER>
…

### Coordinating Instructions
- **Timeline:** <TIMELINE>
- **Boundaries:** <BOUNDARIES>
- **Operating guidelines:** <OPERATING_GUIDELINES>
- **Risk mitigation:** <RISK_MITIGATION>

### Contingencies
- **If** <CONTINGENCY_CONDITION> **then** <CONTINGENCY_ACTION>
…

---

## 4. Admin & Logistics

### Resources Required
| Resource | Quantity | Source | Status |
| --- | --- | --- | --- |
| <RESOURCE_NAME> | <RESOURCE_QUANTITY> | <RESOURCE_SOURCE> | <RESOURCE_STATUS> |
…

### Supply & Provisioning
<SUPPLY_PLAN>

### Transportation & Movement
<TRANSPORTATION_PLAN>

### Sustainment
<SUSTAINMENT_PLAN>

### Recovery / Rollback Plan
<ROLLBACK_PLAN>

---

## 5. Command & Signal

### Decision Chain
1. <PRIMARY_LEAD>
2. <SUCCESSOR_LEAD>
…

### Communications Plan
| Channel | Medium | Purpose | Cadence |
| --- | --- | --- | --- |
| <CHANNEL_NAME> | <CHANNEL_MEDIUM> | <CHANNEL_PURPOSE> | <CHANNEL_CADENCE> |
…

### Reporting Requirements
- <REPORTING_REQUIREMENT>
…

### Decision Authority
| Decision | Authority | Escalation |
| --- | --- | --- |
| <DECISION_TYPE> | <DECISION_AUTHORITY> | <ESCALATION_PATH> |
…

### Acknowledgement
All parties MUST acknowledge receipt and understanding of this plan.

---

WHERE:
- <PLAN_TITLE> is String; concise name for the plan or operation.
- <TIMESTAMP> is ISO8601; date/time the plan was prepared.
- <CLASSIFICATION> is one of: PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED.
- <OPERATING_ENVIRONMENT> is String; 1–3 sentences; describes the domain, environment, or scope of operations.
- <CURRENT_STATE> is String; 1–3 sentences; factual assessment of the current situation and relevant background.
- <OBSTACLE> is String; name or category of a challenge, competitor, blocker, or risk.
- <OBSTACLE_ASSESSMENT> is String; impact, likelihood, and probable course of action for the obstacle.
- <HIGHER_INTENT> is String; the overarching goal from leadership or strategy that this plan supports.
- <ADJACENT_EFFORTS> is String; related parallel initiatives, teams, or workstreams and their relevance.
- <SUPPORTING_RESOURCES> is String; available assets, teams, tools, or capabilities that can be leveraged.
- <ASSUMPTION> is String; a condition assumed to be true for planning purposes; must be validated before or during execution.
- <CONSTRAINT> is String; a restriction imposed by leadership or policy that limits freedom of action (MUST do or MUST NOT do).
- <LIMITATION> is String; a shortcoming in capability or resource that restricts options.
- <MISSION_STATEMENT> is String; single sentence; answers who, what, when, where, and why; active voice; present tense.
- <TASK> is String; the specific action to be accomplished; measurable and time-bound.
- <PURPOSE> is String; the reason the task matters; links to higher intent.
- <END_STATE> is String; describes the desired conditions when the mission is complete.
- <LEADERS_INTENT> is String; 2–4 sentences; states the purpose, key tasks, and desired end state in the leader's own framing.
- <CONCEPT_OF_OPERATIONS> is String; 2–5 sentences; high-level approach describing how phases combine to achieve the mission.
- <PHASE_NUMBER> is Integer; sequential from 1.
- <PHASE_NAME> is String; short descriptive name for the phase (e.g., "Preparation", "Execution", "Consolidation").
- <PHASE_OBJECTIVE> is String; what this phase aims to achieve.
- <PHASE_TASK> is String; a discrete task within the phase; actionable and assignable.
- <PHASE_SUCCESS_CRITERIA> is String; measurable conditions that indicate the phase objective is met.
- <TRANSITION_TRIGGER> is String; the event or condition that signals transition to the next phase; last phase uses "Mission complete" or equivalent.
- <TIMELINE> is String; key dates, deadlines, or time windows for execution.
- <BOUNDARIES> is String; scope limits, geographic or logical boundaries, and deconfliction lines.
- <OPERATING_GUIDELINES> is String; guidelines governing actions, decisions, and interactions during execution.
- <RISK_MITIGATION> is String; identified risks and their mitigations.
- <CONTINGENCY_CONDITION> is String; a specific adverse event or deviation from plan.
- <CONTINGENCY_ACTION> is String; the prescribed response to the contingency condition.
- <RESOURCE_NAME> is String; name or type of resource (personnel, equipment, budget, tooling, etc.).
- <RESOURCE_QUANTITY> is String; amount or count required.
- <RESOURCE_SOURCE> is String; where the resource comes from (team, vendor, budget line, etc.).
- <RESOURCE_STATUS> is one of: AVAILABLE, REQUESTED, PENDING, AT_RISK, UNAVAILABLE.
- <SUPPLY_PLAN> is String; 1–3 sentences; how consumable resources will be sourced and distributed.
- <TRANSPORTATION_PLAN> is String; 1–3 sentences; how assets, deliverables, or personnel move between locations or stages.
- <SUSTAINMENT_PLAN> is String; 1–3 sentences; how the operation will be maintained over its duration.
- <ROLLBACK_PLAN> is String; 1–3 sentences; procedure for reverting or recovering if execution fails.
- <PRIMARY_LEAD> is String; name and role of the primary decision-maker.
- <SUCCESSOR_LEAD> is String; name and role of the next in line; at least one successor required.
- <CHANNEL_NAME> is String; identifier for the communication channel (e.g., "Primary", "Backup", "Emergency").
- <CHANNEL_MEDIUM> is String; the medium of communication (e.g., "Slack", "Email", "Teams", "In-person").
- <CHANNEL_PURPOSE> is String; what this channel is used for (e.g., "Coordination", "Status updates", "Escalation").
- <CHANNEL_CADENCE> is String; frequency of communication (e.g., "Real-time", "Daily standup", "On event").
- <REPORTING_REQUIREMENT> is String; a specific report, metric, or status update expected during or after execution.
- <DECISION_TYPE> is String; category of decision (e.g., "Go/No-go", "Resource allocation", "Scope change").
- <DECISION_AUTHORITY> is String; who has authority to make this decision.
- <ESCALATION_PATH> is String; who to escalate to if the primary authority is unavailable.
- … denotes repetition; items follow the same pattern for each entry in the section.
</format>
```
