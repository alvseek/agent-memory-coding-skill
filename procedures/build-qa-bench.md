# Build QA Bench

Build a project's QA **bench** — the rig the tests run on — map-driven and honest. Reads the audit from `/map-qa-instrument`, then fills the gaps by progressively writing `qa/README.md` (the R/I/A/O spine) across a 4-phase lifecycle: **DEFINE → BUILD → TEST → DOCUMENT**.

Scope is the **rig** — the R/I/A/O loop engine (scripts · seeds · config), the `qa/README.md` index, and the documents that describe how to operate it: the per-module **runbooks** and the cross-module **playbook**. A test bench resets to a known state, loads a specimen, drives it, and reads the output; that is exactly RESET → INJECT → ACT → OBSERVE, and a runbook is how a human walks that loop for one module. What runs *on* the rig belongs elsewhere: fixtures and integration tests to `/integration-test`, the per-feature checklist to `/generate-qa-checklist`, the repeatable runtime proof to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, the ownership split, and the `documented / tribal / missing` grading. This skill references *up* to those; it does not restate them.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/integration-test` (build and run the tests) → `/run-qa-test` (system-level runtime proof).**

> **The `qa/README.md` R/I/A/O table is the single index, and this skill is its only writer.** `/run-qa-test` resolves the loop from it — which script is RESET / INJECT / ACT / OBSERVE — by the table's Mechanism **links**. Producing that table, and the mechanisms it points to, is this skill's core output. There is no in-script header contract; that model is retired.

## Arguments

`$ARGUMENTS`

- `/build-qa-bench` → **Default (incremental)**. Read the map, show the rig gap list (`tribal` + `missing`), pick one to build. One gap per run keeps it reviewable.
- `/build-qa-bench [phase|category]` → Target one directly: `reset`, `inject`, `act`, `observe`, `scripts`, `seeds`, `config`, `runbooks`, `playbook`.
- `/build-qa-bench all` → Sweep every rig gap the map found in one run.

If no arguments provided, load the map and ask which gap to build.

> `fixtures` is **not** a valid target here — fixtures exist to reach one test's precondition, so they belong to `/integration-test`; `checklists` belong to `/generate-qa-checklist`. If one is passed, say so and hand off rather than building it.

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

**Scope: the R/I/A/O loop engine only** — the reset / inject / act / observe mechanisms (`scripts` + `seeds` + `config`). This phase does **NOT** touch fixtures or checklists — those belong to `/integration-test` and `/generate-qa-checklist` — nor the runbooks and playbook, which this skill writes later in Phase 4, once the loop they document actually runs.

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

### Step 10: Write the runbooks and the playbook

A runbook is how a human operates one module's loop; the playbook is how the modules are operated together. Both link the mechanisms Phase 2 built rather than restating their commands, which is why they are written here and not before the loop runs.

**Per touched module**, create or refresh `qa/runbooks/{module}.md` from the [Runbook template](#runbook-template). Fill what this run actually taught you and leave a single `TODO:` per section rather than inventing module knowledge you do not have — a half-filled honest runbook beats a fully-filled speculative one. Its Reset and Inject sections **link** the README's mechanisms; they never copy the commands, which would drift the moment a script changes.

**If the project spans modules**, create or refresh `qa/playbook.md` from the [Playbook template](#playbook-template) — the connection map, the full-system boot order, and the full-system smoke.

Leave the `Act` / `Observe` scenario sections **empty**. They are part of the shape and `/run-qa-test` Tactic A resolves them by name when they exist, but nothing in this pipeline fills them yet; that owner is deferred. An empty scenario section is the documented default.

### Step 11: Fill Known Gaps / Debts

Fill [## Known Gaps / Debts]([path-to-agent-memory-coding-skill]/templates/qa-readme-template.md#known-gaps--debts) from the map's still-open rows — both the rig gaps this run didn't build **and** the test-layer gaps that belong to `/integration-test` and `/generate-qa-checklist`, marked as such so the reader knows where each goes. Be honest: this is what's not yet trustworthy.

### Step 12: Clean up + refresh the map

1. Delete every `<!-- tip -->` and the HOW-TO block from `qa/README.md`.
2. Re-run `/map-qa-instrument --rescan` so the map's grades — and its index-integrity check — reflect the newly-built reality. The loop closes: **map → build → map.**

### Step 13: Completion report

Present a brief report to [USER-NAME]:
- Rig gaps built this run + links repaired + what stayed `documented` (confirmed).
- R/I/A/O loop status after the self-smoke, flagging any phase that is manual rather than scripted.
- README sections filled.
- Runbooks written or refreshed this run, and whether the playbook was touched.
- Remaining rig gaps (deferred) and remaining test-layer gaps (→ `/integration-test`, `/generate-qa-checklist`).
- The `--rescan` result, including index integrity.
- Pointer to `/integration-test` for the tests, then `/run-qa-test` for the full runtime proof.

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

## Daily Loop / Quick Start
<the copy-pasteable path to bring THIS module up and actually use it — link the bench's ACT
 mechanism, then the module-specific launch. This is the runbook's real Act: it is what
 /run-qa-test Tactic A follows, and for most modules it is the whole of the invariant path.>

## Act → Exercise the System
<OPTIONAL — empty is the right default. Add a scenario ONLY when a real bug taught you a durable
 invariant worth re-running every time. Do NOT pre-write scenarios for hypothetical bugs: they
 rot, and a stale scenario is worse than none. Per-feature verification goes in a checklist.>

## Observe → Confirm Result
<OPTIONAL — the pass/fail expectations for the scenarios above, if there are any. Omit the whole
 section when the Act section is empty.>

## Config Switching
<files/lines to edit when going local ↔ deployed. Committed config = deploy target.>

## Troubleshooting
<symptoms → causes → fixes>

## Known Gotchas
<things that broke before, with workarounds>
```

> The `## Act → Exercise the System` and `## Observe → Confirm Result` headings are the contract `/run-qa-test` Tactic A resolves *when scenarios exist*. Keep them exact — but leaving them empty is a legitimate, common, and often correct state. Tactic A falls back to the Daily Loop path and reports "no module scenarios (by design)".

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

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Canonical home for the loop / ontology / ownership / grading. Supplies the gap list and the index-integrity check; called with `--rescan` at the end.
- **/integration-test** — downstream sibling. Owns fixtures and the integration tests that consume them. Bench first, then tests — a fixture has nothing to build against until the loop runs.
- **/qa-status** — downstream reader. Grades the bench this skill builds, and runs its OBSERVE mechanism as a liveness probe.
- **/generate-qa-checklist** — downstream sibling. Owns the per-feature checklist; its gate reads this skill's output as the project's opt-in signal.
- **/run-qa-test** — downstream. Build does a light self-smoke only; the repeatable runtime proof is `/run-qa-test`'s job, resolved from the index this skill writes.

---

## Anti-Patterns

1. **Fictionalizing a green loop.** A Status is `documented` only after Phase 3 actually ran it. Unbuilt or untested phases say so.
2. **Building without a map.** Build is map-driven — no `qa/qa-map.md` → stop and run `/map-qa-instrument create`. Never re-scan here.
3. **Documenting before building.** Phase 1 fills only the R/I/A/O intent; the rest of the README waits for Phase 4, so it describes reality, not intention.
4. **Building test-layer content.** Fixtures and integration tests are `/integration-test`'s, checklists `/generate-qa-checklist`'s. If the map shows those gaps, report them and hand off — don't quietly author half a test layer.
5. **Writing a scenario into a runbook.** The `Act` / `Observe` headings are part of the runbook shape, but nothing in this pipeline fills them yet — that owner is deferred. Leave them empty; an empty scenario section is the documented default, not a gap to close here.
6. **Rewriting an adopted script.** A `tribal` mechanism is promoted by *linking* it in the index, not by moving, renaming, or restyling it. Touching it turns a one-line fix into a regression risk.
7. **Building a second script for a diverged index.** A `DIVERGED` row means the index points at the wrong file, not that the mechanism is missing. Repoint the link.
8. **Clobbering a hand-written README.** If `qa/README.md` exists, reconcile — add missing sections, preserve good content.
