# Build QA Bench

Build a project's QA **bench** — the rig the tests run on — map-driven and honest. Reads the audit from `/map-qa-instrument`, then fills the gaps by progressively writing `qa/README.md` (the R/I/A/O spine) across a 4-phase lifecycle: **DEFINE → BUILD → TEST → DOCUMENT**.

Scope is the **R/I/A/O loop engine only** — scripts · seeds · config, plus the `qa/README.md` index itself. A test bench resets to a known state, loads a specimen, drives it, and reads the output; that is exactly RESET → INJECT → ACT → OBSERVE. The **test layer** (runbooks · playbook · fixtures) belongs to `/build-qa-test`, the per-feature checklist to `/generate-qa-checklist`; the repeatable runtime proof belongs to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, the ownership split, and the `documented / tribal / missing` grading. This skill references *up* to those; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/build-qa-test` (build the tests) → `/run-qa-test` (run them).**

> **The `qa/README.md` R/I/A/O table is the single index, and this skill is its only writer.** `/run-qa-test` resolves the loop from it — which script is RESET / INJECT / ACT / OBSERVE — by the table's Mechanism **links**. Producing that table, and the mechanisms it points to, is this skill's core output. There is no in-script header contract; that model is retired.

## Arguments

`$ARGUMENTS`

- `/build-qa-bench` → **Default (incremental)**. Read the map, show the rig gap list (`tribal` + `missing`), pick one to build. One gap per run keeps it reviewable.
- `/build-qa-bench [phase|category]` → Target one directly: `reset`, `inject`, `act`, `observe`, `scripts`, `seeds`, `config`.
- `/build-qa-bench all` → Sweep every rig gap the map found in one run.

If no arguments provided, load the map and ask which gap to build.

> Test-layer targets (`runbooks`, `playbook`, `fixtures`) are **not** valid here — they belong to `/build-qa-test`, and `checklists` to `/generate-qa-checklist`. If one is passed, say so and hand off rather than building it.

---

## Procedure

*This procedure fills ONE document — `qa/README.md`, the R/I/A/O spine — progressively across 4 phases (DEFINE → BUILD → TEST → DOCUMENT). The doc is the source of truth. Never document ahead of what's built: a phase's Status becomes `documented` only after Phase 3 actually runs it.*

---

## Phase 0: Load the Map + Prepare the Spine

*Goal: gather the two inputs — the map (what this project's QA looks like today) and the README spine (what build writes into).*

### Step 1: Load the map

Read `qa/qa-map.md` + its sub-maps. If absent → **STOP**: *"No QA map — run `/map-qa-instrument create` first."* Build is map-driven — it never re-scans.

From the map, read two things:

1. **The R/I/A/O maturity table** — each phase's Status and, where one exists, the Mechanism link the map found (`documented` / `tribal` → a script exists; `missing` → nothing yet).
2. **The index-integrity table** — whether the existing README index resolves. A `DIVERGED` or dead-link row is a **repair job**, not a build job: the mechanism exists but the index points elsewhere. Fix the link in Phase 1 and say so; don't build a second script.

The `missing` phases are the build work — on a greenfield project, that's all four.

### Step 2: Read the template

Read the [QA README template]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md) — the R/I/A/O spine. Its HOW-TO block carries this same 4-phase lifecycle.

### Step 3: Prepare the spine

- `qa/README.md` **absent** → `cp [path-to-agent-memory-coding-skill]/templates/qa-readme-template.md ./qa/README.md`.
- `qa/README.md` **exists** → reconcile: keep the existing content, add only the sections it's missing. Never clobber a hand-written README.

Respect the project's real folder names throughout (the map records any drift, e.g. `qa/configs/` for config). Never create a parallel folder to satisfy a canonical name.

---

## Phase 1: DEFINE

*Goal: turn the map into the **index** — write each phase's intent into the README R/I/A/O table and carry over any mechanism the map already found. That table is both the spec Phase 2 builds against and the table `/run-qa-test` later resolves the loop from.*

### Step 4: Fill the R/I/A/O Loop table

Fill **only** the [## The R/I/A/O Loop]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#the-riao-loop) section. For each of RESET / INJECT / ACT / OBSERVE, fill its row:

- **What it means here** — the concrete intent (e.g. RESET = "tear down containers, DBs back to last seed"). Write this **even for a `missing` phase** — it's the spec Step 5 builds to.
- **Mechanism** — the link the map found (`documented` / `tribal`), or **leave empty** if `missing`. This link is the resolver: it's how `/run-qa-test` finds the mechanism, so linking an existing one here is all the wiring it needs — no header, no move, no rename.
- **Status** — carried from the map.

For a **diverged or dead** row from Step 1, repoint the link at the mechanism the scan actually found and note the correction — that alone may close the gap without building anything.

Fill **nothing else** in the README yet — you can't honestly document a loop that isn't built.

### ⛔ END OF PHASE 1

**STOP.** Present the filled R/I/A/O table to [USER-NAME]. It's the build spec: it shows what each phase must do, which mechanisms already exist vs. must be built, and any link repairs. Do not build until it's confirmed.

---

## Phase 2: BUILD

*Goal: make every row in the table link a real, working mechanism. ⛔ Prerequisite: Phase 1 confirmed.*

### Step 5: Build the missing loop mechanisms

**Scope: the R/I/A/O loop engine only** — the reset / inject / act / observe mechanisms (`scripts` + `seeds` + `config`). Build does **NOT** touch runbooks, the playbook, fixtures, or checklists. Those belong to `/build-qa-test` and `/generate-qa-checklist`: this skill builds the bench, not the tests run on it.

The default posture is **build**. Work each phase by its Status:

| Status | Action |
|---|---|
| `missing` | **Build** — create the mechanism (a reset script, a seed workflow, the config it needs), stubbed with a single `TODO:` for project specifics, then **link it in the table's Mechanism cell**. On a greenfield project, all four go this way. |
| `tribal` | **Link it** — the mechanism exists but nothing pointed at it. Adding the link in Step 4 *is* the promotion; the script keeps its name and location. Confirm it runs. |
| `documented` | **Confirm** — already linked and discoverable. Just confirm it runs. |

Build in loop order — RESET → INJECT → ACT → OBSERVE (config feeds INJECT/ACT) — so each phase's clean state is ready for the next. As each mechanism becomes real, its Mechanism cell links it: by the end of Phase 2, every row points at a working script.

For a `missing` phase, follow the [Build R/I/A/O Mechanisms component]([path-to-agent-memory-coding-skill]/components/build-riao-mechanisms.md) — the per-part (RESET / INJECT / ACT / OBSERVE) scaffold recipes — and shape the files per the [Templates](#templates) below.

> *The hard line: build only the missing engine parts; the index links everything else, and that index is the only contract `/run-qa-test` reads.*

---

## Phase 3: TEST

*Goal: prove each built phase actually runs before claiming it. ⛔ Prerequisite: Phase 2 done.*

### Step 6: Self-smoke each built phase

Run a **light self-smoke** on what you just built, using each recipe's "Done when" as the pass condition: does RESET actually reach a clean state? does INJECT actually load? Only after it runs may that phase's Status become a real `documented` — never fictionalize a green loop.

If a phase can only be run manually (a desktop app launched by hand), say so in its row rather than claiming a scripted pass.

The full repeatable runtime proof is **not** built here; delegate it to `/run-qa-test` and point the user there.

---

## Phase 4: DOCUMENT

*Goal: write reality back into the rest of the README, then re-audit. ⛔ Prerequisite: the loop actually runs (Phase 3).*

### Step 7: Fill First-Time Setup + Daily Loop

Fill [## First-Time Setup]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#first-time-setup) and [## Daily Loop]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#daily-loop) — the copy-pasteable run instructions, from the scripts that now actually work.

### Step 8: Fill Where Everything Lives + Where To Go Next

Fill [## Where Everything Lives]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#where-everything-lives) and [## Where To Go Next]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#where-to-go-next) — the front-door navigation, linking each category folder that exists + the map. Drop rows for categories this project doesn't have; never link a file that isn't there.

### Step 9: Fill Config Switching

Fill [## Config Switching]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#config-switching) — the project's exact local ↔ deploy swap. Invariant: committed config = deploy target; local overrides never committed.

### Step 10: Fill Known Gaps / Debts

Fill [## Known Gaps / Debts]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#known-gaps--debts) from the map's still-open rows — both the rig gaps this run didn't build **and** the test-layer gaps that are `/build-qa-test`'s, marked as such so the reader knows where each goes. Be honest: this is what's not yet trustworthy.

### Step 11: Clean up + refresh the map

1. Delete every `<!-- tip -->` and the HOW-TO block from `qa/README.md`.
2. Re-run `/map-qa-instrument --rescan` so the map's grades — and its index-integrity check — reflect the newly-built reality. The loop closes: **map → build → map.**

### Step 12: Completion report

Present a brief report to [USER-NAME]:
- Rig gaps built this run + links repaired + what stayed `documented` (confirmed).
- R/I/A/O loop status after the self-smoke, flagging any phase that is manual rather than scripted.
- README sections filled.
- Remaining rig gaps (deferred) and remaining test-layer gaps (→ `/build-qa-test`).
- The `--rescan` result, including index integrity.
- Pointer to `/build-qa-test` for the tests, then `/run-qa-test` for the full runtime proof.

---

## Templates

*The rig's file shapes. The [Build R/I/A/O Mechanisms component]([path-to-agent-memory-coding-skill]/components/build-riao-mechanisms.md) says what to build per phase; these say what the file looks like.*

- **The spine**: [qa-readme-template.md]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md) — the `qa/README.md` filled across all four phases.

### R/I/A/O script shape

Files at `qa/scripts/` (or `qa/` root if there will be ≤4 scripts). **Existing scripts keep their natural names and locations** — `teardown`, `import-seed`, `start-stack`, `smoke-check` are all fine. The filename patterns below are a readability suggestion for *new* scripts, never a requirement, because resolution happens through the README index, not the filename.

| Phase | Suggested filename | Examples |
|---|---|---|
| RESET | `reset-{scope}.{ext}` | `reset-stack`, `reset-db`, `teardown` |
| INJECT | `seed-{scope}.{ext}` | `seed-fixtures`, `seed-from-snapshot`, `import-seed` |
| ACT | `start-{scope}.{ext}` | `start-stack`, `start-module` |
| OBSERVE | `smoke-{scope}.{ext}` | `smoke-check`, `tail-logs` |

Every script — generated or adopted:
- **Exits non-zero on failure.** A script that always exits 0 makes the whole loop unable to report red.
- **Is safe to run twice** and **physically cannot reach a prod/shared store** (guard on the connection target, not on a comment).
- A newly generated stub carries a single `TODO:` line and nothing else — no boilerplate, no baked-in lessons.
- When adopting a script that already works, **link it and leave it alone** — do not rewrite it, rename it, move it, or add a header.

### Config inventory — `qa/config/REQUIRED.md`

```markdown
# {Project} — Required Config Inventory

> Every config key the system needs to start at all.

| Key | Used by | Status | Acquisition step / source |
|---|---|---|---|
| `RESEND_API_KEY` | bff (email send) | missing | Sign up at resend.com, free tier sufficient for QA |
| `DB_URL` | api | exists & documented | See `.env.local.template` |
| `STRIPE_WEBHOOK_SECRET` | api (webhooks) | tribal | Currently in a password manager — TODO: document |

## Acquisition Notes

<expand on any item that needs more than one line>
```

### Per-environment config templates

Placeholders only, **never** real secrets: `qa/config/.env.local.template`, `.env.qa.template`, `.env.production.template`. For .NET projects with `Web.config` / `App.config`: `qa/config/Web.Local.config.template` / `App.Local.config.template`.

Every template starts with a 2-line header:

```
# Committed config = deploy target. This template is the swap-IN for local mode.
# Never commit actual secrets — placeholders only.
```

### Seeds — `qa/seeds/`

Seeds are *sources*, not scripts: the dumps, snapshots, or generator inputs INJECT consumes. Record the **seed strategy** (`prod-snapshot` / `dummy` / `hybrid` / `none`) in the README's INJECT row, since it decides the mechanism shape. If seeds are large or contain real data, keep them out of git and document the acquisition step instead of committing them.

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Canonical home for the loop / ontology / ownership / grading. Supplies the gap list and the index-integrity check; called with `--rescan` at the end.
- **/build-qa-test** — downstream sibling. Owns everything this skill refuses: runbooks, playbook, fixtures, and the scenarios inside them. Bench first, then tests — a fixture has nothing to build against until the loop runs.
- **/generate-qa-checklist** — downstream sibling. Owns the per-feature checklist; its gate reads this skill's output as the project's opt-in signal.
- **/run-qa-test** — downstream. Build does a light self-smoke only; the repeatable runtime proof is `/run-qa-test`'s job, resolved from the index this skill writes.

---

## Anti-Patterns

1. **Fictionalizing a green loop.** A Status is `documented` only after Phase 3 actually ran it. Unbuilt or untested phases say so.
2. **Building without a map.** Build is map-driven — no `qa/qa-map.md` → stop and run `/map-qa-instrument create`. Never re-scan here.
3. **Documenting before building.** Phase 1 fills only the R/I/A/O intent; the rest of the README waits for Phase 4, so it describes reality, not intention.
4. **Building test-layer content.** Runbooks, playbook and fixtures are `/build-qa-test`'s, checklists `/generate-qa-checklist`'s. If the map shows those gaps, report them and hand off — don't quietly author half a test layer.
5. **Rewriting an adopted script.** A `tribal` mechanism is promoted by *linking* it in the index, not by moving, renaming, or restyling it. Touching it turns a one-line fix into a regression risk.
6. **Building a second script for a diverged index.** A `DIVERGED` row means the index points at the wrong file, not that the mechanism is missing. Repoint the link.
7. **Clobbering a hand-written README.** If `qa/README.md` exists, reconcile — add missing sections, preserve good content.
