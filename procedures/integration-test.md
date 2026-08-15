# Integration Test

Run runtime verification through the qa/ instrument — execute the R/I/A/O loop to verify the system actually runs. Two tactics: **whole-stack module smoke** (did a change break the run path?) and the **goal-driven fixture→e2e ladder** (does a specific feature/flow produce the right outcome, driven the way the system really runs it?). Closes the loop on *"does it actually work?"*.

- **Standalone**: invoke directly after manual changes, bug fixes, or pre-deploy checks to verify runtime behavior on a scope.
- **Embedded (wizard-delegated)**: called by `/high-wizard` Step 17, `/quick-wizard` Step 8, and `/pixel-wizard` Step 19 as the "Final Integration Test" step in their lifecycle.

## Arguments

`$ARGUMENTS`

### Standalone invocation (user-invoked)

- `/integration-test [scope]` → Run integration tests on the given scope of touched modules
- `/integration-test` → Will ask for scope

**Scope examples:**
- Module names: `auth`, `api`, `worker`
- File paths: `src/auth/login.ts`, `src/api/users.ts`
- Git-based: `all changes since last commit`

If no arguments provided, ask: "What scope should I run integration tests on? (module names, file paths, or 'all changes since last commit')"

### Embedded invocation (wizard-delegated)

When called from `/high-wizard` Step 17, `/quick-wizard` Step 8, or `/pixel-wizard` Step 19, this procedure runs in **embedded mode** with two caller-passed inputs:

- `scope`: list of files from the caller's Execution Log (HW/pixel-wizard) or QW plan execution
- `embedded_mode=true`: signals to write results into the caller's plan `## FINAL INTEGRATION TEST` section (where the wizard step is labeled "Final Integration Test" — "final" is the wizard's positional descriptor, not a property of this procedure itself)

Embedded mode flow: caller hands off control → this procedure runs the R/I/A/O loop → results embedded in caller's plan → caller resumes its next step.

---

## Procedure

### Step 1: Detect qa/ Instrument

Check for `qa/README.md` with a filled **R/I/A/O Loop** table — that table is the index this procedure resolves the loop from.

- **If missing**: STOP. Present to [USER-NAME]:
  ```
  No qa/ instrument (R/I/A/O index) detected for this project.
  A) Build it: /map-qa-instrument create, then /build-qa-instrument (recommended)
  B) Skip integration test (log decision)
  ```
  - If A: run the map → build pipeline, then return here.
  - If B: log the skip:
    - **Standalone mode**: report `"Integration test skipped — no qa/ instrument"` to [USER-NAME] and end.
    - **Embedded mode**: write `"Final Integration Test skipped — no qa/ instrument"` into caller's plan `## FINAL INTEGRATION TEST` section, then return control to caller.

### Step 2: Identify Touched Modules

From the scope (caller-passed in embedded mode, or asked in standalone mode), map each file to its qa/ runbook by matching directory or module name. Surface any files that don't map to a runbook — flag as *"no runbook coverage"* in the report/log.

### Step 3: Choose the Tactic

Integration verification has two tactics. Pick by what you're actually verifying:

- **Tactic A — Whole-stack module smoke** (Step 3A). *"Did this change break the module's invariant run path?"* Broad, coarse. Use for post-change regression across touched modules, and for the embedded wizard step by default.
- **Tactic B — Goal-driven fixture→e2e ladder** (Step 3B). *"Does this specific feature/flow produce the right outcome, driven through its real entry point?"* Surgical, high-confidence on one path. Use to verify a shipped feature end-to-end, or to reproduce + verify a bug fix.

Often you run **both**: B to prove the changed feature works, A to confirm nothing else regressed. In embedded (wizard) mode, default to A unless the caller named a specific feature/flow — then run B on it.

**Both tactics obey these standing refinements** (they are what make a run trustworthy and repeatable):
1. **Reset the baseline at the START and teardown at the END** — wrap the whole run in try/finally so a mid-run failure still cleans up. A run that leaves residue makes the next run start dirty.
2. **Keep both layers** — the fast targeted check (a component/DB test) AND the slow full-flow. One does not replace the other; the pyramid wants many fast, few slow.
3. **Fidelity** — any shortcut that stands in for a real stage MUST produce a state *equivalent* to that stage's real output, or downstream checks pass against states the system could never actually reach.

### Step 3A: Whole-Stack Module Smoke

**Resolve the loop from `qa/README.md`'s R/I/A/O table — the index, not the scripts.** Its Mechanism column links each phase (RESET / INJECT / ACT / OBSERVE) to the script that runs it; that link is the contract, written by `/build-qa-instrument`. Read the table — do NOT scan filenames or in-script headers.

For each touched module's runbook, run the full loop:

- **a.** Read `qa/runbooks/{module}.md`
- **b.** Run the table's **RESET** mechanism (to clean state)
- **c.** Run the table's **INJECT** mechanism (test data)
- **d.** Run the table's **ACT** mechanism (bring stack up)
- **e.** Execute the runbook's Act-section scenarios (per runbook instructions)
- **f.** Run the table's **OBSERVE** mechanism
- **g.** Compare results against the runbook's Observe-section expectations

**Cross-module scope**: if the touched files span multiple modules (or the change is inherently cross-cutting), also run the **playbook** (`qa/playbook.md`) — its Full-System Boot Order, Full-System Smoke, and any End-to-End Scenarios covering the touched paths. Runbooks verify each module in isolation; the playbook verifies they still work *connected*.

### Step 3B: Goal-Driven Fixture→e2e Ladder

Use this to verify one specific feature/flow (e.g. *"auto fish-in quarantine"*). The core insight: driving a whole flow through its real entry points is expensive (auth, full stack, slow), so pay the real cost only for the **one step you're validating**, and reach everything before it **cheaply via fixtures**.

1. **Decompose the flow into stages** and name the **step under test** — the single stage whose behavior you're validating (usually the changed or suspect one). List the upstream stages that must have happened first.
   > Example — auto fish-in quarantine: `create order → supplier order → prepare fish-in → CONFIRM fish-in (step under test) → observe tank state`.

2. **THE RULE — fixture the preconditions; exercise the step under test for real. NEVER fixture the step under test.** A shortcut standing in for the behavior you're validating proves nothing. (A shortcut standing in for an *upstream* stage is exactly right.)

3. **RESET the baseline** — either the Tactic-A RESET, or a scoped **snapshot** of just the entities the run will touch (capture their pre-state so teardown can restore them exactly).

4. **Build the precondition state by forward-chaining the upstream stages** — for each, use its `fixture(stage)` from `qa/fixtures/` (reuse existing snapshot data / call the real API with a cached token / a DB seed that mirrors that stage's real output). **No reset between stages** — each consumes the prior stage's accumulated state. Prefer the highest-fidelity fixture available; if a needed fixture doesn't exist, flag it and offer to build it (it belongs to the qa/ instrument — see `/setup-qa-instrument`).

5. **Exercise the step under test for real** — drive its *actual* entry point: the HTTP endpoint the UI/mobile calls, the scheduler endpoint, the real service method at the true boundary. Not an internal shortcut that bypasses the wiring.

6. **OBSERVE the goal outcome** — assert the real result (SQL query, response body, smoke check). For DB-facing steps use the **surgical pattern**: snapshot the disposable target(s) first, drive the step, assert the exact DB delta, so the check is precise and not masked by other data.

7. **TEARDOWN (finally)** — restore snapshots / delete created rows / reset touched entities, so the run leaves **zero residue** and is re-runnable. This runs even if an assertion failed.

8. **Fidelity check (periodic, not every run)** — occasionally run the REAL upstream stage (not its fixture) and assert its output matches what `fixture(stage)` produced. If they diverge, the fixture has drifted and is lying — fix the fixture before trusting further Tactic-B runs off it.

**Applicability & escape hatches.** The DB/HTTP mechanics above (SQL delta, cached token, endpoint) are *one common shape* — read them as examples, not the only form. Two assumptions ride under Tactic B; when either fails, adapt rather than force it:
- **State must be resettable** for RESET + TEARDOWN to hold. If the step has *irreversible* side effects (a real email/SMS, a payment, a non-idempotent external call) you cannot `finally { undo }` — route it through a **sandbox / test double / idempotency key**, or fall to Tactic A and assert the *intent* (the outbound call was issued) rather than the irreversible effect. For **non-persistent** systems (stateless, streaming, pure compute) "snapshot the rows" has no meaning — OBSERVE via the system's real output channel (emitted event, return value, log/trace) and TEARDOWN is a no-op.
- **The step under test needs an automatable entry point.** If it's **UI-only** (desktop GUI, mobile screen) with no service/HTTP seam, you cannot drive it for real — drive the **nearest automatable boundary** (the method/endpoint the UI calls) and **manual-verify** the UI layer, and say so. Do NOT relabel a boundary-driven run as full e2e.

### Step 4: Present Findings

Any failure becomes a **Critical** finding. Present by invoking the `/wait-options` command procedure — run the command; its format rules are not in context.
Preamble: *"Runtime verification findings:"*

**STOP**. Wait for [USER-NAME]'s response.

If no findings, report: *"Integration test passed — runtime clean."*

### Step 5: Fix Cycle

Apply approved fixes in one batch. Re-run the loop (Step 3A or 3B, whichever this run used) for the affected modules/flow. Repeat until clean or [USER-NAME] explicitly defers remaining items.

### Step 6: Log Results

- **Standalone mode**: Report results inline to [USER-NAME]:
  - Tactic used (A whole-stack smoke / B fixture→e2e ladder / both)
  - Touched modules + runbooks run
  - For Tactic B: the flow, the step under test (driven for real), and the fixtures used for the upstream stages
  - Playbook run (if cross-module): result, or N/A
  - qa/ Status (detected / skipped)
  - R/I/A/O loop results (pass/fail); confirm teardown left zero residue
  - Findings + Fixed

- **Embedded mode**: Write results into caller's plan `## FINAL INTEGRATION TEST` section:
  - **Scope**: touched modules
  - **qa/ Status**: detected / missing / skipped
  - **Runbooks Run**: list of `qa/runbooks/{module}.md` exercised
  - **Playbook Run**: `qa/playbook.md` if cross-module (boot order + full-system smoke + E2E scenarios), or N/A
  - **R/I/A/O Results**: per-module pass/fail summary
  - **Findings**: runtime failures + severity, or *"No findings — runtime clean"*
  - **Fixed**: what was fixed from approved findings, or *"N/A"*

**Embedded mode return**: After Step 6, control returns to the wizard caller (HW Step 17, QW Step 8, or pixel-wizard Step 19), which then proceeds to its next step (Move to Completed or Report Completion).
