# High Wizard Protocol

Execute smart planning with structural decision collection - forces "ask before assuming" by collecting implementation decisions in gated rounds, with recommended defaults, before writing any plan content or executing.

## Arguments

`$ARGUMENTS`

- `/high-wizard [context]` → Create High Wizard plan for the given context
- `/high-wizard` → Will ask for context

If no arguments provided, ask: "What feature or task should I create a High Wizard plan for?"

---

## Procedure Rules

High Wizard is a **Level 1** wizard protocol: one coherent deliverable, planned in a file. It is a leaf — it never orchestrates sub-plans — and it may itself be launched as a sub-plan by `/council-of-wizards`, `/rite-of-creation`, or `/forge-of-covenant`.

Level 1 is implementation altitude, so that is what you collect decisions about — Step 6 names the categories, the condition each one runs under, and the order they are asked in. Implementation nouns — main function, module entrypoint, execution flow — are the right vocabulary to disclose in, because they are what this altitude is made of. Nothing gets pushed down; there is no lower rung. (`/wait-options-coding` governs *how* you present a decision, never *which* decisions are yours — Step 6 is where that is decided.)

If a parent launched you, then why this deliverable exists, how it is bounded against its siblings, and which contracts it must honor were settled one level up. Those arrive in the handoff that Step 5 reads before any investigation begins — treat them as given, and do not re-ask them.

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

**First, if launched as a sub-plan**: read and follow the [Subplan Handoff component]([path-to-agent-memory-coding-skill]/components/subplan-handoff-read.md). It tells you what you inherited, what you may not reopen, and where to find the payload if none was passed. Record it under `## INHERITED CONTEXT` before investigating anything.

Then read and follow the [Planning Investigation component]([path-to-agent-memory-coding-skill]/components/planning-investigation.md) — it runs the shared investigation checklist and produces the findings this plan's decisions are built from. This is where the thinking happens — NOT in the plan document.

### Step 6: Present Decisions — One Round per Category

Decisions are not presented in one block. Each category from this procedure's opening gets its own round, in the order declared there, and every round is a gate: present, STOP, and wait for [USER-NAME] to clear it before building the next. The [Planning Decision component]([path-to-agent-memory-coding-skill]/components/planning-decision.md) governs what earns a place in a round and how a round is run — read and follow it before building the first round.

Present the [planning rounds]([path-to-agent-memory-coding-skill]/components/planning-rounds.md).

Do NOT write any plan sections until every round that ran is confirmed.

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
- Present findings via /wait-options-coding (its Step 7) — preamble: *"Code quality review for implementation:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and update this plan's Quality Review section (its Step 8)

3. **Resume control** here after `/analyze-code-quality` completes. Proceed to Step 17 (Build QA Checklist).

### Step 17: Build QA Checklist (Delegated to `/generate-qa-checklist`)

After Quality Review is resolved, hand this plan off to QA by building its verification checklist. Static quality review (Step 16) answered *"is the code clean?"*; this step produces the artifact that will answer *"is it actually right?"* — **later, by a human, with the stack up.**

> **This step does not verify anything, and must never claim to.** A wizard sweep is a coding session: the QA stack is almost certainly down, so running the R/I/A/O loop here would mean a cold `start-stack` plus a full seed restore on every sweep — minutes to tens of minutes nobody asked for. Runtime verification belongs to a dedicated QA session (`/run-qa-test`), where the stack is already up and Tactic B's fixtures can be built. What this step guarantees is that the sweep never ends without a written plan for that verification.

1. **Collect scope**: Identify all files created or modified during implementation from this plan's Execution Log. That list, plus this plan itself, is the **caller-passed scope**.

2. **Invoke `/generate-qa-checklist`** with this plan as the scope input.

The delegated procedure will:
- **Check the QA instrument is set up** — a `qa/qa-map.md` from `/map-qa-instrument`, and a built bench from `/build-qa-bench`. If either is absent it **notifies loudly and auto-skips** rather than inventing a `qa/` folder this project never opted into.
- Read the plan for **scope** (what changed, which modules, contracts, what's already automated)
- Derive **risk independently** — invariants to disprove, regression surface, boundaries and error paths, cross-module effects, prior defects. The plan is input, never authority: a checklist that only restates acceptance criteria passes by construction.
- Write `qa/checklists/{feature}.md`, marking each item automated vs manual and flagging the UI-bound ones

3. **Record the outcome in this plan's `## QA HANDOFF` section** — the checklist path, or the skip and its reason. Never leave it blank; a silent skip reads as "nothing needed."

4. **Resume control** here after the delegated procedure completes. Proceed to Step 18 (Move Plan to Completed).

### Step 18: Move Plan to Completed

After all implementation phases are done, logged, and both Quality Review (Step 16) + QA Handoff (Step 17) are resolved, follow the [Archive Plan component]([path-to-agent-memory-coding-skill]/components/archive-plan.md) — move the plan file `[plan-file].md`.

### Step 19: Completion Report

Present a brief completion report to [USER-NAME]:
- Plan file location (in `/plans/completed/`)
- Summary of what was implemented
- Quality Review status (clean / N findings fixed)
- **QA Handoff**: `qa/checklists/{feature}.md` built, or skipped + reason
- ⚠️ **State plainly: "Not runtime-verified."** Then the exact next action — *"run `/run-qa-test --checklist qa/checklists/{feature}.md` when the stack is up"*, or *"set up the QA instrument first: `/map-qa-instrument create` → `/build-qa-bench`"* if the step auto-skipped. A plan moving to `completed/` must never imply verification it didn't do.
- Any notes or follow-ups worth mentioning

Then offer: "Would you like me to run `/wrap-up` to close the session?"

### ⛔ END OF PHASE 3

Protocol complete.

---
