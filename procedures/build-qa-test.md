# Build QA Test

Build a project's QA **tests** — the things that run on the bench. Goal-driven and map-aware: you name a flow or feature, and this skill builds the assets needed to verify it — **fixtures** (the cheap preconditions), the **scenario** (what to exercise and what to expect), and the **checklist** (the human-runnable version).

Scope is the **test layer only** — `qa/fixtures/`, `qa/checklists/`, and the Act + Observe sections of `qa/runbooks/{module}.md` / the End-to-End Scenarios in `qa/playbook.md`. The **rig** it all runs on (scripts · seeds · config + the R/I/A/O table) belongs to `/build-qa-bench`; actually running these tests belongs to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, and the `documented / tribal / missing` grading. The Tactic-B consumption rules (the ladder, the fidelity discipline) live in `/run-qa-test`. This skill references *up* to both; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/build-qa-test` (build the tests) → `/run-qa-test` (run them).**

> **Built per-flow, never up front.** A fixture only has meaning relative to a flow stage, and a checklist only relative to a feature. There is no "scaffold all the tests" mode — that produces empty folders that lie about coverage. One flow per run.

## Arguments

`$ARGUMENTS`

- `/build-qa-test` → **Default**. Read the map, show what the bench can run but has no tests for, and ask which flow/feature to build.
- `/build-qa-test [flow|feature]` → Target one directly (e.g. `auto fish-in quarantine`, `customer order`, `packing handover`).
- `/build-qa-test --fixture [stage]` → Build a single missing fixture (the hand-off `/run-qa-test` makes when a Tactic-B run hits a gap).

If no arguments provided, load the map and ask which flow to build tests for.

---

## Procedure

*This skill produces test assets for **one flow** across 4 phases (DEFINE → BUILD → TEST → DOCUMENT), mirroring `/build-qa-bench`. Never document ahead of what's built: a fixture is only listed as available after Phase 3 actually ran it.*

---

## Phase 0: Load the Map + Gate on the Bench

*Goal: confirm there is a working rig to build tests against, and gather what already exists.*

### Step 1: Load the map

Read `qa/qa-map.md` + its sub-maps. If absent → **STOP**: *"No QA map — run `/map-qa-instrument create` first."* This skill is map-driven; it never re-scans.

From the map, note what already exists in the test layer: `qa/fixtures/` entries, `qa/checklists/` entries, and which runbooks already carry Act + Observe content.

### Step 2: Gate on the bench

Read `qa/README.md`'s **R/I/A/O Loop** table. Every phase must link a real mechanism with Status `documented`.

- **Any phase `missing` or unlinked** → **STOP**: *"The bench isn't built — RESET/INJECT/ACT/OBSERVE must run before tests can be built against them. Run `/build-qa-bench` first."*
- **Any phase `tribal`** → warn, and offer to continue: a tribal mechanism works but isn't discoverable, so the tests you build on it inherit that fragility.

> **Why this gate is hard.** A fixture's job is to produce the state a real stage would have left behind. Without a working RESET you cannot get to a known baseline to compare against, and without a working OBSERVE you cannot prove the fixture landed. Building tests on an unbuilt bench produces assets nobody can verify.

### Step 3: Pick the flow

If the flow wasn't passed as an argument, present what the bench can currently run alongside what has no test coverage, and ask [USER-NAME] which flow or feature to build for. One per run.

Prefer flows that already have a documented shape to build from — check `docs/flows/` (or whatever the orientation map lists) before inventing a decomposition.

---

## Phase 1: DEFINE

*Goal: decompose the flow and decide exactly which assets this run will produce. ⛔ Prerequisite: Phase 0 gate passed.*

### Step 4: Decompose the flow into stages

Write the stage chain end to end, then name the **step under test** — the single stage whose behavior is being validated. Everything before it is a **precondition** to be reached cheaply.

> Example — auto fish-in quarantine:
> `create order → supplier order → prepare fish-in → CONFIRM fish-in (step under test) → observe tank state`

Mark each upstream stage with what it would need:

| Stage | Role | Fixture needed? |
|---|---|---|
| create order | precondition | yes — none exists |
| supplier order | precondition | reuse existing `qa/fixtures/supplier-order.*` |
| prepare fish-in | precondition | yes — none exists |
| **confirm fish-in** | **step under test** | **never** — driven for real |
| observe tank state | assertion | n/a — OBSERVE mechanism |

> **The rule this table enforces**: fixture the preconditions, exercise the step under test for real. A shortcut standing in for the behavior you're validating proves nothing. (Canonical form: `/run-qa-test` Tactic B, rule 2.)

### Step 5: Name the three deliverables

State plainly what this run will produce:

1. **Fixtures** — one per upstream stage that lacks one. Name each and state its **fidelity source** (see Step 6's ladder).
2. **Scenario** — where the Act + Observe pair will be written: a module's `qa/runbooks/{module}.md` if single-module, or `qa/playbook.md`'s End-to-End Scenarios if it crosses modules.
3. **Checklist** — `qa/checklists/{flow}.md`, the human-runnable version for when the automated path isn't available (UI-only steps, or a release gate someone signs off).

Any of the three may legitimately be "not needed this run" — say so explicitly rather than producing an empty file.

### ⛔ END OF PHASE 1

**STOP.** Present the stage table + the three named deliverables to [USER-NAME]. This is the build spec: it shows what gets faked, what gets driven for real, and what gets written where. Do not build until it's confirmed.

---

## Phase 2: BUILD

*Goal: produce the named assets. ⛔ Prerequisite: Phase 1 confirmed.*

### Step 6: Build the fixtures

For each fixture named in Step 5, build it at the **highest fidelity available**. Work down this ladder and stop at the first rung the project supports:

| Rung | Form | Fidelity |
|---|---|---|
| 1 | **Reuse real captured state** — rows/payloads snapshotted from a real run of that stage | highest — it *is* the real output |
| 2 | **Call the real stage's API** with a cached token / service call, then keep the result | high — the real code path produced it |
| 3 | **Hand-rolled seed** (SQL insert, JSON payload) mirroring the stage's known output | lowest — a human's belief about the output |

Record the rung in the fixture itself as a comment header, because it is the honest measure of how much a Tactic-B run built on it can be trusted.

Each fixture must be:
- **Composable** — it consumes the prior stage's accumulated state and adds only its own. No reset between stages.
- **Idempotent or self-cleaning** — re-running it must not stack duplicate state.
- **Teardown-paired** — it either registers what it created for teardown, or documents what the caller must restore.

Stub anything project-specific with a single `TODO:` rather than guessing a table name or endpoint.

### Step 7: Build the scenario

Write the Act + Observe pair into the location chosen in Step 5.

- **Act** — the concrete steps that drive the step under test through its **real entry point** (the endpoint the UI calls, the scheduler trigger, the service method at the true boundary). If the only entry point is UI-only, write the nearest automatable seam as the Act, and mark the UI layer explicitly as manual-verify. Do not label a boundary-driven scenario as e2e.
- **Observe** — the exact expected outcome, specific enough to fail: the SQL delta, the response field, the state transition. *"Order appears correctly"* is not an expectation; *"`llx_stock_mouvement` gains one row with `type=3` for the confirmed fish-in"* is.

### Step 8: Build the checklist

Write `qa/checklists/{flow}.md` — the ordered, human-runnable steps with a pass/fail box per step, plus what to do when a step fails. This is what gets used when the automated path can't run, or when someone signs off a release by hand.

Skip this step only if Phase 1 explicitly declared it not needed.

---

## Phase 3: TEST

*Goal: prove the assets work before claiming them. ⛔ Prerequisite: Phase 2 done.*

### Step 9: Run the fixture chain

RESET to a clean baseline, then run the fixtures in stage order and confirm the chain actually reaches the precondition state the step under test expects. This is the fixture equivalent of the bench's self-smoke — a fixture that has never run is a guess.

If the chain doesn't reach the precondition, fix the fixture now. Do not proceed with a chain you know is broken.

### Step 10: Fidelity check on the new fixtures

For each fixture built at **rung 2 or 3**, run the REAL upstream stage once and compare its output against what the fixture produces. They must be equivalent in everything the step under test reads.

- **Match** → record the check date in the fixture header.
- **Diverge** → the fixture is lying. Fix it before it's used, and note what diverged.

Rung-1 fixtures skip this — captured real state is its own proof.

> Skipping this step is the single most expensive shortcut available here: a drifted fixture makes every later run validate a state the system can never actually reach, and the failure surfaces as a mystery long after this session.

### Step 11: Teardown check

Run the teardown and confirm the run left **zero residue** — re-running the whole chain from clean must produce the same result. A test that only passes the first time is not a test.

---

## Phase 4: DOCUMENT

*Goal: write reality back, then re-audit. ⛔ Prerequisite: the assets actually ran (Phase 3).*

### Step 12: Link the assets

- Add each new fixture to `qa/fixtures/` and make sure the map will find it (in-folder, discoverable name).
- Confirm the scenario is in place in its runbook or the playbook.
- Link the checklist from the flow's runbook so someone arriving at the module finds it.

### Step 13: Record honest status

In `qa/README.md`'s **Known Gaps / Debts** section, record what this run did *not* cover: stages still without fixtures, any rung-3 fixture whose fidelity check is pending, and any step that is manual-verify rather than driven.

Never write a coverage claim the Phase 3 runs didn't earn.

### Step 14: Refresh the map

Re-run `/map-qa-instrument --rescan` so the map's grades reflect the newly-built reality. The loop closes: **map → build → map.**

### Step 15: Completion report

Present a brief report to [USER-NAME]:
- Flow built for, and the step under test.
- Fixtures created + the fidelity rung of each; fidelity-check results.
- Scenario written (where) + checklist written (or explicitly skipped).
- Teardown-clean confirmation.
- Remaining gaps + the `--rescan` result.
- Pointer to `/run-qa-test [flow]` to actually run it.

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Canonical home for the loop / ontology / grading. Supplies the gap list; called with `--rescan` at the end.
- **/build-qa-bench** — upstream sibling. Builds the rig these tests run on. Phase 0 gates on its output: no working R/I/A/O loop, no tests.
- **/run-qa-test** — downstream. Consumes everything this skill produces: fixtures for Tactic B, scenarios for Tactic A. When a run hits a missing fixture it hands back here via `--fixture [stage]` rather than improvising one.
- **/setup-qa-instrument** — the legacy monolith. Its fixture and checklist template shapes are reused here until they migrate over.

---

## Anti-Patterns

1. **Fixturing the step under test.** The one thing that must be driven for real. A fixture standing in for it proves nothing and hides the bug you were looking for.
2. **Scaffolding empty fixture/checklist folders.** An empty `qa/checklists/` reads as "we have checklists" to everyone who sees it. Build per-flow or build nothing.
3. **Claiming a fixture works before running it.** Phase 3 exists because an unrun fixture is a belief, not an asset.
4. **Skipping the fidelity check on a hand-rolled seed.** A rung-3 fixture is a human's guess about a stage's output; unchecked, it silently validates impossible states.
5. **Vague expectations.** "Works correctly" cannot fail, so it can never catch a regression. Write the exact delta.
6. **Building the rig here.** Scripts, seeds, and config are `/build-qa-bench`'s. If the loop is missing, stop and send the user there — don't quietly build half a bench.
