# Localize Context

Graduate a **consenting** project's fleet-authored memory OUT of the central `@agent-memory` store and INTO the project's own repository — **structural context → `docs/`** (human-facing, always) and, **opt-in, work-product memory → `.agents/`** (agent-facing). One-time, forward-only. See [ADR-005](//@agent-memory/docs/adr/2026-07-06-project-local-memory-externalization.md) + [ADR-010](//@agent-memory/docs/adr/2026-07-13-work-product-memory-localization.md).

**The load-bearing rule — identity stays, work-product travels:**
- **Work-product travels** — *code-describing* structural context → `docs/`; *episodic + project-scoped knowledge* → `.agents/`.
- **Identity stays, always** — reasoning, emotion, RAS, **general** (cross-project) knowledge, and business/strategy/relationship memory **never leave the fleet store**. Leaking those into a (client) repo is the failure this procedure exists to prevent.

---

## Arguments

`$ARGUMENTS`

- `/localize-context` — Localize the **current** project (detect from cwd).
- `/localize-context [project-name]` — Target the named project instead of cwd detection.
- `/localize-context --status` — Report whether the current project is localized (read-only). No move.

---

## What Localizes (safety boundary)

**Human lane → `docs/`** (always — ADR-004/005):
- Orientation map (`orientation-map.md`)
- Structural project-context: architecture overviews, module docs, conventions, flow descriptions, ADR indexes

**Agent lane → `.agents/`** (opt-in — ADR-010):
- Episodic memory (`agent-[domain]/episodes/`, project-matched) → `.agents/session/`
- Project-scoped knowledge (`agent-[domain]/knowledge-base/[project]/`) → `.agents/knowledge/`

**Stays central (fleet-private), always:**
- Emotional / relationship memory
- Reasoning memory + RAS triggers
- **General** (cross-project) knowledge — `knowledge-base/` outside a `[project]/` subfolder (research, core-domain, cross-cutting patterns)
- Business / strategy / commercialization context
- Any file holding secrets, OAuth, credentials, or internal fleet design

**Ambiguous → ASK.** Never auto-move a file whose classification isn't obvious.

---

## Step 1: Identify project + guard

1. **Identify project** — from `[project-name]` arg, else infer from cwd (same detection as `/map-orientation` Prelude).
2. **Resolve central paths**:
   - Central map: `//@agent-memory/shared-memory/[PROJECT-NAME]/context/orientation-map.md`
   - Central context dir: `//@agent-memory/shared-memory/[PROJECT-NAME]/context/`
   - Project root: the project's working directory on disk (cwd for the active project).
3. **Guards**:
   - Central map missing → STOP + report: *"No orientation map for [PROJECT] yet — run `/map-orientation create` first, then localize."*
   - Central map already has `home: project` → the **`docs/` structural lane is already localized**. Do NOT blanket-exit — branch on the **agent lane** (Step 6b, ADR-010):
     - `<project-root>/.agents/session/` **exists** → both lanes already done → *"[PROJECT] is already fully localized (`docs/` + `.agents/`)."* Exit.
     - `<project-root>/.agents/session/` **absent** → the docs lane is done but the agent lane was never graduated (e.g. the project was localized before ADR-010 added it). **Skip Steps 2–6 (docs lane already done) and jump straight to [Step 6b](#step-6b-graduate-work-product-memory-opt-in--agent-lane)** to offer graduating episodic + project-scoped knowledge. Report first: *"[PROJECT]'s `docs/` lane is already localized; picking up the newer agent lane (Step 6b)."*

> `--status` mode stops here: report localized (map `home: project`) or central-only; if localized, also note whether the agent lane is present (`.agents/` exists), then exit.

## Step 2: Consent gate + `AGENTS.md`

1. **Confirm consent** — one explicit confirmation from [USER-NAME]: *"Localize [PROJECT] into its own repo? This moves the map + structural context into `<project-root>/docs/` and leaves a central stub. Confirm the project is agreed to host AI artifacts."* Wait.
2. **Root `AGENTS.md`**:
   - Present at `<project-root>/AGENTS.md` → will **append** the pointer section (skip if already present — idempotent).
   - Missing → create a minimal `AGENTS.md` (house-rules stub + the pointer section). Confirm creation.
3. **Append the prose pointer** (never a boolean flag — the standard is prose sections):

   ```markdown
   ## Agent Orientation
   This repo maintains a structured orientation map at `docs/orientation-map.md`.
   Load it before starting work for architecture and navigation context.
   ```

## Step 3: Classify central context files

1. List `*.md` in the central context dir (exclude `orientation-map.md` and `context-index.md` — handled separately).
2. Classify each per [What Localizes](#what-localizes-safety-boundary): **localize** (code-describing) vs **stay** (fleet-private).
3. **Present the full classification for confirmation BEFORE any move** — this is the safety pause:

   ```
   Localization plan for [PROJECT]:
     MOVE → docs/:   [file] — [why structural]
     STAY central (private):    [file] — [why fleet-private]
     AMBIGUOUS (confirm):       [file] — [both readings]
   ```
   Wait for [USER-NAME] to confirm / reclassify. Do NOT move anything until confirmed.

## Step 4: Create `docs/` layout

- `mkdir -p <project-root>/docs`

## Step 5: Move + rebase the orientation map

1. **Copy** central map → `<project-root>/docs/orientation-map.md`.
2. **Frontmatter**: keep `project` / `description` / `created` / `last_full_scan`; add `source_of_truth: project`.
3. **Rebase paths** (two different bases — don't conflate):
   - **Doc `path` references** stay **project-root-relative** — the agent resolves them from the repo root (cwd), exactly as the central map already did (a central map's `README.md` entry never meant `shared-memory/.../context/README.md`). → unchanged.
   - **`child_map` sub-links** are relative to the **map file's folder**. The map now lives at `docs/`, so rewrite the old central-context form (`../../../[sub]/orientation-map.md`) to `docs/`-relative: `../[sub]/orientation-map.md` (one `..` climbs from `docs/` to the repo root, then descends into the sub-project). This keeps `/map-orientation` Load Mode L2 (which follows `child_map` relative to the parent map's location) working unchanged.
4. **Delete** the central map only after the copy is verified (it's replaced by the stub in Step 7).

## Step 6: Move classified context + indexes

1. For each **localize**-classified file: copy → `<project-root>/docs/[file]`, then delete the central original.
2. **In-project index**: create `<project-root>/docs/context-index.md` (header `# [PROJECT] Project Context`) with the moved entries.
3. **Central index**: remove moved entries from the central `context-index.md`. Files classified **stay** remain listed centrally and physically in place.

> **Atomicity**: this move is not atomic across the two repos. If interrupted, report partial state (which files copied vs deleted) and finish manually — same discipline as `/update-project-context` Move-to-Shared.

## Step 6b: Graduate Work-Product Memory (opt-in — agent lane)

The `docs/` structural lane (Steps 4–6) is done. Now offer the **agent lane** — episodic + project-scoped knowledge → `.agents/` (see [ADR-010](//@agent-memory/docs/adr/2026-07-13-work-product-memory-localization.md)). This is a **separate** consent: welcoming AI into the repo (`AGENTS.md`) is not the same as publishing the fleet's session history.

1. **Opt-in gate** — ask [USER-NAME]:
   > *"Also graduate this project's **work-product memory** into `.agents/`? This moves episodic session logs + project-scoped knowledge (gathered across all agents) into `<project-root>/.agents/`, leaving a bounded per-project pointer centrally (episodic index becomes repo-authoritative — ADR-011). Identity (reasoning/emotion/RAS), general knowledge, and business/strategy stay fleet-private. Confirm, or skip to keep them central."*

   If **skipped** → jump to Step 7 (the project is still localized for the `docs/` lane; the agent lane simply isn't graduated).

2. **Gather across agents** — a project's memory is smeared over many `agent-*/` folders. Scan every `//@agent-memory/agent-*/`:
   - **Episodic**: files in `agent-*/episodes/` whose filename or index summary matches the project (filename prefix `[project]-` OR the `agent-memory-index.md` project tag). Skip `episodes/archive/`.
   - **Knowledge**: everything under `agent-*/knowledge-base/[project]/` (the **project-scoped subfolder only** — NEVER general `knowledge-base/*` files).

3. **Present the gather manifest — WAIT.** Before moving anything:
   ```
   Work-product gather for [PROJECT]:
     EPISODIC → .agents/session/
       [agent] episodes/[file]            → session/[theme].md        (new)
       [agentA]+[agentB] .../[theme]      → session/[theme].md        (MERGE: stacked sub-episodes)
     KNOWLEDGE → .agents/knowledge/
       [agent] knowledge-base/[proj]/[f]  → knowledge/[f]             (new)
       [agentA]+[agentB] .../[f]          → knowledge/[f]             (MERGE: concatenated under ## [agent])
   Confirm / reclassify. Nothing moves until confirmed.
   ```
   Wait for [USER-NAME].

4. **Create layout**: `mkdir -p <project-root>/.agents/session <project-root>/.agents/knowledge`.

5. **Move (copy-verify-delete)** — per ADR-010 merge rules; copy first, verify, THEN delete centrals (minimizes the loss window — not atomic across two repos):
   - **Episodic** (one target file per theme):
     - No collision → copy `agent-X/episodes/[theme].md` → `.agents/session/[theme].md`.
     - Same theme across agents → **merge**: stack sub-episodes newest-first into one `.agents/session/[theme].md` (never clobber).
     - **Attribution on move**: every sub-episode H3 header gets `(agent: [domain])` from its source folder (the one moment provenance is unambiguous). Strip the redundant `[project]-` filename prefix (the folder IS the project now).
   - **Knowledge** (one target file per name):
     - No collision → copy → `.agents/knowledge/[file]`.
     - Same name across agents → **concatenate** both under `## [agent-domain]` headings in one `.agents/knowledge/[file]`.
   - Delete each central original only after its target is verified.

6. **Self-describe** (so external agents/tools reuse it without the fleet's central store):
   - `.agents/README.md` — one-screen layout explainer: what `session/` + `knowledge/` hold, that they're fleet-authored work-product graduated per ADR-010, what `(agent: …)` attribution means, and that identity memory intentionally stays with the fleet.
   - `.agents/session/index.md` — `# [PROJECT] Session Log` + one line per theme file (newest-first: agents involved + one-line summary).
   - `.agents/knowledge/index.md` — `# [PROJECT] Project Knowledge` + one line per file (description + source agent(s)).

7. **`AGENTS.md` pointer** — append (idempotent) alongside the existing `docs/` pointer:
   ```markdown
   ## Agent Memory
   Fleet-authored work-product for this project lives in `.agents/` — session history (`.agents/session/`)
   and project knowledge (`.agents/knowledge/`). Any agent working here can read and extend it.
   ```

8. **Central traces** — in EACH contributing agent's `agent-memory-index.md` / knowledge index, leave a permanent trace (do NOT delete the memory of the work):
   - Episodic ([ADR-011](//@agent-memory/docs/adr/2026-07-21-localized-episodic-index-repo-authoritative.md)): do **not** keep per-theme entries and do **not** repoint each one. Collapse them into **one** bounded pointer in a `## Localized Projects` subsection: `- [PROJECT](→ <project>/.agents/session/index.md) — localized YYYY-MM-DD (index in repo). Latest: [theme] (YYYY-MM-DD)`. The **repo** `.agents/session/index.md` is the authoritative newest-first index (MOVE-TO-TODAY applies there); the central pointer is a fleet-trace only, never the read source.
   - Knowledge: keep the repoint in the `# Core Knowledge Base` (or project-context) index (unchanged).
   - Traces are **permanent** — the fleet still remembers *what it did* even if the repo isn't checked out.

## Step 7: Write the central stub

Replace the central `orientation-map.md` with a **stub** (breadcrumb + machine-branch signal — NOT the real entries):

```yaml
---
project: "[PROJECT-NAME]"
home: project
localized_path: docs/orientation-map.md
created: "[original created]"
localized_on: "[TODAY-DATE]"
---

# Orientation Map — [PROJECT-NAME] (localized)

This project's orientation map + structural context live **in the project repo** at
`docs/orientation-map.md` (source of truth). This central file is a stub;
resolution keys off the project root (cwd) — see Localized Home Resolution.

### `docs/orientation-map.md` (in-project)
- **type**: orientation-map-link
- **home**: project
- **child_map**: (resolved at project root, not relative to this store)
- **notes**: "Localized [TODAY-DATE]. Load via /map-orientation (home: project resolution)."
```

## Step 8: Report

Summarize **both lanes**: `docs/` structural files moved vs stayed (with reasons); and — if the agent lane (Step 6b) was graduated — episodic + knowledge gathered/merged into `.agents/` (which agents contributed, any merges), central traces written (per-project episodic pointer + knowledge breadcrumb). Note `AGENTS.md` updated/created, stub written. Remind [USER-NAME]:
- Commit `docs/`, `.agents/` (if graduated), + `AGENTS.md` in the **project** repo.
- Commit the stub + central index changes (per-project episodic pointer + knowledge breadcrumb) in the **`@agent-memory`** repo.

---

## Localized Home Resolution

**The canonical rule** — defined here once, consumed by `/map-orientation` (all modes), `/update-project-context` (shared scope), and the **work-product memory** procedures (`/load-episodic`, `/update-episodic`, `/load-knowledge`, `/update-knowledge`, awakening, proactive loading) per [ADR-010](//@agent-memory/docs/adr/2026-07-13-work-product-memory-localization.md). Never applies to **identity** memory (reasoning, emotion, RAS), **general** (cross-project) knowledge, or business/strategy — those are always central.

Given a project:

1. Detect project; compute central map path `shared-memory/[project]/context/orientation-map.md`.
2. **Central map missing** → not localized → central-only defaults.
3. **Read central map frontmatter**:
   - `home: project` present → **(localized)**
     - `PROJECT_ROOT` = the project's working directory (cwd for the active project)
     - `MAP_PATH` = `<PROJECT_ROOT>/<localized_path>` (default `docs/orientation-map.md`)
     - `CONTEXT_DIR` = `<PROJECT_ROOT>/docs/`
     - `SESSION_DIR` = `<PROJECT_ROOT>/.agents/session/` — localized **episodic**; its `index.md` is the authoritative episodic index-of-record ([ADR-011](//@agent-memory/docs/adr/2026-07-21-localized-episodic-index-repo-authoritative.md) — the central store keeps only a bounded `## Localized Projects` pointer) (ADR-010)
     - `KNOWLEDGE_DIR` = `<PROJECT_ROOT>/.agents/knowledge/` — localized **project-scoped** knowledge (ADR-010)
     - `SOURCE_OF_TRUTH` = `project`
   - else → **(central)**
     - `MAP_PATH` = `shared-memory/[project]/context/orientation-map.md`
     - `CONTEXT_DIR` = `shared-memory/[project]/context/`
     - `SESSION_DIR` = `agent-[domain]/episodes/` (per-agent central — unchanged)
     - `KNOWLEDGE_DIR` = `agent-[domain]/knowledge-base/[project]/` (per-agent central — unchanged)
     - `SOURCE_OF_TRUTH` = `central`
4. Consumers operate on the resolved `(MAP_PATH, CONTEXT_DIR, SESSION_DIR, KNOWLEDGE_DIR)`. Resolution keys off **cwd**, never an absolute or cross-store relative path — this is what makes localization machine-portable across the different filesystem locations of the fleet store vs a client repo.
5. **Reachability guard (localized only)**: if `home: project` but the needed resolved dir (`SESSION_DIR` / `KNOWLEDGE_DIR` / `MAP_PATH`) does not exist on disk, the project is localized but its bundle isn't checked out at cwd → **report** *"[PROJECT] is localized but `.agents/` (or `docs/`) isn't here — wrong cwd, or the bundle isn't checked out"* and **STOP**. Never fall back to a central write — that silently re-forks the single home (ADR-010).

---

## Non-Goals (this iteration)

- **De-localization / reversal** — forward-only. Add a reverse flow only if a real engagement needs it.
- **Localizing identity memory** (reasoning, emotion, RAS), **general** (cross-project) knowledge, or **business / strategy / relationship** context — the preserved safety boundary; these never localize. (ADR-010 narrowed ADR-005's boundary to identity-vs-work-product: episodic + project-scoped knowledge now DO localize, into `.agents/`.)
- **Sub-map fractal localization** — the root map + its context localize; existing sub-maps keep their placement.

## Integration With Other Procedures

- **[map-orientation](map-orientation.md)** — consumes Localized Home Resolution in its Prelude (all modes read/write the resolved `MAP_PATH`/`CONTEXT_DIR`). `.agents/` is a hidden folder, so its C2 scan already skips it — the agent lane never pollutes the map.
- **[update-project-context](memory/update-project-context.md) / [load-project-context](memory/load-project-context.md)** — shared scope resolves to `docs/`; **private scope resolves to `.agents/knowledge/`** when localized (ADR-010). These are the real project-scoped knowledge writer/reader.
- **[update-episodic](memory/update-episodic.md) / [load-episodic](memory/load-episodic.md)** — episodic files **and the index** resolve to `SESSION_DIR` when localized; the repo `.agents/session/index.md` is the read/write/archive index-of-record, and central keeps one bounded `## Localized Projects` pointer ([ADR-011](//@agent-memory/docs/adr/2026-07-21-localized-episodic-index-repo-authoritative.md)).
- **[update-knowledge](memory/update-knowledge.md) / [load-knowledge](memory/load-knowledge.md)** — general knowledge stays central; project-scoped resolves to `KNOWLEDGE_DIR` (`.agents/knowledge/`) via `/update-project-context`.
- **[wrap-up](wrap-up.md)** — inherits via `/map-orientation --session-touched` + `/update-episodic` (no direct change).
- **[awaken-agent](awaken-agent.md)** — Phase 2 resolves the localized **shared context-index** (`docs/`), **episodic** (`.agents/session/`), and **private project knowledge** (`.agents/knowledge/`) via Localized Home Resolution; the orientation map is resolved separately by `/map-orientation` (bare) at load.

## Anti-Patterns

1. **Moving IDENTITY memory into a repo** — reasoning, emotion, RAS, **general** (cross-project) knowledge, and business/strategy/relationship never localize. (Episodic + project-scoped knowledge DO — into `.agents/` — per ADR-010.)
2. **Dual home** — leaving a full central map AND an in-project map. Central must become a stub. Same for work-product: content **and the episodic index** move to `.agents/`; central keeps only a stub / bounded pointer, never a full mirror ([ADR-011](//@agent-memory/docs/adr/2026-07-21-localized-episodic-index-repo-authoritative.md)).
3. **Boolean consent flag in `AGENTS.md`** — use presence + a prose pointer; a boolean duplicates filesystem state and can lie.
4. **Absolute or cross-store relative paths in the stub** — breaks portability; resolution keys off cwd.
5. **Auto-moving ambiguous files** — classification pauses for confirmation; never move on assumption.
6. **Silent central fallback when `.agents/` is unreachable** — if localized but the bundle isn't at cwd, STOP and report; never write to the central store (it silently re-forks the single home).
7. **Clobbering same-name work-product instead of merging** — episodic merges as stacked sub-episodes; knowledge concatenates under `## [agent]` headings. Never overwrite.
8. **Localizing general (non-`[project]/`) knowledge** — only the project-scoped subfolder travels; general craft stays fleet-central.
