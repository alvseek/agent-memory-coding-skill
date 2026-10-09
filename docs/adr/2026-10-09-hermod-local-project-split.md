# ADR-022: Extracting the Localization Lane into `hermod-local`

**Date**: 2026-10-09

**Status**: Accepted

**Extends**: ADR-012 (*Memory Core / Coding-Skill Decoupling*), ADR-020 (*The Hermod Family and Per-Layer Access Declarations*), and ADR-021 (*Extracting the Wizard Cluster into `hermod-wizards`*).

---

## Problem

After the fleet and wizard extractions, `agent-memory-coding-skill` held two concerns that change for different reasons: the central-only shell and project/documentation surface, and the **localization lane** (`localize-context`, `localized-memory-workflow`, and the `## Localized Home Resolution` rule). The lane is the only part that reads or writes the working repository, and a defect in it can reach base procedures such as the awakening, because roughly thirteen procedures resolve the localized home inline.

Localization is a **horizontal** concern: a branch that runs through many procedures rather than a self-contained vertical like the wizards. Extracting it therefore cannot be a pure file move; the cut has to say how the base procedures get a home once the rule leaves.

---

## Decision

**We decided to**: extract the localization lane into a new standalone public repo, `agent-memory-local` (`hermod-local`), and rename `agent-memory-coding-skill` to `agent-memory-project` (`hermod-project`), which becomes **central-only**.

The base procedures no longer test `home: project`. They operate on an injected **home contract**, `HOME = { MAP_PATH, CONTEXT_DIR, SESSION_DIR, KNOWLEDGE_DIR }`, and carry only the central default. `agent-memory-local` owns the resolution that reads the central map's `home: project` frontmatter, overrides `HOME`, and enforces the reachability guard. `awaken-coder` detects a localized project by the presence of `.agents/` at cwd and mentions `hermod-local`; from there the lane is driven by local.

The rename is a full identity rename (repo, installer manifests, folder prefix `agent-coding-` → `agent-project-`, path placeholder, environment declaration), and the lineage note records that the original repo split four ways: project, local, fleet, wizards.

**Why we chose this:**
- One repo per concern, matching the fleet (ADR-020) and wizards (ADR-021) extractions.
- Making the base central-only is what actually isolates the fragile lane: project stops containing the rule, so a local defect cannot reach the awakening path.
- Parameterizing on `HOME` (rather than a pointer or duplication) keeps the rule single-homed in `agent-memory-local` with no second copy to drift.

---

## What to Build (Requirements)

**Core Requirements:**
- New public repo `agent-memory-local`: `localize-context`, `localized-memory-workflow`, a new read-only `load-local-context`, and `components/localized-home-resolution.md`; plus its own installer tooling (prefix `agent-local-`, placeholder `[path-to-agent-memory-local]`, manifest `.agent-memory-local-<harness>-manifest`).
- Rename `agent-memory-coding-skill` → `agent-memory-project` with the full identity rename; add `components/home-contract.md`; strip the `home: project` branch from the ~13 consumers and repoint them at `HOME`.
- Every installer (core, project, fleet, wizards, local) lists the others' manifests so a cleanup never deletes a sibling's folders, and a one-time step removes the orphaned `agent-coding-*` folders.
- Lineage note (`MIGRATION.md` + `README.md`) naming all four successor repos.

**Success Criteria:**
- No localization logic remains in `agent-memory-project`; a grep for `home: project` and `.agents` across its procedures returns nothing.
- `agent-memory-local` installs as `agent-local-*` skills with green CI; re-running any installer leaves every other layer intact.
- `awaken-coder` hands off to `hermod-local` on detection, and no stale `agent-coding-*` folders remain after the rename.
- Both suites green; installs verified on OpenCode and Claude Code.

---

## Alternatives Rejected

- **No split, one lane**: the drift being removed stays, and a local defect still reaches base procedures.
- **Split with a pointer**: leaves `home: project` inside the base; the horizontal survives.
- **Split with duplicated localized-aware consumers**: two homes for the same procedure, recreating the drift as duplication.
- **`hermod-project` keeps the resolution**: rejected — the base should not localize at all.
- **Declare `[LOCAL-ACCESS]`**: nothing calls `hermod-local`; it is a leaf, so the declaration would have no reader.
- **History-preserving extraction** (`git filter-repo`): the fleet and wizards extractions used a fresh repo plus a `MIGRATION.md`.

---

**Full context**: [High Wizard plan](../../plans/2026-10-09-agent-memory-local-project-split.md)

---
