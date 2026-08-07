# High Wizard Protocol

Execute smart planning with structural decision collection - forces "ask before assuming" by collecting ALL implementation decisions upfront with recommended defaults before writing any plan content.

## Arguments

`$ARGUMENTS`

- `/high-wizard [context]` → Create High Wizard plan for the given context
- `/high-wizard` → Will ask for context

If no arguments provided, ask: "What feature or task should I create a High Wizard plan for?"

---

## Procedure

*IMPORTANT: This procedure structurally enforces UUID f3a8b2c1 (VERIFY FIRST) - the agent MUST collect and confirm decisions BEFORE writing any plan sections. Writing ahead on assumptions is prohibited.*

*This procedure is split into 3 phases. Each phase ends with a STOP gate. Do NOT read ahead into later phases — complete and confirm the current phase before proceeding.*

---

## Phase 1: Discovery & Planning Frame

*Goal: Investigate the task, collect decisions, frame objectives/scope, and get early confirmation before any solution writing.*

### Step 1: Read Template

Read the [High Wizard Plan Template]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md) file

### Step 2: Check Date

Get current date for file naming:
`date '+%Y-%m-%d %H:%M'`

### Step 3: Copy Template

Copy the template file to the `/plans` folder with the final name:
`cp {source} ./plans/[YYYY-MM-DD]-[project]-[theme].md`

### Step 4: Fill Project Info

Fill the [Project Info]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#project-info) section only (Project, Date, Agent, Theme)

### Step 5: Investigate and Collect Decisions

Read and follow the [Investigate & Collect Decisions component]([path-to-agent-memory-coding-skill]/components/investigate-and-collect-decisions.md) — it runs the shared investigation checklist and collects decision items for the WAIT Options form. This is where the thinking happens — NOT in the plan document.

### Step 6: Present WAIT Options

Present the WAIT Options form to [USER-NAME] by invoking the `/wait-options` command procedure.
Preamble: "I've investigated the codebase. Here are the decisions I need before planning"

STOP. Present to [USER-NAME] for review. Do NOT write any plan sections until decisions are confirmed.

### Step 7: Fill Objectives + Success Criteria

Fill the [Objectives]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#objectives) and [Success Criteria]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#success-criteria) sections

### Step 8: Fill Scope

Fill the [Scope]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#scope) section (In Scope / Out of Scope)

### Step 9: Fill Confirmed Decisions

Record all confirmed decisions (with any changes [USER-NAME] made) in the [Confirmed Decisions]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#confirmed-decisions) section. Include the meaningful reasons - this IS the analysis record.

### Step 10: Early Review

Present objectives, scope, and confirmed decisions to [USER-NAME]. Then propose which optional plan sections to include based on investigation findings.

**Optional sections (lettered)** — propose based on task context:
- **A) Integration Architecture** — Propose when: multi-system changes, multiple components interacting
- **B) System Flow Diagrams** — Propose when: changing data/process flow, API changes, sequence changes
- **C) Technical Considerations** — Propose when: significant technical constraints, limitations, or dependencies exist
- **D) Detailed Analysis** — Propose when: investigation/analysis-focused tasks, unclear objectives needing deep examination
- **E) Bug Investigation** — Propose when: bug fix, debugging, error investigation, unexpected behavior analysis
- **F) Solution Options & Evaluation** — Propose when: brainstorming/decision tasks, multiple viable approaches need evaluation, architecture decisions
- **G) ADR Output** — Propose when: F is included AND the decision has architectural significance worth documenting separately

**Response format:**
```
[Present objectives, scope, and confirmed decisions as before]

Based on the task, I'll include these optional plan sections:
[x] A) Integration Architecture (reason: ...)
[ ] B) System Flow Diagrams (reason: not needed because ...)
[x] C) Technical Considerations (reason: ...)
[ ] D) Detailed Analysis (reason: not needed because ...)
[ ] E) Bug Investigation (reason: not needed because ...)
[ ] F) Solution Options & Evaluation (reason: not needed because ...)
[ ] G) ADR Output (reason: not needed because ...)

Add or remove any? Or proceed.
```

### ⛔ END OF PHASE 1

STOP. Present Step 10 to [USER-NAME] for review. Do NOT write the solution until confirmed to avoid cascading changes when this section needs adjustment.

**Phase 2 requires [USER-NAME]'s explicit confirmation of the Early Review (objectives, scope, confirmed decisions, and optional sections). Do NOT proceed until confirmed.**

---

## Phase 2: Solution Design

*Goal: Write the solution and implementation phases based on confirmed decisions, then self-review and present for final approval.*

*⛔ Prerequisite: Phase 1 (Early Review) MUST be confirmed by [USER-NAME] before starting this phase.*

### Step 11: Fill Solution

Fill the [Solution]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#solution) section. Build directly from confirmed decisions.

**Optional sections**: Only fill the optional sections (A-G) that were confirmed in Step 10. Remove unconfirmed optional section markers and their placeholder content from the plan file — do not leave empty optional sections.

**ADR file creation**: If section G is confirmed, after filling all plan sections:
1. Copy the [ADR Template]([path-to-agent-memory-coding-skill]/templates/adr-template.md) to the project's ADR location
2. Fill it using content from section F (Solution Options & Evaluation) and the Confirmed Decisions table
3. Link the ADR back to this plan file
4. Update the plan's section G with the ADR file path

**CRITICAL**: If any NEW decision is discovered during writing that was not covered in Step 6, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

### Step 12: Fill Implementation Phases

Fill the [Implementation Phases]([path-to-agent-memory-coding-skill]/plan-templates/high-wizard-plan-template.md#implementation-phases) section.

**CRITICAL**: Same rule - if any NEW decision is discovered during writing, STOP immediately and present it before continuing.

### Step 13: Self-Review + Auto-Fix

Read and follow the [Plan Self-Review + Auto-Fix component]([path-to-agent-memory-coding-skill]/components/plan-self-review.md). If no issues found, proceed silently to Step 14.

### Step 14: Final Review

Read and follow the [Plan Final Review component]([path-to-agent-memory-coding-skill]/components/plan-final-review.md).

### ⛔ END OF PHASE 2

STOP. Wait for [USER-NAME]'s instruction to proceed to implementation.

**Phase 3 requires [USER-NAME]'s explicit instruction to start implementing. Do NOT proceed until instructed.**

---

## Phase 3: Implementation & Closure

*Goal: Execute the plan, review quality, archive, and wrap up.*

*⛔ Prerequisite: Phase 2 (Final Review) MUST be confirmed by [USER-NAME] before starting this phase.*

### Step 15: Start Implementation

After [USER-NAME] instructs to start implementing, start implementing following the **Execution Protocol for AI** from the plan file.

### Step 16: Quality Review (Delegated to `/analyze-code-quality`)

After all implementation phases are done and logged, run **static** code quality review by delegating to `/analyze-code-quality` in embedded mode. Findings are embedded directly into this plan's `## QUALITY REVIEW` section — the plan IS the audit trail.

1. **Collect scope**: Identify all files created or modified during implementation from this plan's Execution Log. This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/analyze-code-quality`** following the /analyze-code-quality with these inputs:
   - `scope`: the file list collected above (from Execution Log)
   - `embedded_mode=true`: signals the procedure to skip standalone working-doc creation; findings get embedded into this plan's Quality Review section

The delegated procedure will:
- Run **Scope Reconciliation** (its Step 3) — surface any git-diff vs Execution Log discrepancies for [USER-NAME] to reconcile
- **Discover quality standard** (its Step 4) — looks for `**/quality-standard.md`; if found, applies Dimension 8; if not, freeform
- Walk quality dimensions against the reconciled scope (its Steps 5-6)
- Present findings via /wait-options (its Step 7) — preamble: *"Code quality review for implementation:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and update this plan's Quality Review section (its Step 8)

3. **Resume control** here after `/analyze-code-quality` completes. Proceed to Step 17 (Final Integration Test).

### Step 17: Final Integration Test (Delegated to `/integration-test`)

After Quality Review is resolved, run **runtime** verification by delegating to `/integration-test` in embedded mode. Results are embedded directly into this plan's `## FINAL INTEGRATION TEST` section — static quality review (Step 16) answered "is the code clean?"; this step answers "does it actually work?".

1. **Collect scope**: Identify all files created or modified during implementation from this plan's Execution Log. This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/integration-test`** following the /integration-test with these inputs:
   - `scope`: the file list collected above (from Execution Log)
   - `embedded_mode=true`: signals the procedure to write results into this plan's Final Integration Test section

The delegated procedure will:
- **Detect qa/ instrument** (its Step 1) — stop + offer `/setup-qa-instrument` if missing
- **Identify touched modules** and map to playbooks (its Step 2)
- **Run R/I/A/O loop per module** (its Step 3): reset → seed → start → act scenarios → smoke → compare
- Present findings via /wait-options (its Step 4) — preamble: *"Runtime verification findings:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and re-run affected modules (its Step 5)
- Log results into this plan's `## FINAL INTEGRATION TEST` section (its Step 6)

3. **Resume control** here after `/integration-test` completes. Proceed to Step 18 (Move Plan to Completed).

### Step 18: Move Plan to Completed

After all implementation phases are done, logged, and both Quality Review (Step 16) + Final Integration Test (Step 17) are resolved, follow the [Archive Plan component]([path-to-agent-memory-coding-skill]/components/archive-plan.md) — move the plan file `[plan-file].md`.

### Step 19: Completion Report

Present a brief completion report to [USER-NAME]:
- Plan file location (in `/plans/completed/`)
- Summary of what was implemented
- Quality Review status (clean / N findings fixed)
- Final Integration Test status (clean / N runtime failures fixed / skipped — no qa/)
- Any notes or follow-ups worth mentioning

Then offer: "Would you like me to run `/wrap-up` to close the session?"

### ⛔ END OF PHASE 3

Protocol complete.

---
