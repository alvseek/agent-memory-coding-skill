# Build QA Test

Build a project's QA **tests** — everything that runs on the bench. Goal-driven and map-aware: you name a flow, a shipped plan, or a single missing fixture, and this skill builds what's needed to verify it.

Scope is the **test layer**: `qa/runbooks/`, `qa/playbook.md`, `qa/checklists/`, `qa/fixtures/`, and the Act + Observe scenarios inside the runbooks and the playbook. The **rig** it all runs on (scripts · seeds · config + the `qa/README.md` R/I/A/O index) belongs to `/build-qa-bench`; actually running these belongs to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, the ownership split, and the `documented / tribal / missing` grading. The Tactic-B consumption rules live in `/run-qa-test`. This skill references *up* to both; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/build-qa-test` (build the tests) → `/run-qa-test` (run them).**

> **Built per-flow and per-feature, never up front.** A fixture only has meaning relative to a flow stage; a checklist only relative to a shipped change. There is no "scaffold all the tests" mode — that produces empty folders that lie about coverage.

## Arguments

`$ARGUMENTS`

| Invocation | Trigger | Builds |
|---|---|---|
| `/build-qa-test [flow]` | you're about to verify a flow or feature | fixtures + the Act/Observe scenario + the runbook or playbook that holds it |
| `/build-qa-test --checklist [plan]` | a wizard plan just shipped | the per-feature checklist |
| `/build-qa-test --fixture [stage]` | `/run-qa-test` hit a missing fixture mid-run | that one fixture |
| `/build-qa-test` | — | read the map, show what the bench can run but has no tests for, and ask |

Flow mode builds *before* a run; checklist mode builds *after* a feature lands. Same owner, different moment.

---

## Phase 0: Load the Map + Gate on the Bench

*Runs in every mode. Goal: confirm there is a working rig to build tests against, and gather what already exists.*

### Step 1: Load the map

Read `qa/qa-map.md` + its sub-maps. If absent → **STOP**: *"No QA map — run `/map-qa-instrument create` first."* This skill is map-driven; it never re-scans.

Note what already exists in the test layer: `qa/fixtures/` entries, `qa/checklists/` (active and `completed/`), which runbooks exist, and whether `qa/playbook.md` does. Respect the project's real folder names — the map records any drift.

### Step 2: Gate on the bench

Read `qa/README.md`'s **R/I/A/O Loop** table, and the map's **index-integrity** table.

| Bench state | Action |
|---|---|
| All four phases linked + `documented` | Proceed. |
| Any phase `tribal` | **Warn and offer to continue** — it works but isn't discoverable, so tests built on it inherit that fragility. |
| Any phase `missing` or unlinked | **STOP**: *"The bench isn't built — RESET/INJECT/ACT/OBSERVE must run before tests can be built against them. Run `/build-qa-bench` first."* |
| Any row `DEAD` or `DIVERGED` | **STOP** — the index points at the wrong mechanism. `/build-qa-bench` repairs the link; building tests now would validate against a loop nobody chose. |

> **Why this gate is hard.** A fixture's job is to produce the state a real stage would have left behind. Without a working RESET you cannot reach a known baseline to build against, and without OBSERVE you cannot prove the fixture landed. Tests built on an unbuilt bench are unverifiable by construction — they look like coverage and are not.

**Exception — checklist mode.** A checklist is human-runnable and does not require a scripted loop, so `--checklist` may proceed on a `missing` bench. Warn once, and record in the checklist's Preconditions that the stack must be brought up by hand.

Then jump to the matching mode block below — read only that block.

---

## Flow Mode (`[flow]` arg, or bare)

*Builds the assets to verify one flow, across 4 phases (DEFINE → BUILD → TEST → DOCUMENT), mirroring `/build-qa-bench`. Never document ahead of what's built: a fixture is only listed as available after Phase 3 actually ran it.*

### F1: Pick the flow

If the flow wasn't passed, present what the bench can currently run alongside what has no test coverage, and ask [USER-NAME] which flow or feature to build for. One per run.

Prefer flows that already have a documented shape — check `docs/flows/` (or whatever the orientation map lists) before inventing a decomposition. Reusing the project's own flow doc keeps the test aligned with how the system is actually described.

### F2: DEFINE — decompose the flow

Write the stage chain end to end, then name the **step under test** — the single stage whose behavior is being validated. Everything before it is a **precondition** to be reached cheaply.

> Example — auto fish-in quarantine:
> `create order → supplier order → prepare fish-in → CONFIRM fish-in (step under test) → observe tank state`

Mark each upstream stage with what it needs:

| Stage | Role | Fixture |
|---|---|---|
| create order | precondition | build — none exists |
| supplier order | precondition | reuse `qa/fixtures/supplier-order.*` |
| prepare fish-in | precondition | build — none exists |
| **confirm fish-in** | **step under test** | **never** — driven for real |
| observe tank state | assertion | n/a — the OBSERVE mechanism |

> **The rule this table enforces**: fixture the preconditions, exercise the step under test for real. A shortcut standing in for the behavior you're validating proves nothing. (Canonical form: `/run-qa-test` Tactic B, rule 2.)

### F3: DEFINE — name the deliverables

State plainly what this run will produce:

1. **Fixtures** — one per upstream stage that lacks one. Name each and state its intended **fidelity rung** (F5).
2. **Scenario** — the Act + Observe pair, and where it goes: a module's `qa/runbooks/{module}.md` if single-module, or `qa/playbook.md`'s End-to-End Scenarios if it crosses modules.
3. **Host document** — if the runbook or playbook that should hold the scenario doesn't exist yet, this run creates it (F6). Say so.

Any deliverable may legitimately be "not needed this run" — say so explicitly rather than producing an empty file.

### ⛔ END OF DEFINE

**STOP.** Present the stage table + the named deliverables to [USER-NAME]. This is the build spec: it shows what gets faked, what gets driven for real, and what gets written where. Do not build until it's confirmed.

### F4: BUILD — the host document

If the scenario's home doesn't exist, create it now from the [Runbook template](#runbook-template) or [Playbook template](#playbook-template).

A runbook created here is a **skeleton plus this flow's scenario** — Goal, Preconditions, the four R/I/A/O sections, Config Switching, Troubleshooting, Gotchas. Fill what this flow teaches you and leave the rest as a single `TODO:` per section rather than inventing module knowledge you don't have. A half-filled honest runbook beats a fully-filled speculative one.

The runbook's Reset / Inject sections **link the bench's mechanisms** — they do not restate the commands, which would drift the moment a script changes.

### F5: BUILD — the fixtures

For each fixture named in F3, build it at the **highest fidelity available**. Work down this ladder and stop at the first rung the project supports:

| Rung | Form | Fidelity |
|---|---|---|
| 1 | **Reuse real captured state** — rows/payloads snapshotted from a real run of that stage | highest — it *is* the real output |
| 2 | **Call the real stage's entry point** with a cached token / service call, then keep the result | high — the real code path produced it |
| 3 | **Hand-rolled seed** (SQL insert, JSON payload) mirroring the stage's known output | lowest — a human's belief about the output |

Record the rung in the fixture's header (see the [Fixture header](#fixture-header)) — it is the honest measure of how far a Tactic-B run built on it can be trusted.

Each fixture must be:
- **Composable** — it consumes the prior stage's accumulated state and adds only its own. No reset between stages.
- **Idempotent or self-cleaning** — re-running must not stack duplicate state.
- **Teardown-paired** — it either registers what it created for teardown, or documents what the caller must restore.
- **Disposable-scoped where possible** — prefer a dedicated test entity and a recognizable marker prefix over touching live rows, so cleanup is provable.

Stub anything project-specific with a single `TODO:` rather than guessing a table name or endpoint.

### F6: BUILD — the scenario

Write the Act + Observe pair into the host document, under these **exact headings** — `/run-qa-test` resolves them by name:

- `## Act → Exercise the System`
- `## Observe → Confirm Result`

**Act** — the concrete steps that drive the step under test through its **real entry point** (the endpoint the UI calls, the scheduler trigger, the service method at the true boundary). If the only entry point is UI-only, write the nearest automatable seam as the Act and mark the UI layer explicitly as manual-verify. Never label a boundary-driven scenario as e2e.

**Observe** — the exact expected outcome, specific enough to fail. *"Order appears correctly"* is not an expectation; *"`llx_stock_mouvement` gains one row with `type=3` for the confirmed fish-in"* is. If you cannot write a failing condition, you do not yet understand the check.

Keep a runbook's scenarios to the module's **invariant** path. Per-feature variants belong in a checklist; cross-module paths belong in the playbook.

### F7: TEST — run the fixture chain

RESET to a clean baseline, then run the fixtures in stage order and confirm the chain actually reaches the precondition the step under test expects. This is the fixture equivalent of the bench's self-smoke — a fixture that has never run is a guess.

If the chain doesn't reach the precondition, fix it now. Do not proceed with a chain you know is broken.

### F8: TEST — fidelity check

For each fixture built at **rung 2 or 3**, run the REAL upstream stage once and compare its output against what the fixture produces. They must be equivalent in everything the step under test reads.

- **Match** → record the check date in the fixture header.
- **Diverge** → the fixture is lying. Fix it before it's used, and note what diverged.

Rung-1 fixtures skip this — captured real state is its own proof.

> Skipping this is the most expensive shortcut available here. A drifted fixture makes every later run validate a state the system can never actually reach, and it surfaces as a mystery long after this session.

### F9: TEST — teardown check

Run the teardown and confirm the run left **zero residue** — re-running the whole chain from clean must produce the same result. A test that only passes the first time is not a test.

### F10: DOCUMENT — link and record

- Place each new fixture in `qa/fixtures/` with a discoverable name so the map finds it.
- Confirm the scenario sits under the pinned headings in its runbook or the playbook.
- If a runbook was created, link it from `qa/README.md`'s Where Everything Lives.
- In `qa/README.md`'s **Known Gaps / Debts**, record what this run did *not* cover: stages still without fixtures, any rung-3 fixture whose fidelity check is pending, any step that is manual-verify rather than driven.

Never write a coverage claim the F7–F9 runs didn't earn.

### F11: DOCUMENT — refresh the map

Re-run `/map-qa-instrument --rescan` so the map's grades reflect the newly-built reality. The loop closes: **map → build → map.**

### F12: Completion report

- Flow built for, and the step under test.
- Fixtures created + fidelity rung of each; fidelity-check results.
- Scenario written (where); runbook or playbook created (or reused).
- Teardown-clean confirmation.
- Remaining gaps + the `--rescan` result.
- Pointer to `/run-qa-test [flow]` to actually run it.

---

## Checklist Mode (`--checklist [plan]` arg)

*Builds a per-feature checklist from a shipped change. Called by the wizards after Final Runtime Verification, or standalone.*

### K1: Read the plan for SCOPE

Read the plan (or the change set, if no plan). Extract only **what changed**:

- the modules and apps touched, and which are *not* touched
- the acceptance criteria and any contracts the plan pinned
- what the plan claims is already covered by automated tests

This is the **input**, not the authority. The plan tells you where to look; it does not tell you what to check.

### K2: Derive RISK independently

Now work out what the change could **break**. This is the half a plan cannot give you, and it is the reason the checklist exists.

Draw on:
- **Invariants** — state rules that must hold before and after. Write each as *a thing to disprove*, not a thing to confirm.
- **Regression surface** — what else reads or writes the same state, and what the change could have silently altered for it.
- **Boundaries and error paths** — empty, zero, already-in-that-state, concurrent, and the failure branch nobody exercised.
- **Cross-module effects** — what downstream consumers assume about the data this change now produces differently.
- **History** — prior checklists in `qa/checklists/completed/` and past defects in this area. Bugs cluster.

> **Why this step is non-negotiable.** The author of a change cannot see the case they didn't think of — if they had, they'd have coded it. A checklist derived only from the plan tests that the developer did what they said, not that the system still works, so every item passes by construction. Two shapes, to make the difference concrete:
>
> | | |
> |---|---|
> | Plan-restating | *"Confirm auto-checklab creates a pending lab request."* — restates the feature |
> | Risk-derived | *"Verify `FishInDate` is not nulled by release or unhold."* — probes what the feature could have broken |

### K3: Write the checklist

Use the [Checklist template](#checklist-template) at `qa/checklists/{feature}.md`.

- Lead with a **terminology / state-model block** if the change turns on states a tester must hold in their head.
- Give a **single happy-path scenario first** that walks the whole change end to end, then per-area sections to isolate a failure.
- Mark each item **automated** (naming the test) or **manual**, so nobody re-runs by hand what CI already proves, and nobody assumes the automated half covers the manual half.
- Note which items are UI-bound — those are the ones an all-green automated run does **not** cover.

### K4: Report

Feature, source plan, item count split automated vs manual, and the pointer to `/run-qa-test --checklist qa/checklists/{feature}.md`.

---

## Fixture Mode (`--fixture [stage]` arg)

*The hand-off `/run-qa-test` makes when a Tactic-B run hits a missing fixture.*

Build the one named fixture: **F5** (build at the highest available rung) → **F7** (prove it reaches the state) → **F8** (fidelity check if rung 2 or 3) → record it in `qa/fixtures/` and report. Then point back at the run that needed it.

Do not expand scope. If building it reveals that *other* stages also lack fixtures, name them and stop — that's a flow-mode run, and quietly building four fixtures under a one-fixture request is how a run turns into an afternoon.

---

## Templates

### Runbook template

File: `qa/runbooks/{module}.md`. An operational how-to — **not** a 7Q README.

```markdown
# {Module} — QA Runbook

> Tells the whole story of QA-ing this module. Read top-to-bottom first time; jump-to-section later.

## Goal
<single sentence: what this runbook helps you accomplish>

## Preconditions
<what must be running first; link the bench's ACT mechanism from qa/README.md>
<link required config from qa/config/REQUIRED.md>

## Reset → Clean State
<link the bench's RESET mechanism; add module-specific extras only>

## Inject → Realistic Data
<link the bench's INJECT mechanism; note the seed strategy>

## Act → Exercise the System
<numbered scenarios: step + expected result. Cover the module's INVARIANT path, not every variant.>

## Observe → Confirm Result
<where to look: logs, UI, SQL asserts. How to tell pass from fail.>

## Config Switching
<files/lines to edit when going local ↔ deployed. Committed config = deploy target.>

## Troubleshooting
<symptoms → causes → fixes>

## Known Gotchas
<things that broke before, with workarounds>
```

> The `## Act → Exercise the System` and `## Observe → Confirm Result` headings are the contract `/run-qa-test` Tactic A resolves. Keep them exact.

### Playbook template

File: `qa/playbook.md`. Only for multi-module projects — a single-app project's one runbook carries the whole story.

```markdown
# {Project} — QA Playbook

> The cross-module strategy layer: connection map + boot order + full-system smoke + end-to-end
> scenarios that span modules. References the per-module runbooks in qa/runbooks/.

## Connection Map

| From | To | Protocol | Port | Auth | Notes |
|---|---|---|---|---|---|

## Full-System Boot Order
1. <e.g. DB first — see qa/runbooks/{db}.md>
2. <e.g. BE next — see qa/runbooks/{be}.md>

## Full-System Smoke
<commands or steps to verify the whole connected stack at once>

## End-to-End Scenarios
<numbered cross-module scenarios. Each step names the module + links its runbook.
 Cover system invariants, not every variant.>
```

### Checklist template

File: `qa/checklists/{feature}.md` → archived to `completed/` on sign-off.

```markdown
# {Feature} — QA Checklist

**Source**: <plan or change set this verifies>
**Purpose**: <what a tester confirms by running this>
**Apps under test**: <modules touched — and note what is deliberately NOT touched>

## Terminology & state model (read first)
<only if the change turns on states the tester must hold in their head>

**Key invariants** (each is a thing to *disprove*):
- <invariant>

## Happy path — single end-to-end scenario (run this first)
<numbered walk of the whole change; each step points at its detailed section below>

## Automated coverage
| Checklist item | Automated test | Still manual |
|---|---|---|

## Checks
- [ ] <observable behavior + expected result>
- [ ] <edge case / error path + expected result>

## Result
<sign-off + date, or defects found>
```

### Fixture header

Every fixture carries, as a comment at the top:

```
# fixture: {stage}
# produces: {the end-state it reproduces}
# fidelity: {rung 1 reuse-snapshot | rung 2 real-entry-point | rung 3 hand-rolled-seed}
# fidelity-checked: {date, or "PENDING — do not trust for assertions"}
# teardown: {what the caller must restore, or "self-cleaning"}
```

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Canonical home for the loop / ontology / ownership / grading. Supplies the gap list; called with `--rescan` at the end.
- **/build-qa-bench** — upstream sibling. Builds the rig these tests run on and owns the `qa/README.md` index. Phase 0 gates on its output: no working R/I/A/O loop, no tests.
- **/run-qa-test** — downstream. Consumes everything built here: fixtures for Tactic B, runbook scenarios for Tactic A, checklists for a guided manual pass. A missing fixture comes back here via `--fixture`, never improvised there.
- **/high-wizard · /quick-wizard · /pixel-wizard** — callers. After Final Runtime Verification, each offers to build the shipped feature's checklist via `--checklist`.
- **/setup-qa-instrument** — the legacy monolith whose runbook / playbook / checklist / fixture shapes now live here.

---

## Anti-Patterns

1. **Fixturing the step under test.** The one thing that must be driven for real. A fixture standing in for it proves nothing and hides the bug you were looking for.
2. **Restating the plan.** A checklist whose every item mirrors an acceptance criterion tests only that the developer did what they said. The items that earn their place are the ones probing what the change could have broken.
3. **Scaffolding empty fixture or checklist folders.** An empty `qa/checklists/` reads as "we have checklists" to everyone who sees it. Build per-flow, per-feature, or build nothing.
4. **Claiming a fixture works before running it.** F7 exists because an unrun fixture is a belief, not an asset.
5. **Skipping the fidelity check on a hand-rolled seed.** A rung-3 fixture is a guess about a stage's output; unchecked, it silently validates impossible states.
6. **Vague expectations.** "Works correctly" cannot fail, so it can never catch a regression. Write the exact delta.
7. **Inventing module knowledge to fill a runbook.** A `TODO:` is honest; a plausible-sounding wrong command costs the next person an hour.
8. **Building the rig here.** Scripts, seeds, and config are `/build-qa-bench`'s. If the loop is missing, stop and send the user there — don't quietly build half a bench.
9. **Restating bench commands in a runbook.** Link the mechanism from the README index instead; a copied command drifts the moment the script changes.
