# Map QA Instrument

Read-only audit of a project's QA instrument. Scans the **whole project** for existing R/I/A/O materials + the 7 QA artifact categories, grades each on **discoverability**, checks that the `qa/README.md` R/I/A/O index still resolves, and writes a set of map docs that link to what already exists in-place (or record "not found").

It **maps**, it never **builds** — filling the gaps it finds belongs to the builders: `/build-qa-bench` (the rig, the runbooks and the playbook), `/integration-test` (fixtures and integration tests) and `/generate-qa-checklist` (the per-feature checklist).

> **Canonical home.** This skill owns the R/I/A/O loop, the artifact ontology, the ownership split, and the grading rubric below. Every other QA skill references *up* to these definitions — do not duplicate them downward.

Pipeline: **`/map-qa-instrument` (audit) → `/build-qa-bench` (build the rig) → `/integration-test` (build and run the tests) → `/run-qa-test` (system-level runtime proof).**

Map files (in-folder, lowercase-kebab):

```
qa/
├── qa-map.md                        ← root index: R/I/A/O maturity + index integrity + links to every sub-map
├── qa-playbook-map.md               ← playbook = a root single-file category (no folder)
├── runbooks/qa-runbooks-map.md
├── checklists/qa-checklists-map.md
├── fixtures/qa-fixtures-map.md
├── config/qa-config-map.md
├── scripts/qa-scripts-map.md
└── seeds/qa-seeds-map.md
```

---

## Arguments

`$ARGUMENTS`

- `/map-qa-instrument` — **Load mode** (default, read-only). Load existing `qa-map.md` + sub-maps, staleness-check the linked materials, re-check index integrity, report. If no map exists: report and point to `create`.
- `/map-qa-instrument create` — **Create mode**. Whole-project scan → grade → write all maps. First-time setup.
- `/map-qa-instrument --rescan` — **Rescan mode**. Re-scan preserving human annotations; report what changed (added / re-graded / gone).
- `/map-qa-instrument [project-path]` — **Path override**. Combines with any mode; targets the named project root instead of cwd.

---

## Concepts (this skill's canonical definitions)

### The Universal QA Loop

Every QA setup, regardless of stack, is a single feedback loop:

```
RESET → INJECT → ACT → OBSERVE
```

- **RESET** — back to a known clean state (drop DBs, clear caches, uninstall APK, `compose down -v`)
- **INJECT** — get realistic-but-safe data in (fixtures, prod snapshots, seed scripts, generators)
- **ACT** — exercise the system the way users do (run app, click flows, send requests)
- **OBSERVE** — see what happened (logs, asserts, screenshots, traces, manual inspection)

This loop is the lens the map grades: for each phase, *does a discoverable mechanism exist?*

### The R/I/A/O index — the one contract

`qa/README.md` carries an **R/I/A/O Loop table** whose Mechanism column links each phase to the script that runs it. That table is the **single resolver**: `/run-qa-test` reads it to find each phase's mechanism. Not filenames, not in-script headers.

> **The `# R/I/A/O category:` in-script header is retired.** It was the old contract; a per-script convention drifts silently because nothing checks it. A single index can be verified in one place — which is what [index integrity](#c4-check-index-integrity) below does. Existing scripts may still carry the header; it is inert, and nothing should be written to depend on it.

The index is written by `/build-qa-bench`, verified here, and consumed by `/run-qa-test`.

### The 7 artifact categories

Four **artifact tiers** (the SRE/ops ontology) + three **loop-plumbing** categories that implement R/I/A/O.

> **Artifact ontology (runbook vs playbook vs checklist vs fixture)** — distinct tiers, each named per the SRE/ops convention:
> - **Runbook** (`qa/runbooks/{module}.md`) — the operational how-to for **one module**: preconditions, launch, reset/inject/act/observe for that module, config-switching, gotchas. Evergreen. Atomic.
> - **Playbook** (`qa/playbook.md`) — the **cross-module** strategy layer: connection map, full-system boot order, full-system smoke, and end-to-end scenarios that span modules. *References* the runbooks. Evergreen.
> - **Checklist** (`qa/checklists/{feature}.md` → `completed/`) — **per-feature** verification tied to a specific shipped change. Ephemeral; archived on sign-off. Not documentation — it is risk analysis with a pass/fail box.
> - **Fixture** (`qa/fixtures/{stage}.*`) — a **per-stage precondition-builder** that cheaply reproduces the end-state of one flow stage ("as if create-order completed"), so `/run-qa-test` Tactic B can reach a deep precondition without paying the full e2e cost for every upstream stage. Composable (each fixture feeds the next stage) and **fidelity-bound** (must mirror what the real stage writes). Built per-flow when needed — not up front.

Loop-plumbing categories:
- **Scripts** (`qa/scripts/*`) — the R/I/A/O executables. Resolved via the `qa/README.md` R/I/A/O table, **not** by filename or in-script header.
- **Config** (`qa/config/`) — the required-config inventory (`REQUIRED.md`) + per-environment templates.
- **Seeds** (`qa/seeds/`) — the test-data sources (DB dumps, snapshots, generators) that INJECT consumes.

### Who owns what (the ownership split)

The map creates nothing. Every category has exactly **one** builder — no category is shared, and no file has two owners.

| Category | Owner | Why |
|---|---|---|
| scripts · seeds · config | **`/build-qa-bench`** | The rig: what makes RESET / INJECT / ACT / OBSERVE executable. |
| runbooks · playbook | **`/build-qa-bench`** | How a human operates the rig — per module, and across modules. Written once the loop they document runs. |
| fixtures | **`/integration-test`** | The preconditions one test needs, built and proven alongside the test that consumes them. |
| checklists | **`/generate-qa-checklist`** | The per-feature, ephemeral half — one checklist per shipped change, archived on sign-off. |
| `qa/README.md` (the index) | **`/build-qa-bench`** | It *is* the R/I/A/O contract. One writer, so it can't drift against itself. |

> **The line**: a runbook documents how to drive one module through the loop, so its scenarios are test content and it belongs to the test builder. The scripts the runbook *invokes* belong to the bench. If you're unsure which side something is on, ask whether it would still exist if there were no features to verify — if yes, it's rig.

### The grading rubric (this skill's core contribution)

Every material is graded on **discoverability**, not mere existence. The tribal-vs-documented split is the whole point — it makes implicit knowledge visible and, unlike a throwaway table, **persists** it:

| Grade | Meaning |
|---|---|
| `exists-documented` | Found **and** discoverable — lives in `qa/` with a proper index entry, or is referenced from a README a newcomer would find. Usable without insider knowledge. |
| `exists-tribal` | Found **but** undiscoverable — a script outside `qa/` or unreferenced, run-steps buried in code/chat/someone's head, nothing in an index pointing to it. Works only if you already know it's there. |
| `missing` | Nothing found. |

---

## Prelude (all modes)

1. **Resolve project root** — `PROJECT_ROOT` = path arg if given, else cwd.
2. **Resolve QA dir** — `QA_DIR` = `<PROJECT_ROOT>/qa/`. Record `MAP_EXISTS` = whether `<QA_DIR>/qa-map.md` exists.
3. Jump to the matching mode block below — read only that block.

---

## Create Mode (`create` arg)

> Explicit user action. Writes map docs (and the folder skeleton to host them) — never instrument content.

### C1: Branch on existence

- `MAP_EXISTS = true` → confirm with [USER-NAME]: *"a QA map already exists — did you mean `--rescan`?"* Wait for confirmation.
- `MAP_EXISTS = false` → continue.

### C2: Detect project shape

Glob for shape signals so the scan knows its scope (submodule roots, stack, shell):

| Signal | Tells you |
|---|---|
| `.gitmodules` | Aggregate-with-submodules — scan each submodule root too |
| `package.json` with `workspaces` | Monorepo workspace |
| `docker-compose.yml` / `compose.yml` | Existing orchestration |
| `Makefile` / `Justfile` / `Taskfile.yml` | Existing run-script framework |
| `*.sln` / `*.csproj` | .NET — expect PowerShell scripts, `Web.config` |
| `pubspec.yaml` / `*.unity` | Flutter / Unity — device-based ACT |

Report the detected shape in one line.

### C3: Whole-project scan (per category)

For each category, glob/grep the **whole project** (not just `qa/`) and link materials **in-place**. The value is surfacing tribal materials that live *outside* `qa/`.

| Category | Canonical home | Scan the whole project for |
|---|---|---|
| **runbooks** | `qa/runbooks/` | existing `qa/runbooks/*.md`; per-module/submodule `README*` with run / getting-started / local-dev sections; root README "how to run"; `CONTRIBUTING.md` run steps |
| **playbook** | `qa/playbook.md` | existing `qa/playbook.md`; root README system/connection map; `docs/architecture/*`, `docs/flows/*`; a root multi-service `docker-compose*` describing boot order |
| **checklists** | `qa/checklists/` | existing `qa/checklists/**/*.md`; QA / test-plan / acceptance docs anywhere; `plans/**/deploy-instruction.md` checklists |
| **fixtures** | `qa/fixtures/` | existing `qa/fixtures/*`; factory/builder/test-data code (`*Factory*`, `*Builder*`, `*Fixture*`, `fixtures/`); seed-builder scripts; **precondition setup embedded inside test suites** (a common tribal home) |
| **config** | `qa/config/` | existing `qa/config/REQUIRED.md` + templates; config keys via `.env*`, `Web.config`/`App.config`, `appsettings*.json`, `process.env.X`, `Configuration["X"]`, `os.getenv(...)` |
| **scripts** | `qa/scripts/` | existing `qa/scripts/*` + role scripts anywhere — RESET (`teardown`/`reset`/`drop`), INJECT (`seed`/`import`/`restore`), ACT (`start`/`run`/`up`), OBSERVE (`smoke`/`health`/`tail`); `Makefile`/`Justfile` targets; `package.json` scripts. Identify each by role; grade `documented` only if linked from the README R/I/A/O table, else `tribal`. |
| **seeds** | `qa/seeds/` | existing `qa/seeds/**`; DB dumps (`*.bak`, `*.sql`, `*.dump`); snapshot exports; seed-data folders |

> **Folder-name drift.** The "Canonical home" column is the ontology default, not a guarantee. If the project already has an equivalent folder under a different name (e.g. `qa/configs/` for config), **use the existing folder** — place that category's sub-map inside it (named for the real folder, e.g. `qa-configs-map.md`) and record the drift in that map's Gaps. Never create a second parallel folder just to satisfy the canonical name. This rule binds every QA skill, not just this one.

### C4: Check index integrity

The R/I/A/O index is the contract the whole pipeline rests on, so the map verifies it rather than assuming it. Read `qa/README.md`'s R/I/A/O Loop table and, for each of the four phases, record:

| Check | Result |
|---|---|
| Row present with a **Mechanism** link? | `linked` / `empty` |
| Does the linked path **resolve** to a real file? | `resolves` / `dead link` |
| Is the linked file one the **C3 scan also found** for that role? | `agrees` / **`diverged`** |
| The row's stated **Status** | carried through |

**`diverged` is the finding this check exists for.** It means the index points somewhere the scan didn't independently identify as that role's mechanism — the README and reality have come apart, and every `/run-qa-test` run since then resolved against the wrong thing. Report it loudly; never silently prefer one source.

If `qa/README.md` is absent entirely → index status `missing`, and every phase grades from scripts alone (note in the map that the loop is unresolvable until `/build-qa-bench` writes the index).

### C5: Grade + roll up R/I/A/O

- **Per material**: apply the [grading rubric](#the-grading-rubric-this-skills-core-contribution) — `exists-documented` / `exists-tribal` / `missing`.
- **Per category**: the category's status = the best-graded material it holds (or `missing`).
- **Roll up the R/I/A/O loop** (for the root map) by tracing each phase to the categories that implement it:

| Phase | Backed by |
|---|---|
| RESET | scripts (RESET-role) + runbook "Reset" sections |
| INJECT | seeds + scripts (INJECT-role) + config |
| ACT | scripts (ACT-role) + runbooks (daily-loop / quick-start path) + playbook boot-order |
| OBSERVE | scripts (OBSERVE-role) + runbook "Observe" sections |

> **Do not grade a runbook down for an empty scenario section.** A runbook earns `exists-documented` on its *how to run this module* content — preconditions, daily loop, config switching, gotchas. Optional Act/Observe scenarios are added only when a real bug earns one; empty is the healthy default, and grading it as a gap would push projects to pre-write scenarios that rot.

A phase cannot grade `exists-documented` if its index row is `empty`, `dead link`, or `diverged` — discoverability *is* resolvability here.

### C6: Write the maps

Create the folder skeleton needed to host the maps (`qa/`, and each category folder that gets a sub-map), then write:

- One **sub-map per category** from the [Sub-Map template](#sub-map-template) — inside its folder (`qa/runbooks/qa-runbooks-map.md`, …); `qa-playbook-map.md` at `qa/` root. A category with no materials still gets its map, stating **NOT FOUND**.
- The **root `qa/qa-map.md`** from the [Root Map template](#root-map-template) — the R/I/A/O maturity table + the index-integrity table + links to every sub-map + a one-line verdict.

Stamp each map's `last scan` with today's date (ask for the date if unknown — never invent one).

### C7: Report

```
QA instrument mapped: qa/qa-map.md
  - R/I/A/O maturity: RESET={grade}, INJECT={grade}, ACT={grade}, OBSERVE={grade}
  - Index integrity: {n} resolve, {n} empty, {n} dead, {n} DIVERGED
  - Categories: {n} documented, {n} tribal, {n} missing
  - Sub-maps written: {count}
  - Top gaps (missing/tribal): {list}
Next: /build-qa-bench for rig, runbook and playbook gaps, /integration-test for fixture and boundary gaps, /generate-qa-checklist for a shipped change.
```

---

## Load Mode (bare arg, default)

> Read-only. Reports the existing map + flags staleness; does not scan or re-grade.

### L1: Branch on existence

- `MAP_EXISTS = false` → report `"No QA map for this project yet — run '/map-qa-instrument create' to scan and create."` and exit.
- `MAP_EXISTS = true` → continue.

### L2: Read maps

Read `qa/qa-map.md` and each linked sub-map into context.

### L3: Staleness check

For each linked material, compare its file mtime to the map's `last scan`:

```sh
stat -c %Y "[material-path]"
```

- material **mtime > last scan** → flag `changed since last map`.
- material **missing** → flag `gone since last map`.

### L4: Re-check index integrity

Re-run [C4](#c4-check-index-integrity)'s link-resolution checks only (cheap: read the README table, stat each linked path). Skip the `agrees / diverged` comparison — that needs a full scan, so a drifted index surfaces here as a **dead link** and otherwise waits for `--rescan`.

### L5: Report

```
QA map loaded: qa/qa-map.md (last scan {date})
  - R/I/A/O maturity: RESET={grade}, INJECT={grade}, ACT={grade}, OBSERVE={grade}
  - Index: {n}/4 phases resolve{, N DEAD LINKS}
  - {n} materials mapped across {n} categories
  - {n} changed / {n} gone since last scan → run '/map-qa-instrument --rescan' if drifted
```

---

## Rescan Mode (`--rescan` arg)

> Explicit refresh after work changed the QA surface. Preserves human-added annotations.

### R1: Branch on existence

- `MAP_EXISTS = false` → report `"No map to rescan — run '/map-qa-instrument create' first."` and exit.
- `MAP_EXISTS = true` → continue.

### R2: Snapshot annotations

Read the current maps. Capture per material any human-added `Notes` (anything beyond the auto-generated link + grade) — this is what we preserve.

### R3: Scan + grade

Execute **C2 → C3 → C4 → C5** as in Create Mode.

### R4: Merge + write

- Material still present → refresh its grade; keep its snapshot `Notes`.
- Material new → add it.
- Material in snapshot but no longer found → mark `gone` (don't delete the row — breadcrumb).

Rewrite all maps; update each `last scan` to today.

### R5: Report

```
QA map rescanned: qa/qa-map.md
  - {n} added | {n} re-graded | {n} gone
  - R/I/A/O maturity: RESET={grade}, INJECT={grade}, ACT={grade}, OBSERVE={grade}
  - Index integrity: {n} resolve, {n} empty, {n} dead, {n} DIVERGED
```

---

## Templates

### Root Map template

```markdown
# QA Instrument Map — {project}

> Read-only audit of the QA instrument. Generated by /map-qa-instrument (last scan {date}).
> This maps what EXISTS and how discoverable it is. Rig, runbook and playbook gaps → /build-qa-bench; fixture and boundary gaps → /integration-test; checklist gaps → /generate-qa-checklist.

## R/I/A/O loop maturity

| Phase | Grade | Backed by |
|---|---|---|
| RESET | {grade} | [teardown.ps1](scripts/teardown.ps1) |
| INJECT | {grade} | [import-seed.ps1](scripts/import-seed.ps1) · [seeds](seeds/qa-seeds-map.md) |
| ACT | {grade} | [start-stack.ps1](scripts/start-stack.ps1) |
| OBSERVE | {grade} | [smoke-check.ps1](scripts/smoke-check.ps1) |

## Index integrity — qa/README.md R/I/A/O table

> The table /run-qa-test resolves the loop from. `diverged` means the index and the scan
> disagree about which script owns a phase — fix before trusting any run.

| Phase | Index link | Resolves | Agrees with scan | Status in index |
|---|---|---|---|---|
| RESET | {link or —} | {yes / DEAD} | {yes / DIVERGED} | {documented/tribal/missing} |
| INJECT | | | | |
| ACT | | | | |
| OBSERVE | | | | |

## Category maps

| Category | Status | Owner | Map |
|---|---|---|---|
| Runbooks | {grade} | /build-qa-bench | [qa-runbooks-map.md](runbooks/qa-runbooks-map.md) |
| Playbook | {grade} | /build-qa-bench | [qa-playbook-map.md](qa-playbook-map.md) |
| Checklists | {grade} | /generate-qa-checklist | [qa-checklists-map.md](checklists/qa-checklists-map.md) |
| Fixtures | {grade} | /integration-test | [qa-fixtures-map.md](fixtures/qa-fixtures-map.md) |
| Config | {grade} | /build-qa-bench | [qa-config-map.md](config/qa-config-map.md) |
| Scripts | {grade} | /build-qa-bench | [qa-scripts-map.md](scripts/qa-scripts-map.md) |
| Seeds | {grade} | /build-qa-bench | [qa-seeds-map.md](seeds/qa-seeds-map.md) |

## Verdict

{one-line maturity summary + the top gaps, split by which builder owns them}
```

### Sub-Map template

```markdown
# QA {Category} Map — {project}

> Read-only audit of {category} materials. Generated by /map-qa-instrument (last scan {date}).
> Links point to materials in-place; grades reflect discoverability. Fill gaps → {owning builder}.

**Category status**: {exists-documented | exists-tribal | missing}
**Owner**: {/build-qa-bench | /integration-test | /generate-qa-checklist}

## Found

| Material | Location | Grade | Notes |
|---|---|---|---|
| {what it is} | [{path}]({relative-path}) | {grade} | {why this grade — e.g. "run steps in README, not a qa/ runbook"} |

## Gaps

- {expected-but-absent}: **NOT FOUND** — {what's missing}

## Last scan

{date} · scanned {N} locations
```

*(If a category found nothing: omit the Found table, and the whole map is the single line `**Category status**: missing` + a Gaps list of what a healthy instrument would have.)*

---

## Integration With Other Procedures

- **/build-qa-bench** — the rig builder. Reads this map to know what to skip vs. generate; owns scripts · seeds · config **and** writes the `qa/README.md` index this skill verifies.
- **/integration-test** — the test builder. Owns fixtures and the integration tests that consume them. Bench before tests — a fixture has nothing to build against until the loop runs.
- **/qa-status** — downstream reader. Reports whether the bench this skill grades is built and running, plus the fixture and checklist debt outstanding.
- **/generate-qa-checklist** — the checklist builder. Owns the per-feature checklist a shipped change earns; the wizards call it as their QA Handoff step.
- **/run-qa-test** — consumes the built instrument at runtime, resolving the loop from the index this skill checks. The map tells it which runbooks, scenarios, and fixtures exist before a run.
- **/map-orientation** — the general-docs sibling. Same read-only, map-then-act philosophy; this one is QA-scoped.

---

## Anti-Patterns

1. **Building instead of mapping.** This skill writes *map docs* only — never a runbook, script, fixture, or checklist body. Gap-filling belongs to the two builders. Creating folders to *host maps* is fine; creating instrument *content* is not.
2. **Grading on existence, not discoverability.** A script that runs but isn't linked from the README R/I/A/O index is `exists-tribal`, not `exists-documented`. The tribal grade is the point.
3. **Scanning only `qa/`.** The value is finding materials that live *outside* `qa/` — run steps in a submodule README, a reset script in `/tools`, fixtures inlined in a test suite. Scan the whole project; link in-place.
4. **Silently reconciling a diverged index.** When the README table and the scan disagree, report it. Picking a winner hides the drift and leaves every future run resolving against something nobody chose.
5. **Duplicating the ontology downward.** These definitions are canonical *here*. The builders and the runner reference up; they do not re-state, and this skill does not reference down to them.
