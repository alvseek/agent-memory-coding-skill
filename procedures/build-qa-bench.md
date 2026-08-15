# Build QA Bench

Build a project's QA **bench** — the rig the tests run on — map-driven and honest. Reads the audit from `/map-qa-instrument`, then fills the gaps by progressively writing `qa/README.md` (the RIAO spine) across a 4-phase lifecycle: **DEFINE → BUILD → TEST → DOCUMENT**.

Scope is the **R/I/A/O loop engine only** — scripts · seeds · config. A test bench resets to a known state, loads a specimen, drives it, and reads the output; that is exactly RESET → INJECT → ACT → OBSERVE. The **test layer** (fixtures · checklists · scenarios) belongs to `/build-qa-test`; the repeatable runtime proof belongs to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, and the `documented / tribal / missing` grading. This skill references *up* to those; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/build-qa-test` (build the tests) → `/run-qa-test` (run them).**

> **The `qa/README.md` R/I/A/O table is the single index.** `/run-qa-test` resolves the loop from it — which script is RESET / INJECT / ACT / OBSERVE — by the table's Mechanism **links**, not from in-script headers. Producing that table (and the mechanisms it points to) is this skill's core output.

## Arguments

`$ARGUMENTS`

- `/build-qa-bench` → **Default (incremental)**. Read the map, show the gap list (`tribal` + `missing`), pick one to build. One gap per run keeps it reviewable.
- `/build-qa-bench [phase|category]` → Target one directly (e.g. `reset`, `inject`, `fixtures`, `config`).
- `/build-qa-bench all` → Sweep every gap the map found in one run.

If no arguments provided, load the map and ask which gap to build.

---

## Procedure

*This procedure fills ONE document — `qa/README.md`, the RIAO spine — progressively across 4 phases (DEFINE → BUILD → TEST → DOCUMENT). The doc is the source of truth. Never document ahead of what's built: a phase's Status becomes `documented` only after Phase 3 actually runs it.*

---

## Phase 0: Load the Map + Prepare the Spine

*Goal: gather the two inputs — the map (what this project's QA looks like today) and the README spine (what build writes into).*

### Step 1: Load the map

Read `qa/qa-map.md` + its sub-maps. If absent → **STOP**: *"No QA map — run `/map-qa-instrument create` first."* Build is map-driven — it never re-scans.

From the map's R/I/A/O maturity table, read each phase's Status and, where one exists, the **Mechanism link** the map found:
- `documented` / `tribal` → a script already exists; the map links it.
- `missing` → nothing exists yet; no link.

The `missing` phases are the build work — on a greenfield project, that's all four.

### Step 2: Read the template

Read the [QA README template]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md) — the RIAO spine. Its HOW-TO block carries this same 4-phase lifecycle.

### Step 3: Prepare the spine

- `qa/README.md` **absent** → `cp [path-to-agent-memory-coding-skill]/templates/qa-readme-template.md ./qa/README.md`.
- `qa/README.md` **exists** → reconcile: keep the existing content, add only the sections it's missing. Never clobber a hand-written README.

---

## Phase 1: DEFINE

*Goal: turn the map into the **index** — write each phase's intent into the README R/I/A/O table and carry over any mechanism the map already found. That table is both the spec Phase 2 builds against and the table `/run-qa-test` later resolves the loop from.*

### Step 4: Fill the R/I/A/O Loop table

Fill **only** the [## The R/I/A/O Loop]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#the-riao-loop) section. For each of RESET / INJECT / ACT / OBSERVE, fill its row:

- **What it means here** — the concrete intent (e.g. RESET = "tear down containers, DBs back to last seed"). Write this **even for a `missing` phase** — it's the spec Step 5 builds to.
- **Mechanism** — the link the map found (`documented` / `tribal`), or **leave empty** if `missing`. This link is the resolver: it's how `/run-qa-test` finds the mechanism, so linking an existing one here is all the wiring it needs — no header, no move.
- **Status** — carried from the map.

Fill **nothing else** in the README yet — you can't honestly document a loop that isn't built.

### ⛔ END OF PHASE 1

**STOP.** Present the filled R/I/A/O table to [USER-NAME]. It's the build spec: it shows what each phase must do, and which mechanisms already exist vs. must be built. Do not build until it's confirmed.

---

## Phase 2: BUILD

*Goal: make every row in the table link a real, working mechanism. ⛔ Prerequisite: Phase 1 confirmed.*

### Step 5: Build the missing loop mechanisms

**Scope: the R/I/A/O loop engine only** — the reset / inject / act / observe mechanisms (`scripts` + `seeds` + `config`). Build does **NOT** touch docs (`runbooks` / `playbook`), `checklists`, or `fixtures` — `/map-qa-instrument` surfaces those via links, in-place. Build never moves, promotes, or authors them: it builds the bench, not the tests run on it.

The default posture is **build**. Work each phase by its Status:

| Status | Action |
|---|---|
| `missing` | **Build** — create the mechanism (a reset script, a seed workflow, the config it needs), stubbed with a single `TODO:` for project specifics, then **link it in the table's Mechanism cell**. On a greenfield project, all four go this way. |
| `documented` / `tribal` | **Confirm** — the mechanism exists and Step 4 already linked it. That link *is* the wiring (`/run-qa-test` resolves from the README table, not from in-script headers). Just confirm it runs. |

Build in loop order — RESET → INJECT → ACT → OBSERVE (config feeds INJECT/ACT) — so each phase's clean state is ready for the next. As each mechanism becomes real, its Mechanism cell links it: by the end of Phase 2, every row points at a working script.

For a `missing` phase, follow the [Build R/I/A/O Mechanisms component]([path-to-agent-memory-coding-skill]/components/build-riao-mechanisms.md) — the per-part (RESET / INJECT / ACT / OBSERVE) scaffold recipes.

> *The hard line: build only the missing engine parts; the map links everything else, and the README table is the index `/run-qa-test` reads.*

---

## Phase 3: TEST

*Goal: prove each built phase actually runs before claiming it. ⛔ Prerequisite: Phase 2 done.*

### Step 6: Self-smoke each built phase

Run a **light self-smoke** on what you just built: does RESET actually reach a clean state? does INJECT actually load? Only after it runs may that phase's Status become a real `documented` — never fictionalize a green loop. The full repeatable runtime proof is **not** built here; delegate it to `/run-qa-test` and point the user there.

---

## Phase 4: DOCUMENT

*Goal: write reality back into the rest of the README, then re-audit. ⛔ Prerequisite: the loop actually runs (Phase 3).*

### Step 7: Fill First-Time Setup + Daily Loop

Fill [## First-Time Setup]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#first-time-setup) and [## Daily Loop]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#daily-loop) — the copy-pasteable run instructions, from the scripts that now actually work.

### Step 8: Fill Where Everything Lives + Where To Go Next

Fill [## Where Everything Lives]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#where-everything-lives) and [## Where To Go Next]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#where-to-go-next) — the front-door navigation, linking each category folder + the map.

### Step 9: Fill Config Switching

Fill [## Config Switching]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#config-switching) — the project's exact local ↔ deploy swap. Invariant: committed config = deploy target; local overrides never committed.

### Step 10: Fill Known Gaps / Debts

Fill [## Known Gaps / Debts]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#known-gaps--debts) from the map's still-open `tribal` / `missing` rows (anything this run didn't build). Be honest — this is what's not yet trustworthy.

### Step 11: Clean up + refresh the map

1. Delete every `<!-- tip -->` and the HOW-TO block from `qa/README.md`.
2. Re-run `/map-qa-instrument --rescan` so the map's grades reflect the newly-built reality. The loop closes: **map → build → map.**

### Step 12: Completion report

Present a brief report to [USER-NAME]:
- Gaps built this run (promoted / scaffolded) + what stayed `documented` (confirmed).
- R/I/A/O loop status after the self-smoke.
- README sections filled.
- Remaining gaps (deferred to a future run) + the `--rescan` result.
- Pointer to `/run-qa-test` for the full runtime proof.

---

## Templates

- **The spine**: [qa-readme-template.md]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md) — the RIAO-definition `qa/README.md`, filled across all four phases.
- **Loop-engine shapes** (reset / inject / act / observe script · seed workflow · config `REQUIRED.md`): reuse the relevant Step-7 template shapes in `/setup-qa-instrument` when building a `missing` mechanism. Build only creates loop-engine parts — runbook / checklist / fixture shapes are out of scope (the map links those).

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Build requires its map (the gap list) and calls `--rescan` at the end to close the loop. Canonical home for the loop / ontology / grading definitions.
- **/build-qa-test** — downstream sibling. Owns everything this skill deliberately refuses: fixtures, checklists, and the runbook/playbook Act+Observe scenarios. Bench first, then tests — a fixture has nothing to build against until the loop runs.
- **/run-qa-test** — downstream. Build does a light self-smoke only; the repeatable runtime proof is `/run-qa-test`'s job.
- **/setup-qa-instrument** — the legacy monolith that this skill + `/map-qa-instrument` replace. Its Step-7 template shapes are reused until they migrate here.

---

## Anti-Patterns

1. **Fictionalizing a green loop.** A Status is `documented` only after Phase 3 actually ran it. Unbuilt / untested phases say so.
2. **Building without a map.** Build is map-driven — no `qa/qa-map.md` → stop and run `/map-qa-instrument create`. Never re-scan here.
3. **Documenting before building.** Phase 1 fills only the R/I/A/O intent; the rest of the README waits for Phase 4, so it describes reality, not intention.
4. **Building docs / checklists / fixtures.** Those aren't build's — `/map-qa-instrument` links them in-place. Build only creates *missing loop-engine* mechanisms (scripts / seeds / config).
5. **Clobbering a hand-written README.** If `qa/README.md` exists, reconcile — add missing sections, preserve good content.
