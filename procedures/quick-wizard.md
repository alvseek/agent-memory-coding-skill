# Quick Wizard Protocol

Execute lightweight smart planning with decision collection and direct execution — same decision-collection discipline as High Wizard but without a custom plan template file. Uses the IDE's built-in plan mode for structured execution tracking. Includes a scope gate that auto-escalates to /high-wizard when the task is too complex for direct execution.

## Arguments

`$ARGUMENTS`

- `/quick-wizard [context]` → Create Quick Wizard plan for the given context
- `/quick-wizard` → Will ask for context

If no arguments provided, ask: "What feature or task should I create a Quick Wizard plan for?"

---

## Procedure

*IMPORTANT: This procedure structurally enforces UUID f3a8b2c1 (VERIFY FIRST) - the agent MUST collect and confirm decisions BEFORE executing. Jumping directly into implementation is prohibited.*

### Step 1: Investigate and Collect Decisions

This is where the thinking happens. Follow the investigation checklist below IN ORDER. Each step from 3-7 produces decision items for the WAIT Options form.

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting decisions.

**Investigation checklist (in order):**

1. **Requirements clarity** - Is the intent already clear? Is there ambiguity within the context? If ambiguous, create decisions to clarify before proceeding
2. **Codebase scan** - Scan relevant files, modules, and architecture related to the task to understand current state
3. **Critical technical points disclosure** - Identify the main function/module entrypoints, core engine algorithm/logic pattern, and key execution flow touchpoints. Surface these in WAIT Options even when the implementation direction is already clear
4. **Alternative approaches** - Based on the requirement, discover what ways this can be done (there's usually more than one) → offer as decisions
5. **Reusable components** - Identify existing functions, utilities, patterns that could be leveraged → offer to reuse the related/reusable ones as decisions
6. **Conflicts and constraints** - Note what could go wrong, what limits exist → if any, offer options based on pros and cons as decisions
7. **Integration points** - Check what existing code/systems will be affected → if concerning, offer options as decisions
8. **Quality standard discovery** - Search for `quality-standard.md` in the project via glob (`**/quality-standard.md`). If found, load it as additional implementation criteria to reference during execution. If not found, note it and proceed

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

**If escalating**: Tell [USER-NAME] "This task is complex enough to benefit from /high-wizard — escalating with the decisions I've already collected." Then execute [High Wizard Protocol](//@agent-memory/control-files/procedures/high-wizard.md) starting from Step 7 (decisions already collected). STOP HERE — do not continue with Quick Wizard steps.

**If suitable for Quick Wizard**: Continue to Step 3.

### Step 3: Present WAIT Options

Present the WAIT Options form to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "I've investigated the codebase. Here are the decisions I need before proceeding"

STOP. Present to [USER-NAME] for review. Do NOT proceed until decisions are confirmed.

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

2. **Invoke `/analyze-code-quality`** following the [Analyze Code Quality procedure](//@agent-memory/control-files/procedures/analyze-code-quality.md) with these inputs:
   - `scope`: the file list collected above
   - `embedded_mode=true`: signals the procedure to skip standalone working-doc creation; findings get embedded into the QW plan's Quality Review section

The delegated procedure will:
- Run **Scope Reconciliation** (its Step 3) — surface any git-diff vs tracked-scope discrepancies for [USER-NAME] to reconcile
- **Discover quality standard** (its Step 4) — looks for `**/quality-standard.md`; if found, applies Dimension 8; if not, freeform
- Walk quality dimensions against the reconciled scope (its Steps 5-6)
- Present findings via [WAIT Options Quality Review variant](//@agent-memory/control-files/procedures/wait-options.md#quality-review-variant) (its Step 7) — preamble: *"Code quality review for implementation:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and update the QW plan's Quality Review section (its Step 8)

3. **Resume control** here after `/analyze-code-quality` completes. Proceed to Step 8 (Final Integration Test).

### Step 8: Final Integration Test (Delegated to `/integration-test`)

After Quality Review is resolved, run **runtime** verification by delegating to `/integration-test` in embedded mode. Results are embedded directly into this plan's `## FINAL INTEGRATION TEST` section — static quality review (Step 7) answered "is the code clean?"; this step answers "does it actually work?".

1. **Collect scope**: Identify all files created or modified during execution (from the plan's execution tracking — plan-mode steps or in-conversation tracking). This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/integration-test`** following the [Integration Test procedure](//@agent-memory/control-files/procedures/integration-test.md) with these inputs:
   - `scope`: the file list collected above
   - `embedded_mode=true`: signals the procedure to write results into the QW plan's Final Integration Test section

The delegated procedure will:
- **Detect qa/ instrument** (its Step 1) — stop + offer `/setup-qa-instrument` if missing
- **Identify touched modules** and map to playbooks (its Step 2)
- **Run R/I/A/O loop per module** (its Step 3): reset → seed → start → act scenarios → smoke → compare
- Present findings via [WAIT Options Quality Review variant](//@agent-memory/control-files/procedures/wait-options.md#quality-review-variant) (its Step 4) — preamble: *"Runtime verification findings:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and re-run affected modules (its Step 5)
- Log results into the QW plan's `## FINAL INTEGRATION TEST` section (its Step 6)

3. **Resume control** here after `/integration-test` completes. Proceed to Step 9 (Report Completion).

### Step 9: Report Completion

After all steps are executed and both Quality Review (Step 7) + Final Integration Test (Step 8) are resolved, present a brief completion summary to [USER-NAME]:
- What was done
- Quality Review status (clean / N findings fixed)
- Final Integration Test status (clean / N runtime failures fixed / skipped — no qa/)
- Any issues encountered
- Any tech debts or follow-up items

---

## Templates

### Quick Wizard Plan Content Template

Use this structure when writing the plan in plan mode (or presenting in conversation):

```markdown
# Quick Wizard Plan: [Theme]

## Objective
[1-2 sentence description of what we're doing and why]

## Confirmed Decisions
*Both asked-and-confirmed by [USER-NAME] AND written-through (Zone A/B decisions with reasoning) — see [What to Surface](wait-options.md#what-to-surface).*

| # | Decision | Chosen | Reason |
|---|----------|--------|--------|
| 1 | [Topic] | [Choice] | [Why] |

## Success Criteria
- [ ] [How we know it's done]
- [ ] Static quality review completed (Step 7 — delegated to `/analyze-code-quality`)
- [ ] Final Integration Test completed (Step 8 — runtime via qa/ instrument, or explicitly skipped)

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

## Final Integration Test
*Filled by Step 8 after Quality Review is resolved. **Runtime** verification through the qa/ instrument — answers "does it actually work end-to-end?".*

- **Scope**: [Modules touched]
- **qa/ Status**: [Detected / Missing / Skipped — reason if skipped]
- **Playbooks Run**: [List of `qa/playbooks/{module}.md` exercised, or "N/A — skipped"]
- **R/I/A/O Results**: [Per-module pass/fail summary, or "N/A — skipped"]
- **Findings**: [Runtime failures + severity, or "No findings — runtime clean", or "N/A — skipped"]
- **Fixed**: [What was fixed from approved findings, or "N/A"]
```

---
