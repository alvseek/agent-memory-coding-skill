# Run QA Test

Run runtime verification on the qa/ bench — execute the R/I/A/O loop to verify the system actually runs. Three tactics: **whole-stack module smoke** (did a change break the run path?), the **goal-driven fixture→e2e ladder** (does a specific feature produce the right outcome, driven the way the system really runs it?), and a **guided checklist pass** (walk a shipped feature's verification and sign it off). Closes the loop on *"does it actually work?"*.

- **Standalone** (the normal way): invoke in a QA session — with the stack up — after changes, bug fixes, or before a deploy. This is also where a wizard's handed-off checklist gets walked and signed off.
- **Embedded (caller-delegated)**: an available mode for any orchestrator that wants results written into its own plan section. **No wizard currently calls it.** Wizards deliberately stop at building the checklist (their QA Handoff step), because a coding sweep almost never has a live stack and a cold start-plus-seed on every sweep is a cost nobody asked for.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, the ownership split, and the grading. This skill references *up* to those; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/build-qa-test` (build the tests) → `/run-qa-test` (run them).**

> **This skill runs; it does not build.** Every missing asset is a hand-off, never an improvisation. That line is what keeps a run's result meaningful.

## Arguments

`$ARGUMENTS`

### Standalone invocation (user-invoked)

- `/run-qa-test [scope]` → Run the QA tests on the given scope of touched modules
- `/run-qa-test --checklist [file]` → Walk a per-feature checklist, then offer to archive it on sign-off
- `/run-qa-test` → Will ask for scope

**Scope examples:**
- Module names: `auth`, `api`, `worker`
- File paths: `src/auth/login.ts`, `src/api/users.ts`
- Git-based: `all changes since last commit`

If no arguments provided, ask: "What scope should I run the QA tests on? (module names, file paths, or 'all changes since last commit')"

### Embedded invocation (orchestrator-delegated)

When an orchestrator delegates here, this procedure runs in **embedded mode** with two caller-passed inputs:

- `scope`: the list of touched files the caller supplies (typically from its own execution log)
- `embedded_mode=true`: signals to write results into the caller's plan under a `## RUNTIME VERIFICATION` section (or whatever section name the caller names)

Embedded mode flow: caller hands off control → this procedure runs the loop → results embedded in caller's plan → caller resumes its next step.

---

## Procedure

### Step 1: Detect the qa/ Bench

Read `qa/README.md`'s **R/I/A/O Loop** table — that table is the index this procedure resolves the loop from.

- **If missing**: STOP. Present to [USER-NAME]:
  ```
  No qa/ bench (R/I/A/O index) detected for this project.
  A) Build it: /map-qa-instrument create, then /build-qa-bench, then /build-qa-test (recommended)
  B) Skip the QA test run (log decision)
  ```
  - If A: run the map → bench → test pipeline, then return here.
  - If B: log the skip:
    - **Standalone mode**: report `"QA test run skipped — no qa/ bench"` to [USER-NAME] and end.
    - **Embedded mode**: write `"Runtime verification skipped — no qa/ bench"` into the caller's runtime-verification section, then return control to caller.

**If present**, also read each row's **Status** and check that each Mechanism link resolves to a real file:

| Finding | Action |
|---|---|
| All four `documented` and resolving | Proceed. |
| A phase is `tribal` | **Warn, proceed.** It runs, but nothing else points at it. |
| A phase is `missing`, unlinked, or its link is dead | **Warn loudly, proceed on the phases that do resolve**, and mark the run **partial** in the report. Never silently substitute another script or scan for one by filename. |

Warn rather than block: an embedded run must still report *something* useful on a half-built instrument, and a partial run honestly labeled is more valuable than no run. Say plainly which phases did not execute and what that means for confidence.

### Step 2: Identify Touched Modules

From the scope (caller-passed in embedded mode, or asked in standalone mode), map each file to its qa/ runbook by matching directory or module name.

Surface any files that don't map to a runbook — flag as *"no runbook coverage"* in the report/log.

**If a touched module has no runbook at all** — the file doesn't exist — that module cannot be smoke-tested by Tactic A, because nothing describes how to bring it up. (A runbook that exists but carries no scenarios is a different thing entirely, and is fine: see Step 3A.) Present:

```
Module {name} has no qa/runbooks/{name}.md — Tactic A can't resolve its scenarios.
A) Build it now: /build-qa-test {module}  (recommended)
B) Run the bench loop only for this module (RESET/INJECT/ACT/OBSERVE, no module scenarios) — partial coverage
C) Skip this module (log it)
```

Never invent scenarios inline to fill the gap — an unreviewed scenario written under run pressure becomes the module's de-facto contract without anyone agreeing to it.

### Step 3: Choose the Tactic

Runtime verification has three tactics. Pick by what you're actually verifying:

- **Tactic A — Whole-stack module smoke** (Step 3A). *"Did this change break the module's invariant run path?"* Broad, coarse. Use for post-change regression across touched modules, and as the default in embedded mode.
- **Tactic B — Goal-driven fixture→e2e ladder** (Step 3B). *"Does this specific feature/flow produce the right outcome, driven through its real entry point?"* Surgical, high-confidence on one path. Use to verify a shipped feature end-to-end, or to reproduce + verify a bug fix.
- **Tactic C — Guided checklist pass** (Step 3C). *"Has everything this shipped change could affect been walked and signed off?"* Human-paced, covers the UI-bound work the other two can't reach. Triggered by `--checklist`.

Often you run **more than one**: B to prove the changed feature works, A to confirm nothing else regressed, C before sign-off. In embedded mode, default to A unless the caller named a specific feature/flow — then run B on it.

**Tactics A and B obey these standing refinements** (they are what make a run trustworthy and repeatable):
1. **Reset the baseline at the START and teardown at the END** — wrap the whole run in try/finally so a mid-run failure still cleans up. A run that leaves residue makes the next run start dirty.
2. **Keep both layers** — the fast targeted check (a component/DB test) AND the slow full-flow. One does not replace the other; the pyramid wants many fast, few slow.
3. **Fidelity** — any shortcut that stands in for a real stage MUST produce a state *equivalent* to that stage's real output, or downstream checks pass against states the system could never actually reach.

### Step 3A: Whole-Stack Module Smoke

**Resolve the loop from `qa/README.md`'s R/I/A/O table — the index, not the scripts.** Its Mechanism column links each phase to the script that runs it; that link is the contract, written by `/build-qa-bench`. Read the table — do NOT scan filenames or in-script headers (the header contract is retired and may be stale).

For each touched module's runbook, run the full loop:

- **a.** Read `qa/runbooks/{module}.md`
- **b.** Run the table's **RESET** mechanism (to clean state)
- **c.** Run the table's **INJECT** mechanism (test data)
- **d.** Run the table's **ACT** mechanism (bring stack up)
- **e.** Follow the runbook's **daily-loop / quick-start** path — bring the module up the way it is actually run
- **f.** Execute the scenarios under `## Act → Exercise the System`, **if the runbook has any**
- **g.** Run the table's **OBSERVE** mechanism
- **h.** Compare against `## Observe → Confirm Result` if present, otherwise against the expectations the quick-start path states

> **An empty scenario section is a valid, deliberate state — never a finding.** Pre-written per-module scenarios for hypothetical failures rot into theatre, and the invariant a runbook really guards is *"does this module come up and behave the way its daily loop says."* Feature-level verification belongs in checklists (Tactic C) and the fixture ladder (Tactic B), not here.
>
> When the pinned headings are present they are the contract and resolution is exact. When they're absent or empty, run the quick-start path and report *"no module scenarios (by design)"* — do **not** offer to build them, and do not guess which prose was meant to be the scenario.

**Cross-module scope**: if the touched files span multiple modules (or the change is inherently cross-cutting), also run the **playbook** (`qa/playbook.md`) — its Full-System Boot Order, Full-System Smoke, and any End-to-End Scenarios covering the touched paths. Runbooks verify each module in isolation; the playbook verifies they still work *connected*.

### Step 3B: Goal-Driven Fixture→e2e Ladder

Use this to verify one specific feature/flow (e.g. *"auto fish-in quarantine"*). The core insight: driving a whole flow through its real entry points is expensive (auth, full stack, slow), so pay the real cost only for the **one step you're validating**, and reach everything before it **cheaply via fixtures**.

1. **Decompose the flow into stages** and name the **step under test** — the single stage whose behavior you're validating (usually the changed or suspect one). List the upstream stages that must have happened first.
   > Example — auto fish-in quarantine: `create order → supplier order → prepare fish-in → CONFIRM fish-in (step under test) → observe tank state`.

2. **THE RULE — fixture the preconditions; exercise the step under test for real. NEVER fixture the step under test.** A shortcut standing in for the behavior you're validating proves nothing. (A shortcut standing in for an *upstream* stage is exactly right.)

3. **RESET the baseline** — either the Tactic-A RESET, or a scoped **snapshot** of just the entities the run will touch (capture their pre-state so teardown can restore them exactly).

4. **Build the precondition state by forward-chaining the upstream stages** — for each, use its `fixture(stage)` from `qa/fixtures/`. **No reset between stages** — each consumes the prior stage's accumulated state.

   Before using a fixture, read its header: a fixture marked `fidelity-checked: PENDING` at rung 2 or 3 has never been proven against the real stage — say so, and treat any assertion downstream of it as provisional.

   **If a needed fixture doesn't exist, stop and hand off to `/build-qa-test --fixture [stage]`.** Fixtures are the test layer's to build. Never improvise one mid-run: an ad-hoc fixture is unreviewed, unversioned, and its fidelity unproven, so every later run inherits a shortcut nobody signed off on.

5. **Exercise the step under test for real** — drive its *actual* entry point: the HTTP endpoint the UI/mobile calls, the scheduler endpoint, the real service method at the true boundary. Not an internal shortcut that bypasses the wiring.

6. **OBSERVE the goal outcome** — assert the real result (SQL query, response body, smoke check). For DB-facing steps use the **surgical pattern**: snapshot the disposable target(s) first, drive the step, assert the exact DB delta, so the check is precise and not masked by other data.

7. **TEARDOWN (finally)** — restore snapshots / delete created rows / reset touched entities, so the run leaves **zero residue** and is re-runnable. This runs even if an assertion failed.

8. **Fidelity check (periodic, not every run)** — occasionally run the REAL upstream stage (not its fixture) and assert its output matches what `fixture(stage)` produced. If they diverge, the fixture has drifted and is lying — hand it back to `/build-qa-test` before trusting further Tactic-B runs off it.

**Applicability & escape hatches.** The DB/HTTP mechanics above (SQL delta, cached token, endpoint) are *one common shape* — read them as examples, not the only form. Two assumptions ride under Tactic B; when either fails, adapt rather than force it:
- **State must be resettable** for RESET + TEARDOWN to hold. If the step has *irreversible* side effects (a real email/SMS, a payment, a non-idempotent external call) you cannot `finally { undo }` — route it through a **sandbox / test double / idempotency key**, or fall to Tactic A and assert the *intent* (the outbound call was issued) rather than the irreversible effect. For **non-persistent** systems (stateless, streaming, pure compute) "snapshot the rows" has no meaning — OBSERVE via the system's real output channel (emitted event, return value, log/trace) and TEARDOWN is a no-op.
- **The step under test needs an automatable entry point.** If it's **UI-only** (desktop GUI, mobile screen) with no service/HTTP seam, you cannot drive it for real — drive the **nearest automatable boundary** (the method/endpoint the UI calls) and **manual-verify** the UI layer, and say so. Do NOT relabel a boundary-driven run as full e2e.

### Step 3C: Guided Checklist Pass

Read the checklist at the given path. If it doesn't exist, offer `/build-qa-test --checklist [plan]` and stop.

1. **Bring the stack up** per the checklist's Preconditions (its runbook / the playbook).
2. **Run the automated rows first** — the checklist's Automated coverage table names them. Report pass/fail per row; these need no human.
3. **Walk the manual rows in order**, ticking each and noting defects inline. Do not tick a row you did not actually observe.
4. **Record the result** in the checklist's Result section: sign-off + date, or the defects found.

**On all-green — offer to archive, never archive automatically.** A checklist is archived *on sign-off*, and an automated green is not a human signing off: a checklist covering UI-bound steps can pass its automatable half while nobody looked at the rest. Present:

```
Checklist {name}: {n}/{n} green ({a} automated, {m} manual).
Archive to qa/checklists/completed/ as signed off? (y/n)
```

On **y**, follow the [Archive Plan component]([path-to-agent-memory-coding-skill]/components/archive-plan.md) with destination `qa/checklists/completed/`.

If **any** row failed or was skipped, do not offer the archive — say which rows are outstanding.

### Step 4: Present Findings

Any failure becomes a **Critical** finding. Present by invoking the `/wait-options` command procedure — run the command; its format rules are not in context.
Preamble: *"Runtime verification findings:"*

**STOP**. Wait for [USER-NAME]'s response.

If no findings, report: *"QA test run passed — runtime clean."* If the run was partial (unresolved phases, skipped modules), say **"passed, partial"** and name what didn't run — a clean result on an incomplete run is the easiest false confidence to ship.

### Step 5: Fix Cycle

Apply approved fixes in one batch. Re-run the loop (Step 3A, 3B, or 3C, whichever this run used) for the affected modules/flow. Repeat until clean or [USER-NAME] explicitly defers remaining items.

### Step 6: Log Results

- **Standalone mode**: Report results inline to [USER-NAME]:
  - Tactic used (A whole-stack smoke / B fixture→e2e ladder / C checklist / combination)
  - Touched modules + runbooks run; modules with no runbook coverage
  - For Tactic B: the flow, the step under test (driven for real), the fixtures used + their fidelity rungs
  - For Tactic C: rows green/red, automated vs manual split, archive decision
  - Playbook run (if cross-module): result, or N/A
  - Bench status (all phases resolved / partial — name the gaps)
  - R/I/A/O loop results (pass/fail); confirm teardown left zero residue
  - Findings + Fixed

- **Embedded mode**: Write results into the caller's runtime-verification section:
  - **Scope**: touched modules
  - **Bench Status**: all resolved / partial (which phases) / missing / skipped
  - **Runbooks Run**: list of `qa/runbooks/{module}.md` exercised; any module without one
  - **Playbook Run**: `qa/playbook.md` if cross-module (boot order + full-system smoke + E2E scenarios), or N/A
  - **R/I/A/O Results**: per-module pass/fail summary
  - **Findings**: runtime failures + severity, or *"No findings — runtime clean"*
  - **Fixed**: what was fixed from approved findings, or *"N/A"*

**Embedded mode return**: After Step 6, control returns to the caller, which proceeds to its next step.

---

## Integration With Other Procedures

- **/map-qa-instrument** — canonical home for the loop, ontology, ownership, and grading. Its index-integrity check is what guarantees the table this skill reads still resolves.
- **/build-qa-bench** — upstream. Builds the loop engine and writes the `qa/README.md` R/I/A/O table Step 3A resolves from.
- **/build-qa-test** — upstream. Builds what this skill *runs*: fixtures (Tactic B), runbook and playbook scenarios (Tactic A), checklists (Tactic C). A missing fixture, runbook, or checklist is a hand-off to it, never an improvisation here.
- **/high-wizard · /quick-wizard · /pixel-wizard** — **not** callers. Each stops at its **QA Handoff** step, delegating to `/build-qa-test --checklist` and leaving the plan explicitly *not runtime-verified*. Running that checklist is a separate, later invocation of this skill — which is why a wizard's completion report names the exact `/run-qa-test --checklist` command to run.
- **archive-plan component** — used by Tactic C to move a signed-off checklist into `qa/checklists/completed/`.

---

## Anti-Patterns

1. **Building anything mid-run.** A fixture, scenario, or runbook invented under run pressure is unreviewed, and it silently becomes the contract everyone runs against afterwards. Hand off to `/build-qa-test`.
2. **Fixturing the step under test.** A shortcut standing in for the behavior you're validating proves nothing (Tactic B, rule 2).
3. **Reporting a partial run as clean.** If phases didn't resolve or modules were skipped, the headline is "passed, partial" plus the gaps — not "passed".
4. **Leaving residue.** No teardown means the next run starts dirty and its result is meaningless. Wrap in try/finally.
5. **Calling a boundary-driven run "e2e".** If the real entry point is UI-only, drive the nearest automatable seam and *say so* — don't relabel it.
6. **Auto-archiving a green checklist.** Green is a result; sign-off is a decision. Offer, then let a human make it.
7. **Resolving a phase by filename.** The index is the contract. Guessing from a filename is how a run silently exercises the wrong script.
