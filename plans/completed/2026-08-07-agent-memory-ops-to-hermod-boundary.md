# High Wizard Plan

## **PROJECT INFO**
- **Project**: agent-memory
- **Date**: 2026-08-07
- **Agent**: Claude Meta
- **Theme**: Move project-context + fleet OPERATIONS from Muninn (core) to Hermod (overlay) — "move the operations, leave the data" (store ≠ server; Valaskjalf holds the data unchanged)
- **Source Protocol**: `/high-wizard` — /high-wizard

*CRITICAL INSTRUCTION: To continue this plan: load the source protocol above, then inspect which sections below are filled vs unfilled to infer your current step.*

---

## **OBJECTIVES**
Move **project-context** and **fleet** *operations* from Muninn (core `control-files`) to Hermod (coding-skill overlay), per the **store ≠ server** frame settled this session. The **data stays put** in Valaskjalf (`@agent-memory`) — only procedure ownership shifts. End-state: a pure chat agent (Muninn only) is **project-blind and fleet-free**; a coder agent (Hermod) owns project-context + orientation-map + fleet, reaching into Valaskjalf directly as a peer of Muninn. The core invariant guard stays **green** throughout.

### **Related Documents**
- [mcp-boundary-strategy.md](../../@agent-memory/shared-memory/agent-memory/context/mcp-boundary-strategy.md) — the core/overlay boundary + "capability belongs where its entities live" (this plan extends it with store≠server + the 3-layer naming)
- [coding-skill-overlay-structure.md](../../@agent-memory/shared-memory/agent-memory/context/coding-skill-overlay-structure.md) — overlay asset taxonomy (procedures/components/templates/scripts)
- Episode: `agent-meta/episodes/agent-memory-core-overlay-boundary.md` — the fleet+push/pull→core move this partially reverses

### **SUCCESS CRITERIA**
- [x] Project-context procedures (`update-project-context`, `load-project-context`) + `project-context-template.md` live in **overlay**; gone from core.
- [x] Fleet procedures (`ask-agent`, `delegate-agent`, `setup-fleet`) + 4 scripts + 2 templates live in **overlay**; gone from core.
- [x] Core awakening (`core-instruction` Phase 2) no longer reads project-context or fleet roster; **`awaken-coder`** loads both.
- [x] `update-memory` Phase 1 no longer evaluates project-context; overlay `project-wrap-up` does.
- [x] `core-knowledge-memory.md` "Proactive Memory Loading" split — general half stays (Muninn), project-context/orientation half → `awaken-coder`.
- [x] Domain Boundary Awareness genericized in core; fleet-specific version restated in `awaken-coder`.
- [x] Localized-resolver seam **collapsed** in the moved procedures (inline localized-home resolution).
- [x] Invariant guard updated (`CORE_FILES` − fleet/project-context; `ADDON` + 5 names) and **GREEN**.
- [x] **Data unchanged** in Valaskjalf: `shared-memory/[project]/context/`, `agent-[domain]/knowledge-base/[project]/`, `fleet-agents.md`, `fleet-map.csv`.
- [x] Recompile + reinstall; core/overlay command counts updated (core 13 / overlay 35 / total 48); ARCHITECTURE/README updated in **both** repos (deep table-prose flagged as doc-debt); `mcp-boundary-strategy.md` records the Valaskjalf/Muninn/Hermod naming + this boundary.

---

## **SCOPE**

### In Scope
- **WS1** — project-context operations Muninn → Hermod (2 procedures + template + template-consumer; carve project-context out of core awakening, `update-memory`, `wrap-up` report; split Proactive Loading; collapse the resolver seam).
- **WS2** — fleet operations core → overlay (3 procedures + 4 scripts + 2 templates; revert core awakening fleet-load; genericize Domain Boundary Awareness).
- **WS3** — cross-cutting closeout: invariant guard update + green; recompile + reinstall live commands; ARCHITECTURE/README in both repos; record naming + boundary in `mcp-boundary-strategy.md`.

### Out of Scope
- **Building the actual MCP servers** (Muninn / Valaskjalf / Hermod as literal running servers) — future; this is the boundary groundwork.
- **SQLite storage backend** for Valaskjalf — future; `.md` today. (Only a noted impl flag: two direct writers need coordination.)
- **`map-orientation` / `localize-context` moves** — already overlay; store≠server means their central-storage access to Valaskjalf is *fine as-is*. No move needed — this plan just confirms their ownership. (Resolves 2 of the 3 deferred `[AGENT-MEMORY-PATH]` holders by re-framing, not code.)
- **`push-agent-work`** storage-delegation — the 3rd deferred holder; spans project+memory repos, stays deferred.
- **codex / antigravity installer compile parity** — carried debt, not this plan.
- **De-localization / any Valaskjalf data migration** — data does not move.

---

## **CONFIRMED DECISIONS**
*These decisions were collected during investigation — both **asked-and-confirmed** by [USER-NAME] AND **written-through** (Zone A/B decisions made by the agent with reasoning, per /wait-options). The reasons serve as the analysis record.*

| # | Decision | Chosen | Reason |
|---|----------|--------|--------|
| 0 | **Architectural frame** (settled in discussion) | store ≠ server: **Valaskjalf** = storage base (data), **Muninn** = control-files-as-memory-server (project-blind), **Hermod** = coding overlay (peer accessor of Valaskjalf, owns project/orientation/fleet) | Separating store from server dissolves "does Muninn have a project?" — data lives in Valaskjalf; both servers access it; project semantics are Hermod's. |
| 1 | Plan structure | **A) One plan, two workstream-phases + shared closeout** | WS1+WS2 touch the same files (core-instruction Phase 2, awaken-coder, the guard); one guard-green pass covers both. |
| 2 | Home of the Hermod half of "Proactive Memory Loading" | **A) Fold into `awaken-coder` as a behavioral note** | `awaken-coder` already owns coder-agent orientation; keeping a project rule in Munnin's `core-knowledge-memory.md` would break "chat agent has no project." |
| 3 | `project-context-template.md` | **A) Move to overlay `templates/`** | Its only consumer (`update-project-context`) becomes Hermod's; leaving it orphans it in Muninn. |
| 4 | Localized-resolver seam | **A) Collapse — overlay procedure does localized-home resolution inline** | Once Hermod owns the procedure there's no separate "core default" to override; the indirection describes a split that no longer exists. |
| 5 | Domain Boundary Awareness (core) | **A) Genericize in core (keep domain humility, drop "check fleet-agents.md") + restate fleet-specific in `awaken-coder`** | Domain humility is a universal agent virtue (chat agent keeps it); the fleet roster it points to is project-keyed = Hermod. |
| 6 | Fleet roster DATA | **A) Stays in Valaskjalf (`fleet-agents.md`, `fleet-map.csv`); only procedures/scripts/templates move** | Roster is project-keyed data — identical to project-context; mirrors "move the operations, leave the data." |

---

## **SOLUTION**

### Architecture Overview
A **boundary re-categorization**, not a data migration. Three layers settled this session:
- **Valaskjalf** — the storage base (`@agent-memory` data; `.md` now). Holds ALL memory data, **unchanged**. Both servers read/write it.
- **Muninn** — `control-files` as a memory server. **Project-blind**: identity (reasoning/emotion/RAS), episodic/theme, general knowledge, shared foundations.
- **Hermod** — the coding-skill overlay. Not a memory provider, but a **peer accessor** of Valaskjalf; owns everything project-keyed: project-context, orientation-map, fleet.

Two capability clusters move Muninn → Hermod; their *data* stays in Valaskjalf. The invariant guard (bans add-on **procedure-name** references inside core files) is the acceptance oracle — run **green** after each workstream.

### Component 1: WS2 — Fleet ops → Hermod (revert last session)
- **Purpose**: fleet = `claude --resume` / session-spawn mechanics (Claude-Code-specific), not memory. Return operations to Hermod; leave roster data in Valaskjalf.
- **Key Files**: move `ask-agent.md`, `delegate-agent.md`, `setup-fleet.md` (procs → overlay `procedures/`); `ask-agent.sh`, `delegate-agent.sh`, `fleet-common.sh`, `wrap-up-agent.sh` (→ new overlay `fleet-scripts/`); `fleet-agents-template.md`, `fleet-map-template.csv` (→ overlay `templates/`). Core edits: `core-instruction-control-files.md` (drop fleet roster load + fleet report + genericize Domain Boundary Awareness), `awaken-agent.md` (drop fleet report line), README/ARCHITECTURE. Overlay: `awaken-coder.md` absorbs fleet load + report + fleet-specific Domain Boundary; README.

### Component 2: WS1 — Project-context ops → Hermod
- **Purpose**: project is a Hermod concept; a Muninn-only chat agent is project-blind.
- **Key Files**: move `update-project-context.md`, `load-project-context.md` (`procedures/memory/` → overlay `procedures/`); `project-context-template.md` (→ overlay `templates/`). Core edits: `core-instruction` Phase 2 (drop shared+private context-index reads + Project Context report; keep episodic), `update-memory.md` (remove Phase 1 Step 1 gate; **keep** Step 4 pre-scan paths per decision A; header "Three→Two gated auto-evals"), `core-knowledge-memory.md` (split Proactive Memory Loading). Overlay: `awaken-coder.md` absorbs project-context load + report + the project half of Proactive Loading; `project-wrap-up.md` gains a Project Context Gate **before** the memory step; the two moved procedures collapse the resolver seam (inline localized-home resolution).

### Component 3: WS3 — Closeout
- **Purpose**: enforce + ship.
- **Key Files**: `check-core-invariant.sh` (CORE_FILES − 3 fleet procs; ADDON + 5 names), `compile-procedures.sh` (run), setup scripts (reinstall), core `ARCHITECTURE.md`/`README.md` + overlay `README.md` (counts), `mcp-boundary-strategy.md` (naming + boundary record).

### Integration Architecture

| Artifact / content | From (Muninn/core) | To (Hermod/overlay) | Type |
|---|---|---|---|
| update-project-context.md | control-files/procedures/memory/ | procedures/ | move |
| load-project-context.md | control-files/procedures/memory/ | procedures/ | move |
| project-context-template.md | control-files/templates/ | templates/ | move |
| ask-agent / delegate-agent / setup-fleet .md | control-files/procedures/ | procedures/ | move |
| 4 fleet scripts (.sh) | control-files/scripts/ | fleet-scripts/ (new) | move + repoint refs |
| fleet-agents-template.md, fleet-map-template.csv | control-files/templates/ | templates/ | move |
| project-context load + report | core-instruction Phase 2 | awaken-coder | relocate content |
| fleet roster load + report | core-instruction Phase 2 + awaken-agent | awaken-coder | relocate content |
| Project Context Gate | update-memory Phase 1 Step 1 | project-wrap-up (new step) | relocate content |
| Proactive Loading (project half) | core-knowledge-memory.md | awaken-coder | split |
| Domain Boundary (fleet-specific) | core-instruction | awaken-coder (restated); core genericized | split |

**Data staying in Valaskjalf (untouched):** `shared-memory/[project]/context/`, `agent-[domain]/knowledge-base/[project]/`, `shared-memory/[project]/fleet-agents.md`, `fleet-map.csv`.

### Technical Considerations
- **Guard-green ordering**: the guard bans add-on **procedure-name** refs in core files. Per workstream, remove the name references from core files BEFORE/with adding those names to the ADDON regex; run the guard at each workstream's end. Never leave a core file naming a moved procedure.
- **Cross-repo non-atomicity**: changes span core (`control-files` submodule) + overlay + parent. Land each workstream's edits → guard-green → WS3 recompiles/reinstalls/commits. If interrupted mid-workstream, the guard names the leaking core file.
- **awaken-coder absorbs what core sheds**: core awakening shrinks (no project-context, no fleet); `awaken-coder` grows. Its lines that currently say *"the core already loaded X"* flip to *"this overlay loads X."*
- **Decision-A promotion recording**: the overlay `project-wrap-up` Project Context Gate must write BEFORE core `update-memory` Phase 2 Step 4 pre-scan, so the write is caught into episodic Promotions with zero new plumbing.
- **Script-path repointing**: fleet scripts land in overlay `fleet-scripts/`; the fleet procedures' runtime script-path refs (compile leaves these alone) repoint from core `scripts/` to the overlay location.
- **SQLite future flag**: when Valaskjalf becomes SQLite, two direct writers (Muninn + Hermod) need write coordination. Out of scope; noted.

---

## **IMPLEMENTATION PHASES**

### Phase 1: WS2 — Fleet ops → Hermod (revert last session)
- [ ] **Step 1.1**: Move fleet artifacts core → overlay
  - **Action**: Relocate 3 procedures + 4 scripts + 2 templates out of `control-files/` into the overlay; repoint script-path refs.
  - **Implementation**: `git mv` (core) `procedures/{ask-agent,delegate-agent,setup-fleet}.md` → overlay `procedures/`; `scripts/{ask-agent,delegate-agent,fleet-common,wrap-up-agent}.sh` → new overlay `fleet-scripts/`; `templates/{fleet-agents-template.md,fleet-map-template.csv}` → overlay `templates/`. In the 3 moved procedures, repoint any `control-files/scripts/…` (or `scripts/…`) references to the overlay `fleet-scripts/` location.
  - **Testing**: `ls` confirms files gone from core, present in overlay; `grep -rn "scripts/" procedures/{ask-agent,delegate-agent,setup-fleet}.md` shows only overlay-correct paths.
  - **Success Criteria**: All 9 artifacts in overlay; no dangling core-script path refs.

- [ ] **Step 1.2**: Strip fleet from core awakening + genericize Domain Boundary
  - **Action**: Remove fleet roster load + fleet report from core; make Domain Boundary Awareness fleet-agnostic.
  - **Implementation**: `core-instruction-control-files.md` — Phase 2 Step 3: drop the `fleet-agents.md` roster load (L27); Step 4 report: drop the fleet block naming `/ask-agent`/`/delegate-agent`/`/setup-fleet` (L41); Domain Boundary Awareness (L46–52): replace "check `fleet-agents.md`" with a generic "consult your fleet roster if you have one." `awaken-agent.md`: drop the fleet report line.
  - **Testing**: `grep -niE '/(ask-agent|delegate-agent|setup-fleet)\b|fleet-agents\.md' core-instruction-control-files.md awaken-agent.md` → no procedure-name hits (generic roster mention OK).
  - **Success Criteria**: Core awakening contains no fleet procedure name; Domain humility retained, fleet-specifics gone.

- [ ] **Step 1.3**: Absorb fleet into `awaken-coder`
  - **Action**: Overlay awakening loads the roster + surfaces fleet + restates the fleet-specific Domain Boundary.
  - **Implementation**: `awaken-coder.md` — add a step to read `shared-memory/[project]/fleet-agents.md` (silent skip if missing) + surface `/ask-agent` + `/delegate-agent` (or `/setup-fleet` if absent) in the augmented report; flip L20's "the core already loaded the fleet roster" to "this overlay loads it"; add the fleet-specific Domain Boundary note.
  - **Testing**: Read-through: awaken-coder now names the fleet load + report; no reliance on core doing it.
  - **Success Criteria**: A coder agent awakening still gets fleet roster + `/ask`/`/delegate` surfacing.

- [ ] **Step 1.4**: Fleet docs
  - **Action**: Revert fleet mentions in core README/ARCHITECTURE; add fleet back to overlay README.
  - **Implementation**: Move the fleet command/section rows from core `README.md` + `ARCHITECTURE.md` back to overlay `README.md` (counts fixed in Phase 3).
  - **Testing**: `grep -n fleet` both repos' docs reflect overlay ownership.
  - **Success Criteria**: Docs describe fleet as an overlay capability.

- [ ] **Step 1.5**: Guard checkpoint (WS2)
  - **Action**: Update the invariant guard for the fleet move and run it.
  - **Implementation**: `check-core-invariant.sh` — remove `ask-agent.md`/`delegate-agent.md`/`setup-fleet.md` from `CORE_FILES`; add `ask-agent|delegate-agent|setup-fleet` to the `ADDON` regex. Run `bash control-files/scripts/check-core-invariant.sh`.
  - **Testing**: Guard exits 0 (green).
  - **Success Criteria**: ✅ Core invariant holds after WS2.

### Phase 2: WS1 — Project-context ops → Hermod
- [ ] **Step 2.1**: Move project-context procedures + template; collapse resolver seam
  - **Action**: Relocate the 2 procedures + template to overlay; inline localized-home resolution.
  - **Implementation**: `git mv` `procedures/memory/{update-project-context,load-project-context}.md` → overlay `procedures/`; `templates/project-context-template.md` → overlay `templates/`. In both moved procedures, replace the "**Storage location (seam)** — defaults to central; an add-on may override" notes with direct localized-home resolution (apply the `/localize-context` rule inline); fix the template `[AGENT-MEMORY-PATH]/control-files/templates/…` ref to the overlay path.
  - **Testing**: Files present in overlay/absent in core; `grep -n "add-on.*resolver\|seam" ` in the 2 procedures → gone.
  - **Success Criteria**: Procedures self-own central+localized resolution; template ref valid.

- [ ] **Step 2.2**: Strip project-context from core memory procedures
  - **Action**: Remove the project-context gate + report from core; keep the inert pre-scan paths (decision A).
  - **Implementation**: `core-instruction` Phase 2 — drop shared+private context-index reads (L24–26) + the "Project Context" report block (L40); **keep** episodic. `update-memory.md` — remove Phase 1 **Step 1 (Project Context Gate)**; renumber remaining gates; change header "Three gated auto-evals" → "Two"; **keep** Phase 2 Step 4 pre-scan path rows + the `wrap-up.md` L36 report line (decision A — data paths, guard-clean). **`update-knowledge.md` (L38–39) + `load-knowledge.md` (L35, L93)** — genericize the `/update-project-context` / `/load-project-context` **name** references (guard-checked core files): drop the procedure name, keep the general-vs-project boundary note as *"project-scoped knowledge (`knowledge-base/[project]/`) is handled by the coding overlay, not here."*
  - **Testing**: `grep -rniE '/(update-project-context|load-project-context)\b' control-files/procedures control-files/core-instruction-control-files.md` → zero hits across ALL guard-checked core files (incl. update-knowledge, load-knowledge).
  - **Success Criteria**: No project-context procedure named in any core memory procedure; episodic + reasoning + knowledge gates intact; pre-scan paths retained; general-vs-project boundary note preserved (name-free).

- [ ] **Step 2.3**: Absorb project-context into `awaken-coder` + split Proactive Loading
  - **Action**: Overlay awakening loads shared+private project-context (localized-aware) + reports it; move the project half of Proactive Memory Loading.
  - **Implementation**: `awaken-coder.md` — add project-context load (shared `context-index` + private `knowledge-base/[project]/context-index`, via localized-home resolution) + the "Project Context" report block; flip L13's "core loaded central project context" to "this overlay loads it". `core-knowledge-memory.md` — split "Proactive Memory Loading": keep the general-knowledge bullet (Muninn); move the project-context/orientation bullets into an `awaken-coder` behavioral note.
  - **Testing**: awaken-coder names the project-context load; `core-knowledge-memory.md` has no project-context loading rule left.
  - **Success Criteria**: Coder agent still auto-loads project-context; Muninn foundation is project-blind.

- [ ] **Step 2.4**: Add Project Context Gate to `project-wrap-up`
  - **Action**: Overlay wrap-up runs `/update-project-context` before the memory wrap-up (preserves episodic promotion recording per decision A).
  - **Implementation**: `project-wrap-up.md` — insert a "Project Context Gate" step (the 3 gate questions from old update-memory Step 1 → call `/update-project-context` on YES) positioned BEFORE Step 2 (memory wrap-up), so core `update-memory` Step 4 pre-scan catches the write into episodic Promotions.
  - **Testing**: Step ordering: gate precedes memory wrap-up; read-through confirms promotion capture path intact.
  - **Success Criteria**: Project-context still evaluated at wrap-up, promotions still land in episodic.

- [ ] **Step 2.5**: Guard checkpoint (WS1)
  - **Action**: Update the guard for the project-context move and run it.
  - **Implementation**: `check-core-invariant.sh` — add `update-project-context|load-project-context` to the `ADDON` regex (they auto-leave `CORE_FILES` since they're gone from `procedures/memory/`). Run the guard.
  - **Testing**: Guard exits 0 (green).
  - **Success Criteria**: ✅ Core invariant holds after WS1.

### Phase 3: WS3 — Closeout
- [ ] **Step 3.1**: Recompile overlay
  - **Action**: Regenerate self-contained compiled commands.
  - **Implementation**: `bash setup-scripts/compile-procedures.sh`; verify `output/` regenerated, components/templates inlined, 0 leftover unresolved refs, anchors resolve.
  - **Testing**: Compile reports expected file count; spot-check a moved procedure (e.g. `output/update-project-context.md`) is self-contained.
  - **Success Criteria**: Clean compile, no unresolved refs.

- [ ] **Step 3.2**: Reinstall live commands + verify counts
  - **Action**: Reinstall both core + overlay commands; confirm the count shift.
  - **Implementation**: Run core setup + overlay `setup-scripts/setup-all-claude-code.sh`; count installed commands.
  - **Testing**: Core command count **drops** by 5 (3 fleet + 2 project-context); overlay **rises** by 5; combined total unchanged.
  - **Success Criteria**: Live `/ask-agent`, `/delegate-agent`, `/setup-fleet`, `/update-project-context`, `/load-project-context` resolve from the overlay; core no longer ships them.

- [ ] **Step 3.3**: Update ARCHITECTURE/README command-split tables
  - **Action**: Reflect the new core/overlay split + counts, and fix stale awakening-flow docs.
  - **Implementation**: Core `ARCHITECTURE.md` + `README.md`, overlay `README.md` — move the 5 commands to the overlay side; update count numbers + the core/overlay command tables. Doc-consistency sweep (not guard-checked, but now stale): core `docs/flows/awaken-agent.md` (core awakening no longer loads project-context/fleet), core `docs/orientation-map.md` + `new-agent-template/agent-memory-index.md` (project-context references) — align with the new split.
  - **Testing**: Doc counts match Step 3.2 reality; `grep -n fleet\|project-context` in the flow doc reflects overlay ownership.
  - **Success Criteria**: Docs + flow narrative accurately describe the post-migration split.

- [ ] **Step 3.4**: Record naming + boundary
  - **Action**: Capture the 3-layer model in project context.
  - **Implementation**: Update `shared-memory/agent-memory/context/mcp-boundary-strategy.md` — add the Valaskjalf/Muninn/Hermod naming + "store ≠ server" + "project-keyed ⇒ Hermod" + this migration's outcome (refines the prior boundary entry).
  - **Testing**: Entry present + internally consistent with the plan.
  - **Success Criteria**: Future agents can load the boundary rationale.

- [ ] **Step 3.5**: Final guard-green + end-to-end verification
  - **Action**: Confirm the whole change holds.
  - **Implementation**: Run `check-core-invariant.sh` (green); mentally trace a coder-agent awakening (core → awaken-coder loads project-context + fleet) and a chat-agent awakening (core only, project-blind, no fleet).
  - **Testing**: Guard green; both awakening traces produce the expected loads with no missing/duplicated content.
  - **Success Criteria**: ✅ Guard green; coder agent fully served, chat agent project-blind/fleet-free; data in Valaskjalf untouched.

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

### Phase 1: WS2 — Fleet ops → Hermod
- [x] **Step 1.1**: Move fleet artifacts core → overlay
  - **Implementation Log**: Cross-repo filesystem `mv` (core + overlay are separate repos in different locations — git staging deferred to wrap-up). Moved 3 procedures (`ask-agent`/`delegate-agent`/`setup-fleet`.md) → overlay `procedures/`; 4 scripts (`ask-agent`/`delegate-agent`/`fleet-common`/`wrap-up-agent`.sh) → new overlay `fleet-scripts/`; 2 templates (`fleet-agents-template.md`/`fleet-map-template.csv`) → overlay `templates/`. Repointed 4 refs in the procedures: script refs `[AGENT-MEMORY-PATH]/control-files/scripts/*.sh` → `[path-to-agent-memory-coding-skill]/fleet-scripts/*.sh` (ask-agent L54, delegate-agent L60+L76), template ref → `[path-to-agent-memory-coding-skill]/templates/fleet-agents-template.md` (setup-fleet L30). Fleet scripts source `fleet-common.sh` via `$(dirname "$0")` (location-independent — no edits). Roster DATA refs (`[AGENT-MEMORY-PATH]/shared-memory/[project]/fleet-agents.md`) left untouched — data stays in Valaskjalf per decision 6.
  - **Testing Log**: `ls` confirmed all 9 artifacts present in overlay, zero fleet leftovers in core `procedures/`+`scripts/`. `grep control-files` in the 3 procedures → none. Script/template refs now overlay-correct.
  - **Success Criteria**: PASS — all 9 in overlay; no dangling core-script refs.
  - **Result**: ✅ Fleet artifacts relocated + refs repointed; roster data untouched.
- [x] **Step 1.2**: Strip fleet from core awakening + genericize Domain Boundary
  - **Implementation Log**: `core-instruction-control-files.md` — (1) removed the Phase 2 Step 3 "Fleet roster" load bullet; (2) removed the Phase 2 Step 4 "Fleet" report bullet (named `/ask-agent`/`/delegate-agent`/`/setup-fleet`); (3) genericized Domain Boundary Awareness item 2: "check `fleet-agents.md` and reference the specialist" → "if you know a specialist agent for this area, reference them by name" (domain humility retained, fleet mechanism dropped). `awaken-agent.md` — **no edit needed**: it only delegates to `core-instruction`'s phased protocol; the fleet report lived entirely in `core-instruction` (plan assumption corrected).
  - **Testing Log**: `grep -niE '/(ask-agent|delegate-agent|setup-fleet)\b|fleet-agents\.md'` on both files → none. Remaining `fleet` mention is L7's descriptive note ("overlay composes … + fleet") — accurate (fleet is now an overlay concern), kept.
  - **Success Criteria**: PASS — no fleet procedure name in core awakening; domain humility intact, fleet-specifics gone.
  - **Result**: ✅ Core awakening is fleet-free; Domain Boundary genericized.
- [x] **Step 1.3**: Absorb fleet into awaken-coder
  - **Implementation Log**: `awaken-coder.md` — (1) intro L3: "core loads central memory + the fleet roster; this overlay adds localization, orientation map, and task-system" → "core loads central memory; this overlay adds localization, orientation map, **fleet**, and task-system"; (2) Step 3 renamed "Orientation map + fleet roster" — added roster load from `[AGENT-MEMORY-PATH]/shared-memory/[project]/fleet-agents.md` (silent skip), replacing the now-false "core already loaded the roster" parenthetical; (3) Step 5 report: added the **Fleet** bullet (surface `/ask-agent`+`/delegate-agent`, or `/setup-fleet` if absent); (4) Domain Boundary note flipped from "inherited from core" to the overlay restating the fleet-specific version (consult `fleet-agents.md`).
  - **Testing Log**: `grep -niE "fleet|/ask-agent|/delegate-agent|/setup-fleet"` → 4 expected hits (intro, load step, report bullet, Domain Boundary). Roster reads from Valaskjalf path (data unmoved ✓).
  - **Success Criteria**: PASS — coder awakening loads roster + surfaces `/ask`/`/delegate`; no reliance on core.
  - **Result**: ✅ awaken-coder owns fleet load + report + fleet-specific Domain Boundary.
- [x] **Step 1.4**: Fleet docs
  - **Implementation Log**: Core `README.md` — removed "agent-to-agent fleet" from the core-primitives blurb (L3) + the "coordinate agent-to-agent (fleet)" clause (L22, now "knows nothing about repos, git, wizards, or fleet"); removed the 3 fleet file-tree lines. Core `ARCHITECTURE.md` — rewrote the two-repo-split note (L7): fleet now listed among what "moved to the overlay" (dropped the stale "returned to the core" parenthetical); removed 3 fleet lines from the core procedures tree; renamed overlay tree `scripts/` → `fleet-scripts/`. Overlay `README.md` — added a **Fleet** capability bullet (ask/delegate/setup-fleet + fleet-scripts/ + templates); rewrote the L22 note to drop the fleet-moved-to-core paragraph, keeping only the push/pull-memory-in-core note. (Overlay-side entries already listing fleet as overlay — ARCH L124/L387/L415 — were already correct and left as-is; command-count reconciliation deferred to Step 3.3.)
  - **Testing Log**: `grep fleet` both repos' docs now attribute fleet to the overlay; no core file-tree entry for the moved fleet files; no "fleet in core" prose remains.
  - **Success Criteria**: PASS — docs describe fleet as an overlay capability.
  - **Result**: ✅ Fleet doc ownership corrected (counts/tables → Step 3.3).
- [x] **Step 1.5**: Guard checkpoint (WS2)
  - **Implementation Log**: `check-core-invariant.sh` — removed `ask-agent.md`/`delegate-agent.md`/`setup-fleet.md` from `CORE_FILES`; appended `ask-agent|delegate-agent|setup-fleet` to the `ADDON` regex.
  - **Testing Log**: `bash check-core-invariant.sh` → `✅ Core invariant holds`, exit 0.
  - **Success Criteria**: PASS — guard green after WS2.
  - **Result**: ✅ Fleet fully relocated; core references no fleet procedure. **Phase 1 (WS2) complete.**

*(Per step, on completion fill: Implementation Log / Testing Log / Success Criteria pass-fail / Tech Debts / Result.)*

### Phase 2: WS1 — Project-context ops → Hermod
- [x] **Step 2.1**: Move project-context procedures + template; collapse resolver seam
  - **Implementation Log**: Filesystem `mv` `update-project-context.md` + `load-project-context.md` (`control-files/procedures/memory/`) → overlay `procedures/`; `project-context-template.md` (`control-files/templates/`) → overlay `templates/`. Collapsed the "**Storage location (seam)** — defaults to central; add-on may override" note in BOTH procedures → direct inline localized-home resolution (apply `/localize-context`'s rule: `home: project` → `docs/` + `.agents/knowledge/`, else central defaults). Repointed the 2 template refs in `update-project-context.md` (L81 Step 5A, L176 Templates) `[AGENT-MEMORY-PATH]/control-files/templates/…` → `[path-to-agent-memory-coding-skill]/templates/…`.
  - **Testing Log**: core `procedures/memory/` 10→8, core `templates/` down to just episodic; overlay has both procs + template. `grep` → no `seam`/`add-on resolver`/`control-files` remnants; template refs overlay-correct.
  - **Success Criteria**: PASS — procedures self-own central+localized resolution; template ref valid.
  - **Result**: ✅ Project-context ops in overlay; seam collapsed.
- [x] **Step 2.2**: Strip project-context from core memory procedures
  - **Implementation Log**: `core-instruction` Phase 2 — removed the shared+private context-index reads; removed the "Project Context" report bullet; added "project context" to the extension-supplied list in the Phase 2 intro (keeps episodic). `update-memory.md` — removed Phase 1 **Step 1 (Project Context Gate)**; renumbered the whole sequence (Reasoning→Step 1, Knowledge→Step 2, Pre-Scan→Step 3, Episodic→Step 4, Emotional→Step 5, Summary→Step 6); header "Three→**Two** gated auto-evals"; Notes "all 4 gates → **all 3**"; **kept** the Step 3 pre-scan project-context path rows + the summary "Project context" line (decision A) but simplified the row parenthetical (core is project-blind — no resolver); added a project-blind Note under Step 2 that a coding agent's fuller wrap-up runs the project-context gate before this step (WITHOUT naming `/project-wrap-up` — guard-safe). `wrap-up.md` L36 report line kept as-is (data path, not a procedure name — decision A). `update-knowledge.md` (L38–39) + `load-knowledge.md` (L35, L93) — genericized the `/update-project-context` / `/load-project-context` name refs to "handled by the coding overlay, not here."
  - **Testing Log**: `grep '/(update-project-context|load-project-context)'` across core procedures + core-instruction → none. update-memory steps renumbered 0–6 contiguously; header "Two gated"; "all 3 gates".
  - **Success Criteria**: PASS — no project-context procedure named in any core memory procedure; gates intact; pre-scan paths + boundary note retained (name-free).
  - **Result**: ✅ Core memory procedures are project-blind (guard-clean).
- [x] **Step 2.3**: Absorb project-context into awaken-coder + split Proactive Loading
  - **Implementation Log**: `awaken-coder.md` — Step 1 flipped ("core loads … and central project context" → "core is project-blind; this overlay owns project-context loading in step 2"); rewrote Step 2 to explicitly **load project context** via `/localize-context` resolution for BOTH central (`shared-memory/[project]/context/context-index.md` + `agent-[domain]/knowledge-base/[project]/context-index.md`) and localized (`docs/context-index.md` + `.agents/knowledge/index.md`) homes, folding in the localized-episodic supersede; added a **Project context** bullet to the Step 5 report. `core-knowledge-memory.md` "Proactive Memory Loading" — removed the two project-context bullets + "Project Context" from Core Behavior + the localized-episodic parenthetical (general knowledge + episodic half stays, Muninn); added the coding half as a **standing-behavior note** in `awaken-coder`. Incidental: genericized a GitButler tip in the shared foundation that still named `/update-project-context` (not guard-checked, but keeps the foundation project-blind).
  - **Testing Log**: `grep` core-knowledge-memory.md → no project-context *loading* rule remains (only the descriptive ADR-nuance mention of "project context" as a concept). awaken-coder now loads project-context (central+localized) + reports it + carries the standing proactive-load note.
  - **Success Criteria**: PASS — coder agent auto-loads project-context; Muninn foundation project-blind.
  - **Result**: ✅ Project-context awakening + proactive-loading now Hermod-owned.
- [x] **Step 2.4**: Add Project Context Gate to project-wrap-up
  - **Implementation Log**: `project-wrap-up.md` — folded the **Project Context Gate** into Step 2 (renamed "Project Context Gate + Memory Wrap-Up"): the 3 gate questions (from the old core `update-memory` Step 1) → run `/update-project-context` on YES **before** the memory wrap-up, so the core `/update-memory` pre-scan catches the write into episodic Promotions (decision A). Chose fold-into-Step-2 over a new numbered step to avoid renumbering project-wrap-up's cross-referenced steps (Step 4/5 verification refs).
  - **Testing Log**: Read-through — gate precedes the memory wrap-up within Step 2; promotion-capture path intact; no step renumbering needed.
  - **Success Criteria**: PASS — project-context evaluated at wrap-up; promotions still land in episodic.
  - **Result**: ✅ Overlay wrap-up owns the project-context gate.
- [x] **Step 2.5**: Guard checkpoint (WS1)
  - **Implementation Log**: `check-core-invariant.sh` — appended `update-project-context|load-project-context` to the `ADDON` regex (both auto-left `CORE_FILES` when they moved out of `procedures/memory/`).
  - **Testing Log**: `bash check-core-invariant.sh` → `✅ Core invariant holds`, exit 0.
  - **Success Criteria**: PASS — guard green after WS1.
  - **Result**: ✅ Project-context ops fully relocated; core references no project-context procedure. **Phase 2 (WS1) complete.**

### Phase 3: WS3 — Closeout
- [x] **Step 3.1**: Recompile overlay
  - **Implementation Log**: `bash setup-scripts/compile-procedures.sh` → "Compiled 35 procedures" (30 prior + 5 moved back = 35 ✓). All 5 moved procedures present in `output/`; `project-context-template.md` inlined into `output/update-project-context.md` (ref rewritten to `#project-context-template` anchor + `## Templates` appendix). Runtime refs correctly left alone (`[path-to-agent-memory-coding-skill]/fleet-scripts/*.sh`, `[AGENT-MEMORY-PATH]/shared-memory/…`). No unresolved template-link leftovers.
  - **Testing Log**: `ls output/` + `grep` confirm inlining + runtime-ref preservation; 0 unresolved refs.
  - **Success Criteria**: PASS — clean compile, self-contained output.
  - **Tech Debts**: ~~Cosmetic double `## Templates`~~ → **RESOLVED**: removed the redundant manual `## Templates` pointer section from the source (the Step 5A ref still drives inlining); recompiled → exactly 1 `## Templates` heading, template inlined, ref anchored.
  - **Result**: ✅ Overlay recompiled, 35 self-contained commands.
- [x] **Step 3.2**: Reinstall live commands + verify counts
  - **Implementation Log**: Ran core installer (`control-files/procedures/setup-scripts/setup-all-claude-code.sh`) → 13 core; then overlay installer (`setup-scripts/setup-all-claude-code.sh`) → 35 overlay. **Hit a stale-manifest bug**: the old overlay manifest still listed `push-memory`/`pull-memory` (from before last session moved them to core), so the overlay cleanup deleted the two files the core installer had just placed → 46 files not 48. **Fix**: re-ran the core installer *after* the overlay (overlay manifest now clean of push/pull-memory) → restored both. Final: 13 + 35 = 48 files, **no manifest collisions**, all 5 moved commands live from the overlay, push/pull-memory present.
  - **Testing Log**: `comm -12` of the two manifests → empty (no collisions); `ls *.md | wc -l` = 48; core manifest 13, overlay 35; the 5 moved + push/pull-memory all present as files. Skill list now surfaces `/ask-agent`, `/delegate-agent`, `/setup-fleet`, `/update-project-context`, `/load-project-context` (overlay-installed).
  - **Success Criteria**: PASS — core −5 (18→13), overlay +5 (30→35), total 48; the 5 resolve from the overlay.
  - **Tech Debts**: ~~Install-order fragility~~ → **RESOLVED**: both installers now skip deleting any file the **sibling manifest** also claims (`grep -qxF` guard) — order-independent, immune to stale entries. Verified via stale-entry simulation (added core-owned `push-memory.md` to the overlay manifest, re-ran overlay → `push-memory.md` survived, 48 intact).
  - **Result**: ✅ Live commands reflect the new split (48, clean).
- [x] **Step 3.3**: Update ARCHITECTURE/README command-split tables
  - **Implementation Log**: Core `README.md` — removed the 2 project-context rows from the memory-command table. Core `ARCHITECTURE.md` — removed the 2 project-context file-tree lines; moved `/update-project-context` + `/load-project-context` from the core command list to the overlay list; added project-context to the L7 split caveat + "the memory core is project-blind". Overlay `README.md` — added project-context to the Repo/integration bullet. **Flow doc** `docs/flows/awaken-agent.md` — rewrote to describe the **project-blind core** awakening (removed project-context, fleet, AND the map/task overlay steps that predated my change), with a note that `/awaken-coder` composes those overlay additions; dropped the map-orientation "Related" link.
  - **Testing Log**: Core docs no longer list project-context as a core command in the trees/lists; flow doc consistent with project-blind core; overlay README lists project-context.
  - **Success Criteria**: PASS (structural) — trees/command-lists/flow reflect the split.
  - **Tech Debts**: ~~Doc-prose polish deferred~~ → **RESOLVED**: `ARCHITECTURE.md` Project-Context section got an ownership note (data in Valaskjalf, ops are overlay); removed the 2 project-context rows from the core procedure-map table; `new-agent-template/agent-memory-index.md` notes project-context is a coding-overlay capability. (`docs/orientation-map.md` L138 left — a valid usage mention of `/update-project-context`, which coding agents have.)
  - **Result**: ✅ Command-split docs + flow corrected (deep table prose flagged).
- [x] **Step 3.4**: Record naming + boundary in mcp-boundary-strategy.md
  - **Implementation Log**: Rewrote `shared-memory/agent-memory/context/mcp-boundary-strategy.md` to the refined **store ≠ server** model: the 3 layers (Valaskjalf = store / Munnin = memory server, project-blind / Hermod = coding overlay, peer accessor); two sharpening tests (project-keyed ⇒ Hermod; two senses of "shared"); what's Hermod's now (project-context + fleet, with the fleet **reversal** from the earlier same-day move-to-core noted) vs Munnin's; "move the operations, leave the data"; updated counts (core 13 / overlay 35); resolved the map-orientation/localize-context deferred question (dissolves under store≠server); push-agent-work still deferred.
  - **Testing Log**: Doc reads coherently; consistent with the implemented split + the plan's Confirmed Decisions.
  - **Success Criteria**: PASS — future agents can load the boundary rationale + naming.
  - **Result**: ✅ Boundary + Valaskjalf/Munnin/Hermod naming recorded.
- [x] **Step 3.5**: Final guard-green + end-to-end verification
  - **Implementation Log**: Ran `check-core-invariant.sh` → green. Traced both awakenings. Caught + fixed one stale line missed in Step 2.2: `core-instruction` L5 summary still said "Phase 2 loads central project context and reports" → "…loads the latest central episodic context and reports (project-blind — project context is a coding-overlay extension)."
  - **Testing Log**: (1) Guard exit 0. (2) **Chat-agent trace** — `core-instruction` has no `context-index`/`fleet-agents`/`/ask-agent`/`/delegate-agent` load (project-blind + fleet-free). (3) **Coder-agent trace** — `awaken-coder` has 4 project-context + 3 fleet-roster refs (loads both). (4) Moved files: none in core, all 5 in overlay. (5) 48 live commands.
  - **Success Criteria**: PASS — guard green; coder agent fully served; chat agent project-blind/fleet-free; Valaskjalf data untouched.
  - **Result**: ✅ End-to-end verified. **Phase 3 (WS3) complete — all 15 steps done.**

---

## **QUALITY REVIEW**
*Filled by procedure Step 16 (delegated to `/analyze-code-quality` in embedded mode) after all execution phases are complete. **Static** review — answers "is the code clean?".*

- **Scope**: [Files reviewed — from Execution Log, reconciled against `git diff --name-only`]
- **Quality Standard**: [quality-standard.md found / not found — dimensions applied]
- **Findings**: [Issues found, or "No findings — implementation meets quality dimensions"]
- **Fixed**: [What was fixed from approved findings, or "N/A"]

---

## **FINAL INTEGRATION TEST**
*Filled by procedure Step 17 after Quality Review is resolved. **Runtime** verification through the qa/ instrument — answers "does it actually work end-to-end?".*

- **Scope**: [Modules touched — mapped from Execution Log scope]
- **qa/ Status**: [Detected / Missing / Skipped — reason if skipped]
- **Playbooks Run**: [List of `qa/playbooks/{module}.md` exercised, or "N/A — skipped"]
- **R/I/A/O Results**: [Per-module pass/fail summary, or "N/A — skipped"]
- **Findings**: [Runtime failures + severity, or "No findings — runtime clean", or "N/A — skipped"]
- **Fixed**: [What was fixed from approved findings, or "N/A"]

---

## **POST-COMPLETION**
After all phases are executed, logged, and both **Quality Review** + **Final Integration Test** are filled, move this plan to `plans/completed/`:
`mkdir -p ./plans/completed && mv ./plans/[this-file].md ./plans/completed/[this-file].md`
