# Quick Wizard Protocol

Execute lightweight smart planning with decision collection and direct execution — same decision-collection discipline as High Wizard but without a custom plan template file. Uses the IDE's built-in plan mode for structured execution tracking. Includes a scope gate that auto-escalates to /high-wizard when the task is too complex for direct execution.

## Arguments

`$ARGUMENTS`

- `/quick-wizard [context]` → Create Quick Wizard plan for the given context
- `/quick-wizard` → Will ask for context

If no arguments provided, ask: "What feature or task should I create a Quick Wizard plan for?"

---

## Procedure

This is a **Level 0** wizard protocol: the smallest unit of planned work. It is a leaf — it never orchestrates sub-plans — and it may itself be launched as a sub-plan by `/council-of-wizards`, `/rite-of-creation`, or `/forge-of-covenant`.

Level 0 is the concrete change, so that is what you collect decisions about — Step 3 names the categories, the condition each one runs under, and the order they are asked in; at this size most will not run at all. Implementation nouns — entrypoints, core logic, execution touchpoints — are the right vocabulary to disclose in, because they are what this altitude is made of. (`/wait-options-coding` governs *how* you present a decision, never *which* decisions are yours — Step 3 is where that is decided.) Nothing gets pushed down; a decision that feels too large to settle here is not something to hand off, it is the scope gate in Step 2 telling you to escalate to `/high-wizard`.

*IMPORTANT: This procedure structurally enforces UUID f3a8b2c1 (VERIFY FIRST) - the agent MUST collect and confirm decisions BEFORE executing. Jumping directly into implementation is prohibited.*

### Step 1: Investigate and Collect Decisions

**First, if launched as a sub-plan**: read and follow the [Subplan Handoff component]([path-to-agent-memory-coding-skill]/components/subplan-handoff.md) — **read side**. It tells you what you inherited, what you may not reopen, and where to find the payload if none was passed. Record it under `## Inherited Context` before investigating anything.

Then read and follow the [Planning Investigation component]([path-to-agent-memory-coding-skill]/components/planning-investigation.md) — it runs the shared investigation checklist and produces the findings this plan's decisions are built from.

### Step 2: Scope Gate Assessment

After investigation, assess whether this task is suitable for Quick Wizard (direct execution) or needs to escalate to /high-wizard (file-based planning).

**Escalate to /high-wizard when ANY of these apply:**
- Task likely spans multiple sessions or risks context compaction
- Multiple files with complex interdependencies need modification
- Task requires production deployment with audit trail
- Implementation has irreversible consequences requiring careful tracking
- You feel uncertain about completing within the current session
- Task involves bug investigation requiring hypothesis-driven debugging (high-wizard section E)
- Task requires evaluating multiple solution approaches with formal comparison (high-wizard section F)
- Task produces an architecture decision record (high-wizard sections F+G)

**If escalating**: Tell [USER-NAME] "This task is complex enough to benefit from /high-wizard — escalating with the decisions I've already collected." Then execute /high-wizard starting from Step 7 (decisions already collected). STOP HERE — do not continue with Quick Wizard steps.

**If suitable for Quick Wizard**: Continue to Step 3.

### Step 3: Present Decisions — One Round per Category

Decisions are not presented in one block. Each category from this procedure's opening gets its own round, in the order declared there, and every round is a gate: present, STOP, and wait for [USER-NAME] to clear it before building the next. The [Planning Decision component]([path-to-agent-memory-coding-skill]/components/planning-decision.md) governs what earns a place in a round and how a round is run — read and follow it before building the first round.

Present the [planning rounds]([path-to-agent-memory-coding-skill]/components/planning-rounds.md).

Do NOT proceed until every round that ran is confirmed.

### Step 4: Create Execution Plan

Enter plan mode if available. If plan mode is not available, present the plan directly in conversation for [USER-NAME]'s approval.

Write the execution plan using the [Quick Wizard Plan Content Template](#quick-wizard-plan-content-template) structure:
- Objective (1-2 sentences)
- Confirmed decisions table
- Numbered execution steps with clear actions

### Step 5: Get Approval

Present the plan for [USER-NAME]'s approval. STOP. Do NOT execute until [USER-NAME] confirms.

### Step 6: Execute

Execute the steps from the plan in order. After each step, briefly report what was done before moving to the next.

**CRITICAL**: If any NEW decision is discovered during execution that was not covered in Step 3, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT execute ahead on assumptions.

### Step 7: Quality Review (Delegated to `/analyze-code-quality`)

After all steps are executed, run **static** code quality review by delegating to `/analyze-code-quality` in embedded mode. Findings are embedded directly into the plan's Quality Review section (created at Step 4 from the Quick Wizard Plan Content Template) — the plan IS the audit trail.

1. **Collect scope**: Identify all files created or modified during execution (from the plan's execution tracking — plan-mode steps or in-conversation tracking). This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/analyze-code-quality`** following the /analyze-code-quality with these inputs:
   - `scope`: the file list collected above
   - `embedded_mode=true`: signals the procedure to skip standalone working-doc creation; findings get embedded into the QW plan's Quality Review section

The delegated procedure will:
- Run **Scope Reconciliation** (its Step 3) — surface any git-diff vs tracked-scope discrepancies for [USER-NAME] to reconcile
- **Discover quality standard** (its Step 4) — looks for `**/quality-standard.md`; if found, applies Dimension 8; if not, freeform
- Walk quality dimensions against the reconciled scope (its Steps 5-6)
- Present findings via /wait-options-coding (its Step 7) — preamble: *"Code quality review for implementation:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and update the QW plan's Quality Review section (its Step 8)

3. **Resume control** here after `/analyze-code-quality` completes. Proceed to Step 8 (Build QA Checklist).

### Step 8: Build QA Checklist (Delegated to `/build-qa-test --checklist`)

After Quality Review is resolved, hand this plan off to QA by building its verification checklist. Static quality review (Step 7) answered *"is the code clean?"*; this step produces the artifact that will answer *"is it actually right?"* — **later, by a human, with the stack up.**

> **This step does not verify anything, and must never claim to.** A wizard sweep is a coding session: the QA stack is almost certainly down, so running the R/I/A/O loop here would mean a cold start plus a full seed restore on every sweep. Runtime verification belongs to a dedicated QA session (`/run-qa-test`). What this step guarantees is that the sweep never ends without a written plan for that verification.

1. **Collect scope**: Identify all files created or modified during execution (from the plan's execution tracking — plan-mode steps or in-conversation tracking). That list, plus this plan itself, is the **caller-passed scope**.

2. **Invoke `/build-qa-test --checklist`** with this plan as the scope input.

The delegated procedure will:
- **Check the QA instrument is set up** — a `qa/qa-map.md` from `/map-qa-instrument`, and a built bench from `/build-qa-bench`. If either is absent it **notifies loudly and auto-skips** rather than inventing a `qa/` folder this project never opted into.
- Read the plan for **scope**, then derive **risk independently** — invariants to disprove, regression surface, boundaries, cross-module effects. The plan is input, never authority.
- Write `qa/checklists/{feature}.md`, marking each item automated vs manual

3. **Record the outcome in the plan's `## QA HANDOFF` section** — the checklist path, or the skip and its reason. Never leave it blank.

4. **Resume control** here after the delegated procedure completes. Proceed to Step 9 (Report Completion).

### Step 9: Report Completion

After all steps are executed and both Quality Review (Step 7) + QA Handoff (Step 8) are resolved, present a brief completion summary to [USER-NAME]:
- What was done
- Quality Review status (clean / N findings fixed)
- **QA Handoff**: `qa/checklists/{feature}.md` built, or skipped + reason
- ⚠️ **State plainly: "Not runtime-verified."** Then the exact next action — *"run `/run-qa-test --checklist qa/checklists/{feature}.md` when the stack is up"*, or the instrument-setup commands if the step auto-skipped.
- Any issues encountered
- Any tech debts or follow-up items

---

## Templates

### Quick Wizard Plan Content Template

Use this structure when writing the plan in plan mode (or presenting in conversation):

```markdown
# Quick Wizard Plan: [Theme]

## Inherited Context
*Filled at investigation step 0 when launched as a sub-plan — from the parent's handoff (or the parent `core-plan.md`). Write "None — standalone plan" if there is no parent.*
*Not yours to reopen. If an inherited decision looks wrong, STOP and surface it — do not silently re-decide it below.*

- **Parent plan**: [path, or "None — standalone plan"]
- **Assigned scope**: [what this plan owns]
- **Inherited decisions**: [decision → chosen → parent's reason; mark each Settled or My call]
- **Contracts / pushed-down items**: [paths + produce/consume, and any decisions left to this plan — or "None"]

## Objective
[1-2 sentence description of what we're doing and why]

## Confirmed Decisions
*Decisions made **by this plan** — both asked-and-confirmed by [USER-NAME] AND written-through (Zone A and B decisions, recorded with their reasoning). Inherited decisions belong above, not here.*

| # | Decision | Chosen | Reason |
|---|----------|--------|--------|
| 1 | [Topic] | [Choice] | [Why] |

## Success Criteria
- [ ] [How we know it's done]
- [ ] Static quality review completed (Step 7 — delegated to `/analyze-code-quality`)
- [ ] QA Handoff completed (Step 8 — checklist built, or auto-skipped with reason recorded)

## Execution Steps
1. **[Step name]**: [What to do] → [How to verify]
2. **[Step name]**: [What to do] → [How to verify]
3. **[Step name]**: [What to do] → [How to verify]

## Quality Review
*Filled by Step 7 (delegated to `/analyze-code-quality` in embedded mode). **Static** review — answers "is the code clean?".*

- **Scope**: [Files reviewed — reconciled against `git diff --name-only`]
- **Quality Standard**: [found / not found — dimensions applied]
- **Findings**: [Issues found, or "No findings — implementation meets quality dimensions"]
- **Fixed**: [What was fixed from approved findings, or "N/A"]

## QA Handoff
*Filled by Step 8 after Quality Review is resolved. This plan is **not** runtime-verified — this section records the plan for that verification, which happens in a QA session with the stack up.*

- **Scope**: [Modules touched]
- **QA instrument**: [Set up (map + bench) / NOT SET UP — auto-skipped]
- **Checklist**: [`qa/checklists/{feature}.md`, or "none — skipped, reason"]
- **Coverage split**: [N automated (named tests) / N manual — of which N are UI-bound]
- **Runtime verification**: **NOT DONE.** Next action: [`/run-qa-test --checklist qa/checklists/{feature}.md` once the stack is up | set up the instrument first: `/map-qa-instrument create` → `/build-qa-bench`]
```

---
