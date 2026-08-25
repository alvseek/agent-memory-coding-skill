# Integration Test

Build and run one integration test end to end — the fixtures that reach its precondition, the test itself, and the run that proves it. Scope is a single real boundary.

**What makes a test integration is what it substitutes, not how much code it covers.** You construct the component in your own test process and hand it *one* real dependency — a database, an HTTP service, a queue, a filesystem. Everything else stays doubled. Because the test provisions its own world, it can run wherever that world can be provisioned: in CI where a container can be started, or in a QA session against the bench.

That line is the one this skill is built on. If the system is already running the way it runs in production and you reach it over a wire, the environment provisioned the world rather than your test — that is **system** level and belongs to `/run-qa-test`. In-process HTTP harnesses (`WebApplicationFactory`, `TestServer`, `supertest`) sit at the top of the integration range and are *not* system tests: you built the application inside your test process rather than starting it.

> **Unit tests are not built here.** They are authored in the wizard's implementation phases, where *"Tests written and passing"* is already a completion criterion. A `/unit-test` procedure is deferred because that path works today.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the artifact ontology, the ownership split, and the grading. This skill references *up* to it; it does not restate them.

> **Built per boundary, never up front.** A fixture only has meaning relative to the precondition a specific test needs, so there is no mode that scaffolds fixtures in advance — that produces a folder that lies about coverage.

## Arguments

`$ARGUMENTS`

- `/integration-test [boundary|feature]` → build and run the test for that boundary
- `/integration-test` → read the map, show which boundaries have no integration coverage, and ask

There is deliberately **no fixture-only mode**. A fixture with no test to consume it has no purpose, and an entry point that starts partway through a procedure inherits the steps before it without running them.

---

## Gate: Can a Test Run Here?

Call `/qa-status` and read its first two lines.

- **Bench built and stack up** → proceed.
- **Either missing** → report what `/qa-status` said, name what would fix it (`/map-qa-instrument create` → `/build-qa-bench`, or bring the stack up), and stop. Build nothing.

When a wizard invoked this, return the skip and its reason rather than stopping the sweep — the wizard records it in the plan's `## QA HANDOFF` section.

> **Why this gate is hard where `/generate-qa-checklist`'s is soft.** A checklist is human-runnable and needs no live anything, so its gate is only an opt-in signal. An integration test must actually execute against a real dependency to be worth writing, and a test authored but never run is a belief rather than an asset.

---

## Phase 1: DEFINE

### Step 1: Name the boundary

State the one real dependency this test crosses, and the component that crosses it. One boundary per run.

Prefer a boundary the map already lists as uncovered, and read `docs/flows/` (or whatever the orientation map lists) before inventing a decomposition — reusing the project's own description keeps the test aligned with how the system is actually built.

### Step 2: Name what stays doubled

Everything that is not the boundary under test. Write the list; it is the definition of this test's scope, and it is what stops an integration test drifting into an unacknowledged system test.

> **The rule this enforces**: one real dependency, everything else substituted. A test with three real dependencies is not a more thorough integration test — it is a system test nobody labelled, running without the environment guarantees a system test relies on.

### Step 3: Name the fixtures and the assertion

1. **Fixtures** — one per precondition the test cannot reach cheaply by calling the code under test. Name each, and state its intended **fidelity rung** (Step 4).
2. **Assertion** — the exact observable outcome, specific enough to fail. *"The order is saved"* is not an assertion; *"`llx_stock_mouvement` gains exactly one row with `type=3` for this order id"* is. If you cannot write a failing condition, you do not yet understand the check.

Either may legitimately be "not needed this run" — say so explicitly rather than producing an empty file.

### ⛔ END OF DEFINE

**STOP.** Present the boundary, the doubled list, the named fixtures with their rungs, and the assertion. This is the build spec: it shows what is real, what is faked, and what will be proven. Do not build until it is confirmed.

---

## Phase 2: BUILD

### Step 4: Build the fixtures

For each fixture named in Step 3, build it at the **highest fidelity available**. Work down this ladder and stop at the first rung the project supports:

| Rung | Form | Fidelity |
|---|---|---|
| 1 | **Reuse real captured state** — rows/payloads snapshotted from a real run of that stage | highest — it *is* the real output |
| 2 | **Call the real stage's entry point** with a cached token / service call, then keep the result | high — the real code path produced it |
| 3 | **Hand-rolled seed** (SQL insert, JSON payload) mirroring the stage's known output | lowest — a human's belief about the output |

Record the rung in the fixture's header (see the [Fixture header](#fixture-header)) — it is the honest measure of how far anything built on it can be trusted.

Each fixture must be:
- **Composable** — where preconditions stack, each consumes the prior one's accumulated state and adds only its own. No reset between them.
- **Idempotent or self-cleaning** — re-running must not stack duplicate state.
- **Teardown-paired** — it either registers what it created for teardown, or documents what the caller must restore.
- **Disposable-scoped where possible** — prefer a dedicated test entity and a recognizable marker prefix over touching live rows, so cleanup is provable.

Stub anything project-specific with a single `TODO:` rather than guessing a table name or endpoint.

### Step 5: Write the test

Drive the component through its real entry point with the boundary live. The test must:

- **Arrange** from the fixtures built in Step 4, never by hand-setting state those fixtures already produce.
- **Act** by calling the component the way production calls it — not an internal shortcut that bypasses the wiring the boundary depends on.
- **Assert** the exact condition from Step 3.
- **Clean up** what it created, through the fixtures' teardown pairing.

Name the test for the behaviour it protects, not for the plan, phase, or ticket that produced it.

---

## Phase 3: RUN

### Step 6: Run it, and make it fail first

Run the test. Then **prove it can fail**: revert the production behaviour it guards — comment the write, flip the condition — and confirm it goes red. Restore, and confirm green again.

A test that has never been red is a test whose assertion may not reach the code it names. This is the cheapest check available and it is the whole reason the test is worth keeping.

> **Restore before moving on, and verify it.** A mutation left on disk is the most expensive residue this procedure can produce, because everything downstream still passes. Check `git status` rather than trusting that you reverted it.

### Step 7: Fidelity check the fixtures

For each fixture built at **rung 2 or 3**, run the real upstream stage once and compare its output against what the fixture produces. They must be equivalent in everything the test reads.

- **Match** → record the check date in the fixture header.
- **Diverge** → the fixture is lying. Fix it before trusting the test, and note what diverged.

Rung-1 fixtures skip this — captured real state is its own proof.

> Skipping this is the most expensive shortcut available here. A drifted fixture makes every later run validate a state the system can never actually reach, and it surfaces as a mystery long after this session.

### Step 8: Teardown check

Run the teardown and confirm the run left **zero residue** — running the whole thing again from clean must produce the same result. A test that only passes the first time is not a test.

---

## Phase 4: RECORD

### Step 9: Link and record

- Place each new fixture in `qa/fixtures/` with a discoverable name so the map finds it, carrying the header below.
- In `qa/README.md`'s **Known Gaps / Debts**, record what this run did *not* cover: boundaries still without integration coverage, and any rung-2 or rung-3 fixture whose fidelity check is still pending.

Never write a coverage claim the Step 6–8 runs didn't earn.

### Step 10: Refresh the map

Re-run `/map-qa-instrument --rescan` so the map's grades reflect the newly-built reality. The loop closes: **map → build → map.**

### Step 11: Completion report

- Boundary tested, and what stayed doubled.
- Fixtures created, their rungs, and their fidelity-check results.
- Test name, and confirmation it was red before it was green.
- Teardown-clean confirmation.
- Remaining gaps + the `--rescan` result.

---

## Templates

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

- **/qa-status** — the gate. Its bench and stack lines decide whether this skill can run at all, and its pending-fixture count is fed by what this skill leaves unchecked.
- **/map-qa-instrument** — upstream. Canonical home for the loop, ontology, ownership and grading; supplies the uncovered-boundary list and is refreshed at Step 10.
- **/build-qa-bench** — upstream. Builds the rig, owns the `qa/README.md` index this skill records gaps in, and owns the runbooks and playbook that document the system this test runs against.
- **/generate-qa-checklist** — sibling. Owns the per-feature checklist, whose Automated column cites the tests built here.
- **/run-qa-test** — sibling, one level up. Runs system-level verification where the environment provisions the world: whole-stack smoke, the fixture→e2e ladder, and the guided checklist walk. The fixtures built here are what its ladder chains.
- **/high-wizard** — caller. A phase that crosses a real boundary invokes this during implementation, once Step 14's `/qa-status` gate came back ready.

---

## Anti-Patterns

1. **More than one real dependency.** That is a system test wearing an integration label, running without the environment guarantees a system test relies on. Name the second dependency and double it, or hand the case to `/run-qa-test`.
2. **Calling an in-process HTTP harness an e2e test.** You constructed the application; nobody started it. It is integration, at the top of the range.
3. **A test that has never been red.** Step 6 exists because an assertion that cannot fail is indistinguishable from one that passes.
4. **Leaving a mutation on disk.** Verify the restore with `git status`, not from memory — everything downstream stays green while the source is wrong.
5. **Skipping the fidelity check on a hand-rolled seed.** A rung-3 fixture is a guess about a stage's output; unchecked, it silently validates impossible states.
6. **Fixturing the thing under test.** Fixture the preconditions; drive the behaviour being validated for real. A shortcut standing in for it proves nothing and hides the bug you were looking for.
7. **Vague assertions.** *"Works correctly"* cannot fail, so it can never catch a regression. Write the exact delta.
8. **Building the rig here.** Scripts, seeds, config, runbooks and the playbook are `/build-qa-bench`'s. If the loop is missing the gate already stopped you — don't quietly build half a bench.
