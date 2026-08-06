# Rite of Creation Protocol

Orchestrate an entire project from idea/vision to a working product. Decomposes the project into SDLC phases, selects which phases apply, assigns protocols and agent roles per phase, enforces phase exit criteria, and tracks execution through to project completion.

## Arguments

`$ARGUMENTS`

- `/rite-of-creation [project vision]` → Create Rite plan for the given project
- `/rite-of-creation` → Will ask for project vision

If no arguments provided, ask: "What project do you want to create from scratch?"

---

## Procedure

*This is a Level 3 wizard protocol. It orchestrates SDLC phases where each phase can contain a `/council-of-wizards` (Level 2), `/high-wizard` (Level 1), or `/quick-wizard` (Level 0). The key flow is: Vision → WAIT Options Round 1 (project decisions) → Phase Menu + Scope Gate → WAIT Options Round 2 (phase planning) → Exit Criteria → Dependencies → Execute → Complete.*

### Step 1: Read Template

Read the [Rite of Creation Plan Template](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md) file

### Step 2: Check Date

Get current date for file naming:
`date '+%Y-%m-%d %H:%M'`

### Step 3: Create Rite Folder + Copy Template

Create the rite plan folder and copy the template as `core-plan.md` inside it:
```
mkdir -p ./plans/[YYYY-MM-DD]-[project]-rite-of-creation
cp {source} ./plans/[YYYY-MM-DD]-[project]-rite-of-creation/core-plan.md
```

### Step 4: Fill Project Vision

Fill the [Project Vision](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md#project-vision) section (Project, Date, Agent Role, Vision, Target Users, Success Feeling)

### Step 5: Investigate Project + Prepare WAIT Options Round 1

Investigate to understand what [USER-NAME] wants to build. This happens BEFORE any table filling — the agent must align understanding with [USER-NAME] first.

**Investigation approach:**
1. **Understand the vision** — What is being built? For whom? What problem does it solve?
2. **Identify project scope** — Is this a backend? Frontend? Mobile? Full-stack? What platforms?
3. **Research context** — Does related code exist? Any existing repos, designs, or specifications?
4. **Tech stack considerations** — What languages, frameworks, infrastructure fit this project?
5. **Constraints and risks** — Budget, timeline, technical limitations, team capabilities?

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting project-level decisions.

Be thorough — these are foundational decisions that shape every phase downstream.

### Step 6: Present Project WAIT Options (Round 1)

Present the project decisions to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Based on my investigation, here are the project decisions I need before planning"

STOP. Present to [USER-NAME] for review. Do NOT fill any tables or proceed until [USER-NAME] confirms the project decisions.

### Step 7: Fill Project Decisions + Phase Menu + Scope Gate

After [USER-NAME] confirms the WAIT Options Round 1, fill the formal plan sections:

1. **Fill Project Decisions table** — Record all confirmed decisions (with any changes [USER-NAME] made) in the [Project Decisions](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md#project-decisions) section. Include the meaningful reasons — this IS the analysis record.

2. **Fill Phase Menu** — Based on the confirmed project decisions, propose which SDLC phases apply. For each of the 9 phases:
   - Mark ✓ (included) or — (skipped) with rationale
   - Recommend protocol level: `/council-of-wizards` for complex phases with multiple features, `/high-wizard` for single-deliverable phases, `/quick-wizard` for simple phases
   - Recommend agent role (generic roles, not specific agent names)

3. **Fill Scope Gate** — Evaluate the project against the scope gate criteria:

   **Rite of Creation is needed when ANY of these are true:**
   - Project requires **multiple SDLC phases** (not just one)
   - Project scope spans **architecture + implementation + delivery**
   - **At least one phase requires Council-level coordination** (CoW) — if all phases are HW/QW, a single CoW suffices instead of RoC

   Fill the [Scope Gate](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md#scope-gate) section with assessment.

4. **Present all three** (decisions, phase menu, scope gate) to [USER-NAME] for review.

STOP. Present to [USER-NAME] for review. Do NOT proceed to phase planning until [USER-NAME] confirms the phase menu and scope gate assessment.

**If scope gate fails to Council** (scope is actually a single phase):
1. Tell [USER-NAME]: "This project fits a single `/council-of-wizards`. De-escalating."
2. Delete the rite plan folder
3. Launch `/council-of-wizards` with the project context — the decisions gathered via WAIT Options carry forward
4. STOP this procedure

**If scope gate fails to HW** (scope is a single deliverable):
1. Tell [USER-NAME]: "This project fits a single `/high-wizard`. De-escalating."
2. Delete the rite plan folder
3. Launch `/high-wizard` with the project context — the decisions gathered via WAIT Options carry forward
4. STOP this procedure

### Step 8: Investigate Phases + Prepare WAIT Options Round 2

Before filling exit criteria and dependencies, investigate to collect decisions about HOW to structure the phases. These are phase-level decisions about execution strategy.

**Investigation checklist (in order):**
1. **Phase depth** — For each included phase, how complex is it? Does it need a Council (multiple features) or just a High Wizard (single deliverable)?
2. **Phase overlap** — Which phases can run in parallel or overlap? Any hard sequential dependencies?
3. **Exit criteria customization** — Are the default exit deliverables appropriate, or do they need project-specific adjustments?
4. **Role assignment** — Are the recommended roles appropriate for this project's context?
5. **Conflicts and constraints** — Are there cross-phase concerns that need special handling?

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting phase-level decisions.

### Step 9: Present Phase WAIT Options (Round 2)

Present the phase planning decisions to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Here are the phase planning decisions I need before structuring the phases"

STOP. Present to [USER-NAME] for review. Do NOT proceed until decisions are confirmed.

### Step 10: Fill Phase Exit Criteria + Dependency Graph + Recommended Roles

After [USER-NAME] confirms WAIT Options Round 2:

1. **Fill Phase Exit Criteria** — For each included phase, customize the exit deliverables based on the confirmed decisions. Remove rows for skipped phases.

2. **Fill Phase Dependency Graph** — Create the mermaid diagram showing phase relationships. Remove nodes for skipped phases. Identify parallel opportunities and critical path.

3. **Update Phase Menu** — If Round 2 decisions changed any protocol assignments or role recommendations, update the Phase Menu table.

**CRITICAL**: If any NEW decision is discovered during this step that was not covered in Step 9, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

### Step 11: Present Phase Plan

Present the phase exit criteria, dependency graph, and any updated phase menu entries to [USER-NAME].

**Response format:**
```
Here's the phase plan:

**Phase Exit Criteria:**
[Show exit criteria table]

**Dependency Graph:**
[Show mermaid diagram]
[Parallel opportunities]
[Critical path]

Review and confirm, or suggest changes.
```

STOP. Present to [USER-NAME] for review. Do NOT proceed until confirmed. If [USER-NAME] changes the phase plan, update all affected sections (exit criteria, dependency graph, phase menu).

**CRITICAL**: If any NEW decision is discovered during presentation, STOP immediately and present it before continuing.

### Step 12: Fill Execution Log

Create placeholder rows in the [Execution Log](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md#execution-log) for each included phase from the confirmed Phase Menu. Remove rows for skipped phases.

### Step 13: Self-Review + Auto-Fix

Do a self-review by thinking critically:
- a. Are all necessary phases included? Any missing?
- b. Are exit criteria realistic and complete for each phase?
- c. Do the protocol assignments make sense for each phase's complexity?
- d. Are dependencies correct? Any missing parallel opportunities?
- e. Is there any conflict between project decisions and the phase plan?

**If issues are found**: Auto-fix consistency issues (wrong protocol assignments, dependency errors, incomplete exit criteria) directly in the plan file. For issues that require a NEW decision (missing phases, scope changes), STOP and present to [USER-NAME] using the WAIT Options format before continuing.

**Report**: Briefly list any auto-fixes made. If no issues found, proceed silently to Step 14.

### Step 14: Final Review

Before presenting the plan, double check: are there any unresolved decisions, assumptions, or new concerns that surfaced during writing (Steps 10-12) or self-review (Step 13) that need [USER-NAME]'s input? If yes, present them now with the same decision format (options + confidence + reason).

Present the complete plan file link to [USER-NAME] for final review. STOP. Wait for instruction.

### Step 15: Execute Phases

After [USER-NAME] instructs to start, execute phases following the dependency graph order.

**For each phase:**
1. Check dependency graph — are all prerequisite phases DONE? Are exit criteria for prerequisites verified?
2. If prerequisites met, launch the phase using its designated protocol (`/council-of-wizards`, `/high-wizard`, or `/quick-wizard`). **Important**: The phase's plan file must be created at a path inside the rite folder, overriding the sub-protocol's default `plans/` location.
3. Update the Execution Log: status → IN PROGRESS, record start date, record protocol used
4. After phase completes, verify its exit criteria (check Status column in Phase Exit Criteria table)
5. Update the Execution Log: status → DONE, record completion date
6. If phase is blocked, update: status → BLOCKED, record reason in Notes

**Parallel execution:**
- If the dependency graph shows phases that can overlap, inform [USER-NAME]: "Phase X and Phase Y can run in parallel. You can launch separate agent sessions to work on them concurrently."
- The protocol identifies parallel opportunities but does NOT enforce parallel execution — [USER-NAME] decides whether to run them concurrently

**Between phases:**
- Verify exit criteria are satisfied before starting dependent phases
- The Phase Exit Criteria table is the gate

### Step 16: Project Completion

After all phases are DONE:
1. Run through the [Project Completion Checklist](//@agent-memory/control-files/plan-templates/rite-of-creation-plan-template.md#project-completion-checklist)
2. Verify all phase exit criteria (Status column checked)
3. Present completion summary to [USER-NAME]

### Step 17: Move Rite Folder to Completed

After [USER-NAME] confirms project is complete, move the entire rite folder:
`mkdir -p ./plans/completed && mv ./plans/[rite-folder] ./plans/completed/[rite-folder]`

**Note**: Episodic memory links to the plan will break after moving. This is accepted — completed plans are archival.

---
