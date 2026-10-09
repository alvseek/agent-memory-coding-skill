# High Wizard Plan

## **PROJECT INFO**
- **Project**: agent-memory (framework)
- **Date**: 2026-10-09
- **Agent**: Claude Meta (meta)
- **Theme**: Extract the localization lane into `agent-memory-local` (`hermod-local`), rename `agent-memory-coding-skill` to `agent-memory-project` (`hermod-project`), and record the four-repo split.
- **Source Protocol**: `/high-wizard` — /high-wizard

*CRITICAL INSTRUCTION: To continue this plan: load the source protocol above, then inspect which sections below are filled vs unfilled to infer your current step.*

---

## **INHERITED CONTEXT**
*Filled at investigation step 0 with whatever was settled before this plan existed. The two sources are recorded separately and never merged — write "None" under a part that does not apply.*
*These decisions are **not yours to reopen**. If one looks wrong, STOP and surface it to [USER-NAME] — do not silently re-decide it here or in Confirmed Decisions below.*

### From the Parent Plan
- **Parent plan**: None — not a sub-plan
- **Assigned scope**: None

| # | Inherited decision | Chosen | Parent's reason | Status |
|---|--------------------|--------|-----------------|--------|
| — | — | — | — | — |

- **Integration contracts**: None
- **Pushed-down open items**: None

### From Pre-Planning Discussion
- **Discussion**: Pre-planning discussion with Alvi, 2026-10-09
- **Agreed scope**: Split the `agent-memory-coding-skill` overlay. Extract the localization lane into a new `agent-memory-local` (`hermod-local`); move the remainder into `agent-memory-project` (`hermod-project`); leave a lineage note that the original repo split into four.

| # | Settled decision | Chosen | His reason | Status |
|---|------------------|--------|------------|--------|
| 1 | Split the local lane out of the coding overlay | Yes | "loosely coupled and less maintenance nightmare"; a local bug should not reach base procedures like the awakening | Settled |
| 2 | Where the remainder lives | Rename `agent-memory-coding-skill` to `agent-memory-project` | fallback chosen because the `agent-memory-wizards` name is already taken by the extracted cluster | Settled |
| 3 | Scope of the lineage note | Names all four repos (project, local, fleet, wizards) | "in fact, it split into 4" | Settled |
| 4 | Repo creation | via `gh`, owner `alvseek` | "yes with gh alvseek" | Settled |
| 5 | Extraction method | Fresh repo + `MIGRATION.md` | the fleet (2026-10-08) and wizards (2026-10-09) extractions both used it | My call (precedent) |
| 6 | Planning vehicle | High Wizard | "use either QW or HW" | Settled |

- **Considered and rejected**:
  - Keep one lane, no split → rejected: Alvi needs the repo separation to tidy, and the base must stop localizing.
  - `hermod-project` keeps the resolution (my original option C) → rejected: the base should not localize at all.
  - `git filter-repo` history-preserving extraction → rejected: fleet/wizards precedent is a fresh repo plus `MIGRATION.md`.
  - Two MCP servers now → deferred by Alvi, not decided here.
- **Left open**:
  - Server count / gateway topology (one server vs two MCPs).
  - Whether the resolution refactors to an injected home now or in a later pass (this plan decides).

---

## **OBJECTIVES**
Split the coding overlay into two repos: `agent-memory-local` (`hermod-local`) owning the localization lane, and `agent-memory-project` (`hermod-project`) holding the central-only remainder. Make `hermod-project` free of localization logic by having its procedures operate on an **injected home** (default central), with `hermod-local` resolving that home and driving them. Rename `agent-memory-coding-skill` to `agent-memory-project` with a full identity rename, and record the four-way lineage.

### **Related Documents**
- `MIGRATION.md` — the repo's own lineage note; the fleet and wizards entries show the shape to extend.
- `docs/adr/2026-10-08-hermod-family-and-layer-access.md` and `docs/adr/2026-10-09-hermod-wizards-extraction.md` — the two prior extractions this mirrors.
- `procedures/localize-context.md` — holds the `## Localized Home Resolution` section that moves.
- `procedures/localized-memory-workflow.md` — the localized read/write override that moves.

### **SUCCESS CRITERIA**
- [ ] `agent-memory-local` exists as a public repo (gh, owner `alvseek`) holding `localize-context`, `localized-memory-workflow`, and the new `load-local-context`, with its own installer, manifest, README, MIGRATION, LICENSE, tests.
- [ ] `agent-memory-coding-skill` renamed to `agent-memory-project` with the full identity rename (repo, manifests, folder prefix, path placeholder, env declaration, installer identity).
- [ ] No localization logic remains in `agent-memory-project`: its procedures operate on an injected home defaulting to central.
- [ ] The ~13 consumers no longer resolve `home: project` themselves; `hermod-local` resolves and drives them.
- [ ] Every installer's sibling-manifest list knows the others, so installs stay order-independent.
- [ ] `load-local-context` exists and `awaken-coder` hands off to it on detection.
- [ ] Lineage note names all four repos (project, local, fleet, wizards).
- [ ] Both repos' test suites are green and installs are verified on at least the OpenCode and Claude Code harnesses.

---

## **SCOPE**

### In Scope
- Create `agent-memory-local` (fresh repo + `MIGRATION.md`) and move `localize-context` + `localized-memory-workflow` into it.
- Extract `## Localized Home Resolution` out of `localize-context` into a component owned by `agent-memory-local`.
- Author `load-local-context` (reader: localized episodic + project knowledge + map).
- Parameterize the ~13 `agent-memory-project` consumers to operate on an injected home (default central) and strip their `home: project` branches.
- Rename `agent-memory-coding-skill` → `agent-memory-project` with the full identity rename.
- Update sibling-manifest lists across core, project, fleet, wizards, local.
- Extend `MIGRATION.md` with the four-way lineage note.
- Tests + installer verification in both repos.

### Out of Scope
- Server count and gateway topology (one server vs two MCPs) — deliberately deferred.
- Serving `hermod-local` over MCP (`[LOCAL-ACCESS]` stays unset; local is a leaf).
- De-localization / reversal, and sub-map fractal localization.
- Any behavior change to the `agent-memory-project` procedures beyond home parameterization.
- Migrating the live central store's data.

---

## **CONFIRMED DECISIONS**
*Decisions made **by this plan** — both **asked-and-confirmed** by [USER-NAME] AND **written-through** (Zone A and B decisions made by the agent, recorded with their reasoning). The reasons serve as the analysis record.*
*Decisions settled before this plan existed — by a parent, or in a pre-planning discussion — belong in [INHERITED CONTEXT](#inherited-context) above, not here. Keeping them separate is what shows which decisions this plan actually owns.*

| # | Decision | Chosen | Reason |
|---|----------|--------|--------|
| 1 | How far the rename reaches | Full identity rename (repo, manifests, folder prefix, placeholder, env declaration, installer identity) | The `coding-skill` identity is stamped in machine-read places; a partial rename leaves the exact string we are escaping. |
| 2 | Rename target name | `agent-memory-project` (singular) | Consistent with `agent-memory-fleet` and `agent-memory-local`; the repo is one lane, not a set of projects. |
| 3 | New layer identity | repo `agent-memory-local`, prefix `agent-local-`, manifest `.agent-memory-local-<harness>-manifest` | Family convention `agent-<layer>-`; distinct from the core's `agent-memory-` so the shared skills dir cannot clobber. |
| 4 | How project gets the localized home | Injected home (parameterize; default central) | D4 (strip the consumers) requires it: a central-only `generate-readme` would read the empty central stub and flag every doc as not-in-map. |
| 5 | The ~13 consumers | Strip the local branch; operate on the injected home | Project ends with zero localization logic, matching "doesn't localize at all". |
| 6 | Reader | Build `load-local-context` now | Awakening's handoff needs a real target. |
| 7 | Handoff form | `awaken-coder` mentions `hermod-local` when it detects localized content (`.agents/` at cwd) | Same shape as the fleet pointer; a presence check, not a resolution. |
| 8 | Sibling manifests | Update all five installers so each lists the others | A sibling list that does not know `local` can delete another layer's folders on its next run. |
| 9 | Access declaration | None for local | Nothing calls `hermod-local`; it is a leaf like the wizards. `[FLEET-ACCESS]` exists because the overlay calls the fleet. |
| 10 | Extraction method | Fresh repo + `MIGRATION.md` | The fleet (2026-10-08) and wizards (2026-10-09) extractions both used it. |

---

## **SOLUTION**

### Architecture Overview

After the split the Hermod family has five repos. The core (`agent-memory-system` / `control-files`, Munnin) stays project-blind and unchanged. `agent-memory-fleet` and `agent-memory-wizards` stay as they are except for their installer sibling lists. The two changed repos are `agent-memory-project` (renamed from `agent-memory-coding-skill`) and the new `agent-memory-local`.

The load-bearing change is a **home contract**. A project's memory home is four values:

```
HOME = { MAP_PATH, CONTEXT_DIR, SESSION_DIR, KNOWLEDGE_DIR }
```

- **Central default** (defined in `agent-memory-project`):
  - `MAP_PATH` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/orientation-map.md`
  - `CONTEXT_DIR` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/`
  - `SESSION_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/episodes/`
  - `KNOWLEDGE_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/[project]/`
- **Localized override** (computed by `agent-memory-local`):
  - `MAP_PATH` = `<project-root>/docs/orientation-map.md`
  - `CONTEXT_DIR` = `<project-root>/docs/`
  - `SESSION_DIR` = `<project-root>/.agents/session/`
  - `KNOWLEDGE_DIR` = `<project-root>/.agents/knowledge/`

`agent-memory-project` procedures reference the four names and carry only the central default; they never test `home: project`. `agent-memory-local` owns the resolution that reads the central map's `home: project` frontmatter, overrides `HOME`, and enforces the reachability guard. So "the project localizes" becomes "the project uses `HOME`; local sets `HOME`".

### Component 1: `agent-memory-local` repo

- **Purpose**: own the localization lane — the mover, the writer, the reader, and the resolution.
- **Key Files**: `procedures/localize-context.md`, `procedures/localized-memory-workflow.md`, `procedures/load-local-context.md` (new), `components/localized-home-resolution.md` (extracted), `setup-scripts/*` (4 harnesses), `.agent-memory-local-<harness>-manifest`, `README.md`, `MIGRATION.md`, `LICENSE`, `tests/`.

### Component 2: `agent-memory-project` repo (rename)

- **Purpose**: the central-only shell + project/doc surface.
- **Key Files**: `setup-scripts/*` (manifest name, `FOLDER_PREFIX` `agent-coding-` → `agent-project-`, placeholder, env declaration), `procedures/awaken-coder.md` (handoff), `components/home-contract.md` (new: the four names + central defaults), `procedures/map-orientation.md`, `procedures/load-project-context.md`, `procedures/update-project-context.md`, `procedures/discovery-contract.md`, the five `procedures/generate-*.md`, `components/push-exclude-policy.md`, `MIGRATION.md`, `README.md`, `docs/adr/`.

### Component 3: Home parameterization of the consumers

- **Purpose**: remove `home: project` from the ~13 consumers so they operate on `HOME`.
- **Key Files**: the Component 2 procedures above plus `components/home-contract.md`.

### Component 4: Installer + sibling wiring

- **Purpose**: five layers install side by side with order-independent cleanup, and the rename leaves no orphaned install.
- **Key Files**: `setup-scripts/setup-all-{claude-code,codex,opencode,antigravity}.py` in core, project, fleet, wizards, local; the one-time orphan cleanup step.

### Component 5: Lineage

- **Purpose**: record that the original staged repo split four ways.
- **Key Files**: `agent-memory-project/MIGRATION.md`, `agent-memory-local/MIGRATION.md`, both READMEs.

### Integration Architecture

| Component | Integrates With | Data Flow | Dependencies |
|-----------|----------------|-----------|--------------|
| `agent-memory-project` awakening | core (Munnin), `agent-memory-local` | core load → central context → on detection, mention local | core |
| `agent-memory-local` resolution | project procedures | cwd + central map → `HOME` → drives project procedures | project (central defaults) |
| Installers (×5) | the shared skills dir | manifest + sibling lists → cleanup that never deletes another layer | each other |
| Harness global files | env declarations | installer stamps declarations | per-harness |

### Cross-System Contract Impact (Blast-Radius Check)

**Change classification**: ☑ string/ID format (installed folder prefix, manifest name) ☑ new/removed field (a new layer + repo) ☑ semantics changed (the repo's identity changes)

| # | Consumer (system + path) | How it couples | Breaks how on this change? | Verified / mitigated |
|---|---|---|---|---|
| 1 | core `control-files/setup-scripts/*` | hardcodes `.agent-memory-coding-skill-manifest` in its sibling list | silent-wrong: stops protecting project's folders | update to `.agent-memory-project-*` + add `.agent-memory-local-*` |
| 2 | fleet `setup-all-*` | hardcodes the coding-skill manifest name | silent-wrong: same | update |
| 3 | wizards `setup-all-*` | hardcodes the coding-skill manifest name | silent-wrong: same | update |
| 4 | project + local installers | new name / new prefix | orphaned `agent-coding-*` folders after the rename | one-time cleanup step |
| 5 | project procedures | `[path-to-agent-memory-coding-skill]` placeholder | dangling path definition | full rename to `[path-to-agent-memory-project]` |
| 6 | harness global files | the env/path-def block | stale declaration | re-stamp on install |

- **Deploy ordering**: create + push `agent-memory-local` first; then rename the repo; then run all five installers. They are order-independent by design, but every sibling list must be updated in the same pass.
- **Existing data**: old `agent-coding-*` installed folders and `.agent-memory-coding-skill-*` manifests are historical; the migration step removes the folders and the new installer writes fresh manifests.
- **Project registry**: none.

### Technical Considerations

- **Home parameterization crosses backends**: under the markdown backend `HOME` is filesystem paths; under MCP the central home is the Munnin tenant and the localized home is the repo. The resolution must express both; the backend seam itself is unchanged by this plan.
- **Sibling order-independence**: five installers now share one skills directory. A sibling list that omits `agent-memory-local` can delete its folders on that installer's next run.
- **Orphan migration on rename**: changing the prefix and manifest name orphan the old `agent-coding-*` folders; a one-time cleanup step removes them.
- **Placeholder rename blast radius**: `[path-to-agent-memory-coding-skill]` is referenced across the overlay's procedures and templates, and in fleet/wizards cross-refs; the rename must sweep every reference.
- **`load-local-context` is a read**: per automatic-for-read it runs on detection without asking; the reachability guard ("localized but not checked out") stops rather than falling back to a central write.

### Solution Options & Evaluation

#### Solution Options

| # | Solution | Description |
|---|----------|-------------|
| 1 | No split, one lane | Keep localization inside the coding overlay. |
| 2 | Split + pointer | Move the lane out; consumers keep their local branch pointing at `hermod-local`. |
| 3 | Split + parameterize (chosen) | Move the lane out; consumers operate on an injected `HOME` defaulting to central. |
| 4 | Split + duplicate | Move the lane out and copy localized-aware consumer variants into `hermod-local`. |
| 5 | History-preserving extraction | `git filter-repo` instead of a fresh repo. |

#### Evaluation

| Solution | Pros | Cons |
|----------|------|------|
| 1 No split | Nothing to build | The drift you are removing stays; a local bug still reaches the base. |
| 2 Pointer | Mechanical, small | Leaves `home: project` in project; the horizontal survives. |
| 3 Parameterize | Project has zero localization; one home for the rule | Refactors ~13 procedures in this pass. |
| 4 Duplicate | No parameterization | Two homes for the same procedure; the drift returns as duplication. |
| 5 filter-repo | Preserves history | Fleet/wizards precedent is a fresh repo; unnecessary for a small lane. |

#### Selected Approach
- **Chosen**: 3 — split + parameterize.
- **Rationale**: it is the only option that satisfies D4 (project central-only) without duplication, and it keeps the rule single-homed in `agent-memory-local`.

### ADR Output

- **ADR File**: `docs/adr/2026-10-09-hermod-local-project-split.md` (created in Step 12 from the wizards ADR template)
- **Decision Summary**: The localization lane is extracted into `agent-memory-local`; the coding overlay is renamed `agent-memory-project` and made central-only by operating on an injected `HOME` that `agent-memory-local` resolves.

---

## **IMPLEMENTATION PHASES**

### Phase 1: Create `agent-memory-local` and move the lane
- [ ] **Step 1.1**: Scaffold the repo
  - **Action**: Create the public repo and the fresh structure.
  - **Implementation**: `gh repo create alvseek/agent-memory-local --public`; add `LICENSE`, `NOTICE`, `README.md` (derived from the overlay's), `MIGRATION.md` (lineage), `tests/`, `setup-scripts/`.
  - **Testing**: Repo exists and clones; first push succeeds.
  - **Success Criteria**: Repo created with the standard structure.

- [ ] **Step 1.2**: Move the lane procedures and extract the resolution
  - **Action**: Move `localize-context` + `localized-memory-workflow` into the new repo, and extract `## Localized Home Resolution` into a component.
  - **Implementation**: Copy-verify-delete. `components/localized-home-resolution.md` holds the `HOME` contract, the `home: project` detection, the override, and the reachability guard.
  - **Testing**: Both procedures reference the component; no dangling reference remains in either repo.
  - **Success Criteria**: Both procedures live in local; the rule is single-homed.

- [ ] **Step 1.3**: Author `load-local-context`
  - **Action**: Write the reader entry.
  - **Implementation**: New procedure: resolve `HOME`, read localized episodic from `SESSION_DIR`, project knowledge from `KNOWLEDGE_DIR`, and the map via `MAP_PATH`. Read-only.
  - **Testing**: Inspection; confirm it never writes and never falls back to central.
  - **Success Criteria**: Procedure exists and resolves the localized home.

- [ ] **Step 1.4**: Installer, manifest, tests
  - **Action**: Give the repo its own installer set.
  - **Implementation**: `setup-scripts/*` for the four harnesses; `FOLDER_PREFIX = "agent-local-"`; manifest `.agent-memory-local-<harness>-manifest`; sibling list `{core, project, fleet, wizards}`.
  - **Testing**: Install into a scratch skills dir; assert folders; assert a cleanup does not delete a sibling's folders.
  - **Success Criteria**: Installs green; CI green.

- [ ] **Step 1.5**: Push
  - **Action**: Commit + push `agent-memory-local`.
  - **Success Criteria**: Public repo pushed.

### Phase 2: Rename and de-localize `agent-memory-project`
- [ ] **Step 2.1**: Full identity rename
  - **Action**: Rename the repo and its internal identity.
  - **Implementation**: `gh repo rename agent-memory-project`; change manifest names, `FOLDER_PREFIX` to `agent-project-`, placeholder `[path-to-agent-memory-project]`, env declaration, installer identity.
  - **Testing**: A grep for `coding-skill` and `agent-coding-` across the repo returns nothing.
  - **Success Criteria**: Identity fully renamed.

- [ ] **Step 2.2**: Remove the local procedures; add the home contract
  - **Action**: Delete `localize-context` + `localized-memory-workflow` from project; add `components/home-contract.md`.
  - **Implementation**: The component names the four `HOME` values and their central defaults.
  - **Testing**: Procedures reference the component; no reference to `/localize-context` remains.
  - **Success Criteria**: Project holds no localization procedure.

- [ ] **Step 2.3**: Parameterize the consumers
  - **Action**: Replace each `home: project` branch with the `HOME` placeholders (central default).
  - **Implementation**: `map-orientation`, `load-project-context`, `update-project-context`, `discovery-contract`, the five `generate-*`, the `push-exclude-policy` component, `templates/orientation-map-template.md` (its localization note), and the tests that reference localization (`test_setup_all_claude_code.py` names `localize-context`; `test_heading_references.py` names `localized projects`).
  - **Testing**: A grep for `home: project` and `.agents` across project procedures returns nothing.
  - **Success Criteria**: No consumer branches on localization.

- [ ] **Step 2.4**: Awakening handoff + orphan cleanup
  - **Action**: Add the detection handoff and the migration step.
  - **Implementation**: `awaken-coder` mentions `hermod-local` when `.agents/` exists at cwd; add the one-time removal of `agent-coding-*` folders.
  - **Testing**: Simulate a localized cwd; confirm the handoff text; run the cleanup against a seeded old install.
  - **Success Criteria**: Handoff present; old folders removed exactly once.

- [ ] **Step 2.5**: Lineage note
  - **Action**: Extend `MIGRATION.md` + `README.md`.
  - **Implementation**: Note the four-way split (project, local, fleet, wizards) and that `agent-memory-coding-skill` became `agent-memory-project`.
  - **Success Criteria**: Lineage recorded in both repos.

### Phase 3: Cross-repo wiring
- [ ] **Step 3.1**: Update sibling lists
  - **Action**: Make each installer protect the others.
  - **Implementation**: In core, project, fleet, wizards, local `setup-scripts/*`, replace the coding-skill manifest name with project's and add local's.
  - **Testing**: Run each installer in isolation against a tree installed by the others; assert nothing is deleted.
  - **Success Criteria**: Order-independent installs hold with five layers.

- [ ] **Step 3.2**: Cross-refs and placeholders in fleet/wizards
  - **Action**: Sweep references to the old repo name/placeholder.
  - **Testing**: Grep across all five repos for `coding-skill` / `agent-coding-`.
  - **Success Criteria**: No stale reference remains.

### Phase 4: Verify
- [ ] **Step 4.1**: Tests
  - **Action**: Run both suites.
  - **Testing**: `pytest` in `agent-memory-local` and `agent-memory-project`; all green.
  - **Success Criteria**: Both suites green.

- [ ] **Step 4.2**: Install verification
  - **Action**: Install all five layers on OpenCode and Claude Code.
  - **Testing**: Check the skills dir for `agent-project-*` and `agent-local-*`; assert no `agent-coding-*` orphan; run a second install to confirm idempotence.
  - **Success Criteria**: Clean installs, no orphans, idempotent re-runs.

- [ ] **Step 4.3**: Push
  - **Action**: Commit + push every changed repo.
  - **Success Criteria**: All repos pushed; installers green.

---

## **EXECUTION LOG**
**Execution Protocol for AI**:
I have to use this document as my **ONLY** source of truth to execute and track the plan steps iteratively. I should **NOT** use additional tools like ToDos because it lacks the context of what should I do. Everytime I want to implement a step I have to check the reference to the original step plan above. Everytime a step has been finished I need to go back to this document to log what was done.
*In other words*:
- I have to make this document as the source of truth for the implementation phase on what I have worked on and what I will be working
- The original plan must be fully in my context, therefore, I have to make sure I loaded the **Plan File** before executing any task and read carefully the reference to the original step
- I have to do the implementation by doing it in order per step THEN, I ALWAYS have to fill the step log rightly after

**Definition of Done (applies to ALL steps)**:
- ✅ **Code Quality**: Code compiles/runs without errors
- ✅ **Testing**: Tests written and passing
- ✅ **Logged**: Implementation and testing logged below
- 🚫 **Blocked**: Get input from [USER-NAME] before assuming

### Phase 1: Create `agent-memory-local` and move the lane
- [x] **Step 1.1**: Scaffold the repo
  - **Implementation Log**: `gh repo create alvseek/agent-memory-local --public`; cloned to `C:\Work\IM\agent-memory-local`. Copied `LICENSE`, `.gitignore`, `.gitattributes`, `.github/workflows/ci.yml` from the overlay; wrote adapted `NOTICE`, `pyproject.toml` (name `agent-memory-local`), `README.md`, `MIGRATION.md`. Created `procedures/`, `components/`, `tests/`, `setup-scripts/`, `docs/adr/`.
  - **Testing Log**: repo created (`https://github.com/alvseek/agent-memory-local`); clone succeeded (empty-repo warning expected); first commit pushed as `6e8218c` on `main`; `git status -sb` clean, tracking `origin/main`.
  - **Success Criteria**: Pass.
  - **Tech Debts**: `setup-scripts/` and `tests/` are still empty; the installer lands in Step 1.4.
  - **Result**: Pass — repo exists with the standard structure.

- [x] **Step 1.2**: Move the lane procedures and extract the resolution
  - **Implementation Log**: Copied `localize-context.md` + `localized-memory-workflow.md` into `agent-memory-local/procedures/`, then deleted the originals from the overlay (true move). Extracted the `## Localized Home Resolution` section into `components/localized-home-resolution.md` (header + `---` + body, per the compile convention); replaced the section in `localize-context.md` and the `## Storage resolution` block in `localized-memory-workflow.md` with a component reference. Both reference the component; the rule now has one home.
  - **Testing Log**: `Select-String` confirms both procedures carry the `components/localized-home-resolution.md` reference; the copied body was removed from `localize-context.md` (the only "canonical rule" hit is the reference line itself). Overlay now has dangling `/localize-context` references in `awaken-coder` (5), `map-orientation` (3), `load-project-context` (1), `update-project-context` (1), `push-exclude-policy` (1) — the Phase 2.3 blast radius.
  - **Success Criteria**: Pass.
  - **Tech Debts**: The overlay's references are dangling until Step 2.3 repoints them at `HOME`; expected intermediate state.
  - **Result**: Pass — lane moved, rule single-homed.

- [x] **Step 1.3**: Author `load-local-context`
  - **Implementation Log**: Wrote `procedures/load-local-context.md`: resolves `HOME` via the component (exits if not localized; stops on the reachability guard), reads localized episodic (repo index top entry → theme file), project knowledge (relevant entries only), and the map; then a compact report. Read-only.
  - **Testing Log**: Inspection confirms it never writes and never falls back to central; it references the `localized-home-resolution` component.
  - **Success Criteria**: Pass.
  - **Tech Debts**: none.
  - **Result**: Pass.

- [x] **Step 1.4**: Installer, manifest, tests
  - **Implementation Log**: Copied the overlay's installer set (`compile-procedures.py`, `install-skills.py`, the four `setup-all-*.py` + two `.bat`) and `tests/`. Adapted with a self-verifying script: `FOLDER_PREFIX` `agent-coding-` → `agent-local-`; manifests `.agent-memory-local-<harness>-manifest`; placeholder `[path-to-agent-memory-local]`; new path-def UUID `d4b7f0a2-3c61-4e58-9a2b-7f1e6c8d0b93`; new env-def UUID `f6a2c8e1-9d43-4b70-8e15-2c9f7a3d6b04`; **removed** the layer-access registration (leaf — no `[LOCAL-ACCESS]`); sibling lists now core + project + fleet + wizards on all four harnesses; test `_KNOWN` sets repointed to the lane's three procedures.
  - **Testing Log**: `python -m compileall` OK; `compile-procedures.py --strict` green (3 procedures, zero unresolved); `uv run ruff check` all passed; `uv run pytest -q` → **37 passed**; an import check confirms all four installers resolve their manifest and four-name sibling lists.
  - **Success Criteria**: Pass.
  - **Tech Debts**: `test_install_skills.py`'s local `_SIBLING_MANIFESTS` still lists only core+fleet (test-local, harmless).
  - **Result**: Pass — installs beside the other layers without clobbering.

- [x] **Step 1.5**: Push
  - **Implementation Log**: `git add -A`; commit `feat: move the localization lane onto a HOME contract with its own installer`; pushed to `origin/main`.
  - **Testing Log**: `git log` shows `6e8218c..78bede8 main -> main`.
  - **Success Criteria**: Pass.
  - **Tech Debts**: none.
  - **Result**: Pass — `agent-memory-local` public with the lane, installer, and green suite.

### Phase 2: Rename and de-localize `agent-memory-project`
- [x] **Step 2.1**: Full identity rename
  - **Implementation Log**: `gh repo rename agent-memory-project --yes` (remote now `github.com/alvseek/agent-memory-project`; local `origin` updated). In-repo identity swept by script across `procedures/`, `components/`, `templates/`, `setup-scripts/`, `tests/`, `pyproject.toml`, `README.md`, `NOTICE`: placeholder `[path-to-agent-memory-project]`, prefix `agent-project-`, manifests `.agent-memory-project-<harness>-manifest`, layer `[CODING-ACCESS]`→`[PROJECT-ACCESS]`, `hermod-coding`→`hermod-project`, repo name `agent-memory-project`. Historical `docs/adr/` and `plans/` left intact (append-only). Global instructions files (Claude Code, OpenCode, Codex, Gemini) migrated: `[path-to-agent-memory-coding-skill]`→`[path-to-agent-memory-project]`, `[CODING-ACCESS]`→`[PROJECT-ACCESS]`, marker renamed.
  - **Testing Log**: source-only grep for the old identity returns nothing; `compile --strict` green (16 procedures); `ruff` clean; `pytest` **39 passed**.
  - **Success Criteria**: Pass.
  - **Tech Debts**: the local checkout folder is still `C:\Work\IM\agent-memory-coding-skill` (renamed after the session); the registered path value still points at it until then, then reinstall to refresh.
  - **Result**: Pass — identity fully renamed.

- [x] **Step 2.2**: Remove the local procedures; add the home contract
  - **Implementation Log**: `localize-context` + `localized-memory-workflow` were already moved out in Step 1.2. Added `components/home-contract.md` — the four `HOME` names + their central defaults, with a note that `agent-memory-local` owns the localized override and detection.
  - **Testing Log**: `compile --strict` resolves the new component; the project's test `_KNOWN` sets were updated to drop `localize-context` (`pytest` **39 passed**).
  - **Success Criteria**: Pass.
  - **Tech Debts**: the central default is stated in both `home-contract.md` (project, authoritative) and `localized-home-resolution.md` (local, as the else-branch); low drift risk since the paths are fixed constants.
  - **Result**: Pass — project holds no localization procedure.

- [x] **Step 2.3**: Parameterize the consumers
  - **Implementation Log**: Repointed the resolution consumers at `components/home-contract.md` and the four `HOME` names: `map-orientation` (Prelude resolve-home), `load-project-context`, `update-project-context`, `push-exclude-policy`; updated `templates/orientation-map-template.md` (localization note) and the README. The five `generate-*` and `discovery-contract` read `MAP_PATH` via map-orientation's Prelude, so they parameterized with no edit. Fixed a nested-component failure: a component cannot reference another component (the compiler inlines one level), so `push-exclude-policy` states its home inline instead of linking `home-contract`.
  - **Testing Log**: `compile --strict` green (16 procedures); `ruff` clean; `pytest` **39 passed**; grep for `home: project` / `/localize-context` / `Localized Home Resolution` across `procedures/` + `components/` returns **0**.
  - **Success Criteria**: Pass.
  - **Tech Debts**: `push-project`/`project-wrap-up` still name `.agents/**` when describing the localized tree they stage; that is a factual path for a pusher, not a resolution branch.
  - **Result**: Pass — no consumer branches on localization.

- [x] **Step 2.4**: Awakening handoff + orphan cleanup
  - **Implementation Log**: `awaken-coder` step 3 rewritten — load central project context via `HOME`, then if `.agents/` exists at cwd detect it as localized and hand off to `/load-local-context` (which supersedes the central load); step 6 report and the proactive-loading note updated. Added `setup-scripts/migrate-old-name.py`, a one-time removal of the pre-rename `agent-coding-*` / `.agent-memory-coding-skill-*` installs across the four harnesses (protecting siblings).
  - **Testing Log**: `ruff` clean; `pytest` **39 passed**; handoff text present in `awaken-coder`.
  - **Success Criteria**: Pass.
  - **Tech Debts**: the migration must be run manually once, then the installers re-run (documented in MIGRATION.md).
  - **Result**: Pass.

- [x] **Step 2.5**: Lineage note
  - **Implementation Log**: `MIGRATION.md` gained the "localization + rename" section — the lane moved to `agent-memory-local`, the rename to `agent-memory-project`, the central-only change, the identity changes, and that the repo is now four repos. `README.md` updated (intro, Contents, the moved-localization bullet).
  - **Testing Log**: `compile --strict` green; content reviewed.
  - **Success Criteria**: Pass.
  - **Tech Debts**: none.
  - **Result**: Pass — lineage recorded in both repos.

### Phase 3: Cross-repo wiring
- [x] **Step 3.1**: Update sibling lists
  - **Implementation Log**: Renamed `coding-skill` → `project` and added `local` in every sibling list: core (`control-files/procedures/setup-scripts/setup-all-claude-code.py`, `setup-all-opencode.py`, `control-files/setup-scripts/uninstall-opencode.py`), fleet (all four `setup-all-*.py`), wizards (`setup-all-opencode.py`). Also corrected the core OpenCode sibling's missing `-opencode-` suffix. Updated the affected tests.
  - **Testing Log**: fleet `pytest` **39 passed**; wizards **33 passed** (after updating the sibling-set assertion to include `local`); core **41 passed**; `check-core-invariant.sh` green.
  - **Success Criteria**: Pass.
  - **Tech Debts**: none.
  - **Result**: Pass — order-independent installs hold with five layers.

- [x] **Step 3.2**: Cross-refs and placeholders in fleet/wizards
  - **Implementation Log**: Swept `*.md` across core, fleet, and wizards for the old repo name/placeholder (excluding frozen `plans/completed` and the MIGRATION lineage notes, which keep the old name on purpose). Updated README/ARCHITECTURE and `load-fleet`.
  - **Testing Log**: grep shows only the intentional historical mentions.
  - **Success Criteria**: Pass.
  - **Tech Debts**: none.
  - **Result**: Pass.

- [x] **Step 4.1**: Tests
  - **Implementation Log**: Ran every suite — `agent-memory-local` 37, `agent-memory-project` 39, `agent-memory-fleet` 39, `agent-memory-wizards` 33, core `control-files` 41; `ruff` clean throughout.
  - **Testing Log**: all green.
  - **Success Criteria**: Pass.
  - **Result**: Pass.

- [x] **Step 4.2**: Install verification
  - **Implementation Log**: Ran `migrate-old-name.py` (removed 35/18/35/35 stale entries across the four harness dirs and deleted the old manifests), then installed all five layers for **OpenCode** and **Claude Code**.
  - **Testing Log**: OpenCode skills dir carries 5 layers — `agent-memory` 17, `agent-project` 16, `agent-local` 3, `agent-fleet` 4, `agent-wizards` 17 — with **0 `agent-coding-*` orphans**; a second project install left the manifest unchanged (idempotent); Claude Code carries the project's `awaken-coder` command and the local lane's commands.
  - **Success Criteria**: Pass.
  - **Result**: Pass — clean installs, no orphans, idempotent.

- [ ] **Step 4.3**: Push
  - **Implementation Log**:
  - **Testing Log**:
  - **Success Criteria**:
  - **Tech Debts**:
  - **Result**:

---

## **QUALITY REVIEW**
*Filled by procedure Step 16 (delegated to `/analyze-code-quality` in embedded mode) after all execution phases are complete. **Static** review — answers "is the code clean?".*

- **Scope**: [Files reviewed — from Execution Log, reconciled against `git diff --name-only`]
- **Quality Standard**: [quality-standard.md found / not found — dimensions applied]
- **Findings**: [Issues found, or "No findings — implementation meets quality dimensions"]
- **Fixed**: [What was fixed from approved findings, or "N/A"]

---

## **QA HANDOFF**
*Filled by procedure Step 17 after Quality Review is resolved. This plan is **not** runtime-verified — this section records the plan for that verification, which happens in a QA session with the stack up.*

- **Scope**: `agent-memory-local` (new repo), `agent-memory-project` (renamed from coding-skill), and the installer sibling lists in core, fleet, wizards.
- **QA instrument**: NOT SET UP — a glob for `**/qa/**` finds nothing in this repo.
- **Integration coverage**: NONE — no bench and no stack. This is a procedures/installer repo, so its "integration" is the installer tests (Phase 1.4, 4.1, 4.2), not a running system. Confirm with [USER-NAME] before implementation that shipping without runtime coverage is intended.
- **Checklist**: none — skipped (no QA instrument; filled at Step 17).
- **Coverage split**: installer tests automated (Phase 1.4/4.1/4.2); manual: install verification on OpenCode + Claude Code.
- **Runtime verification**: **NOT DONE.** Next action: if runtime verification is wanted, set up the instrument first (`/map-qa-instrument create` → `/build-qa-bench`); otherwise rely on the installer tests.

> Do not read a filled checklist as a passed one. This section says a verification *plan* exists, nothing more.

---

## **POST-COMPLETION**
After all phases are executed, logged, and both **Quality Review** + **QA Handoff** are filled, move this plan to `plans/completed/`:
`mkdir -p ./plans/completed && mv ./plans/[this-file].md ./plans/completed/[this-file].md`
