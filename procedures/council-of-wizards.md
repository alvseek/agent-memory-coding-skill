# Council of Wizards Protocol

Orchestrate multiple `/high-wizard` sub-plans into a cohesive feature delivery. Decomposes a feature into requirements, evaluates if multi-plan orchestration is needed, breaks requirements into sub-plans with integration contracts, and tracks parallel execution.

## Arguments

`$ARGUMENTS`

- `/council-of-wizards [feature description]` → Create Council plan for the given feature
- `/council-of-wizards` → Will ask for feature description

If no arguments provided, ask: "What feature should I create a Council of Wizards plan for?"

---

## Procedure

*This is a Level 2 wizard protocol. It orchestrates multiple Level 1 (`/high-wizard` or `/quick-wizard`) sub-plans. The key flow is: WAIT Options → Requirements → Scope Gate → Decompose → Contracts → Dependencies → Execute → Complete.*

### Step 1: Read Template

Read the [Council of Wizards Plan Template](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md) file

### Step 2: Check Date

Get current date for file naming:
`date '+%Y-%m-%d %H:%M'`

### Step 3: Create Council Folder + Copy Template

Create the council plan folder and copy the template as `core-plan.md` inside it:
```
mkdir -p ./plans/[YYYY-MM-DD]-[project]-[feature]
cp {source} ./plans/[YYYY-MM-DD]-[project]-[feature]/core-plan.md
```

### Step 4: Fill Feature Info

Fill the [Feature Info](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#feature-info) section (Project, Date, Agent, Feature description)

### Step 5: Investigate Feature + Prepare WAIT Options

Investigate the feature to understand what [USER-NAME] wants delivered. This happens BEFORE any table filling — the agent must align understanding with [USER-NAME] first.

**Investigation approach:**
1. **Understand the feature** — What is being asked? What is the end result?
2. **Identify all parts** — What distinct pieces need to be built? (data models, APIs, UI, infrastructure, migrations, etc.)
3. **Research context** — Scan relevant codebase, architecture, and existing patterns

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting requirement decisions.

Be exhaustive — missing a requirement here means a missing sub-plan later.

### Step 6: Present Requirements WAIT Options

Present the requirements to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Based on my investigation, here's what I think you want"

STOP. Present to [USER-NAME] for review. Do NOT fill any tables or proceed until [USER-NAME] confirms the requirements.

### Step 7: Fill Requirements + Scope Gate

After [USER-NAME] confirms the WAIT Options, fill the formal plan sections:

1. **Fill Requirements Breakdown table** — Convert confirmed WAIT Options into the [Requirements Breakdown](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#requirements-breakdown) table (R1, R2, R3... with descriptions)

2. **Fill Scope Gate** — Evaluate the confirmed requirements against the scope gate criteria:

   **Council is needed when ANY of these are true:**
   - Feature has **independently shippable sub-deliverables** that build on each other
   - Feature requires **integration contracts** between parts (one plan produces what another consumes)
   - Scope is **too large for a single `/high-wizard`** to cover without losing detail

   Fill the [Scope Gate](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#scope-gate) section with assessment.

3. **Present both** to [USER-NAME] for review.

STOP. Present to [USER-NAME] for review. Do NOT proceed to sub-plan decomposition until [USER-NAME] confirms the requirements are complete and the scope gate assessment is correct.

**If scope gate fails** (single `/high-wizard` suffices):
1. Tell [USER-NAME]: "This feature fits a single `/high-wizard`. De-escalating."
2. Delete the council plan file
3. Launch `/high-wizard` with the feature context — the requirements gathered via WAIT Options carry forward as investigation context
4. STOP this procedure

### Step 8: Investigate & Collect Decomposition Decisions

Before decomposing into sub-plans, investigate the codebase and feature context to collect decisions that will shape the decomposition. These are feature-level decisions about HOW to break the work apart.

**Investigation checklist (in order):**
1. **Grouping strategy** — How should requirements be grouped into sub-plans? (by domain, by layer, by dependency, by team?)
2. **Protocol choice** — Which sub-plans are complex enough for `/high-wizard` vs simple enough for `/quick-wizard`?
3. **Integration points** — What data/interfaces flow between potential sub-plans? What contract format fits?
4. **Parallel strategy** — Which sub-plans can run concurrently? Any hard sequential dependencies?
5. **Conflicts and constraints** — Are there requirements that must be in the same sub-plan? Cross-cutting concerns?

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting decomposition decisions.

### Step 9: Present Decomposition WAIT Options

Present the decomposition decisions to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Here are the decomposition decisions I need before breaking this into sub-plans"

STOP. Present to [USER-NAME] for review. Do NOT proceed to decomposition until decisions are confirmed.

After confirmation, fill the [Confirmed Decisions](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#confirmed-decisions) table with all confirmed decisions (with any changes [USER-NAME] made). Include the meaningful reasons — this IS the analysis record.

### Step 10: Sub-Plan Decomposition

Group the confirmed requirements into sub-plans, **informed by the confirmed decisions**. Each sub-plan should be a coherent, independently shippable deliverable.

**Guidelines:**
- Each sub-plan groups related requirements that naturally belong together
- Choose protocol per sub-plan: `/high-wizard` for complex deliverables, `/quick-wizard` for simple ones
- Name sub-plan files inside the council folder: `SP-[N]-[subplan-name].md` (e.g., `SP-1-api-endpoints.md`)
- Assign IDs: SP-1, SP-2, SP-3...

Fill the [Sub-Plans Table](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#sub-plans-table).

**CRITICAL**: If any NEW decision is discovered during decomposition that was not covered in Step 9, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

### Step 11: Integration Contracts

Identify what data, interfaces, or outputs flow between sub-plans. For each integration point:

1. **Identify the flow** — What does Plan A produce that Plan B needs?
2. **Choose format** — Use industry-standard YAML formats:
   - **OpenAPI** — for REST API contracts
   - **AsyncAPI** — for event/message contracts
   - **JSON Schema** — for data shape contracts
   - **Other YAML** — for custom contracts (config files, migration scripts, etc.)
3. **Create contract file** — Write the YAML contract file at `contracts/[contract-name].yaml` inside the council folder
4. **Fill contracts table** — Link each contract in the [Integration Contracts](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#integration-contracts) table

Create the contracts directory inside the council folder if needed:
`mkdir -p ./plans/[council-folder]/contracts`

*If no integration contracts are needed (sub-plans are independent), note this in the section and remove the table.*

**CRITICAL**: If any NEW decision is discovered during contract creation that was not covered in Step 9, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

### Step 12: Dependency Graph

Create a mermaid dependency graph showing sub-plan relationships.

**Guidelines:**
- Draw arrows from dependencies to dependents (SP-1 → SP-2 means SP-2 depends on SP-1)
- Identify **parallel opportunities** — sub-plans with no dependency between them can run concurrently in separate agent sessions
- Identify **critical path** — the longest sequential chain determines minimum total time

Fill the [Dependency Graph](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#dependency-graph) section with the mermaid diagram, parallel opportunities, and critical path.

**CRITICAL**: Same rule — if any NEW decision is discovered during dependency analysis, STOP immediately and present it before continuing.

### Step 13: Present Decomposition

Present the sub-plans table, integration contracts, and dependency graph to [USER-NAME].

**Response format:**
```
Here's the feature decomposition:

**Sub-Plans:** [count] sub-plans identified
[Show sub-plans table]

**Integration Contracts:** [count] contracts
[Show contracts table or "None"]

**Dependency Graph:**
[Show mermaid diagram]
[Parallel opportunities]
[Critical path]

Review and confirm, or suggest changes.
```

STOP. Present to [USER-NAME] for review. Do NOT proceed until confirmed. If [USER-NAME] changes the decomposition, update all affected sections (sub-plans table, contracts, dependency graph).

### Step 14: Fill Execution Log

Create placeholder rows in the [Execution Log](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#execution-log) for each sub-plan from the confirmed Sub-Plans Table.

### Step 15: Final Review

Present the complete council plan to [USER-NAME].

STOP. Wait for instruction to begin executing sub-plans.

### Step 16: Execute Sub-Plans

After [USER-NAME] instructs to start, execute sub-plans following the dependency graph order.

**For each sub-plan:**
1. Check dependency graph — are all prerequisite sub-plans DONE?
2. If prerequisites met, launch the sub-plan using its designated protocol (`/high-wizard` or `/quick-wizard`). **Important**: The sub-plan's plan file must be created at the path specified in the Sub-Plans Table (inside the council folder), overriding the protocol's default `plans/` location.
3. Update the Execution Log: status → IN PROGRESS, record start date
4. After sub-plan completes, update: status → DONE, record completion date
5. If sub-plan is blocked, update: status → BLOCKED, record reason in Notes

**Parallel execution:**
- If the dependency graph shows sub-plans that can run in parallel, inform [USER-NAME]: "SP-X and SP-Y can run in parallel. You can launch separate agent sessions to work on them concurrently."
- The protocol identifies parallel opportunities but does NOT enforce parallel execution — [USER-NAME] decides whether to run them concurrently

**Between sub-plans:**
- Verify integration contracts are satisfied before starting dependent sub-plans
- Check the "Verified" column in the Integration Contracts table

### Step 17: Feature Completion

After all sub-plans are DONE:
1. Run through the [Feature Completion Checklist](//@agent-memory/control-files/plan-templates/council-of-wizards-plan-template.md#feature-completion-checklist)
2. Verify all integration contracts (check "Verified" column)
3. Present completion summary to [USER-NAME]

### Step 18: Move Council Folder to Completed

After [USER-NAME] confirms feature is complete, move the entire council folder (core plan + sub-plans + contracts):
`mkdir -p ./plans/completed && mv ./plans/[council-folder] ./plans/completed/[council-folder]`

**Note**: Episodic memory links to the plan will break after moving. This is accepted — completed plans are archival.

---
