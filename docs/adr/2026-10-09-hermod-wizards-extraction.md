# ADR-021: Extracting the Wizard Cluster into `hermod-wizards`

**Date**: 2026-10-09

**Status**: Accepted

**Extends**: ADR-012 (*Memory Core / Coding-Skill Decoupling*) and ADR-020 (*The Hermod Family and Per-Layer Access Declarations*).

---

## Problem

The coding overlay had grown into three concerns in one repo: the coding **shell** (`awaken-coder`, `project-wrap-up`, `dockerize`, push/pull), the project / documentation **surface** (orientation map, project context, doc generation, localization), and the planning-and-verification **cluster** (the wizard protocols, `implement-plan`, the QA pipeline). The cluster is the overlay's largest and most self-contained part, and it changes for its own reasons: a new wizard level or a QA tactic has nothing to do with localization or doc generation.

The cluster also has a clean dependency shape. It reads **only** the memory core (its `wait-options-coding` invokes the core `/wait-options`), and nothing else calls it. That makes it extractable without a cross-layer handoff — unlike the fleet, which needed an access declaration because the overlay calls it.

---

## Decision

**We decided to**: extract the wizard + QA + implement-plan cluster into a new standalone public repo, `agent-memory-wizards` (`hermod-wizards`) — a **leaf** that reads only the core and declares **no** access, because nothing calls it.

Moved: the six wizard protocols, `implement-plan`, the QA pipeline (`analyze-code-quality`, `build-qa-bench`, `generate-qa-checklist`, `integration-test`, `map-qa-instrument`, `qa-status`, `run-qa-test`, `setup-qa-visual-instrument`, `generate-standard`), `wait-options-coding`, nine components, three templates, and the five plan templates.

The overlay keeps the shell and the project / doc surface. The three doc generators (`generate-architecture-docs`, `generate-domain-docs`, `generate-flow-docs`), whose only use of `wait-options-coding` was a rarely-hit ambiguous-scope branch, now fall back to the core `/wait-options`. The overlay's installer stops installing and removing the cluster and protects the wizards manifest. The new repo installs itself (OpenCode only, for now).

**Why we chose this:**
- The cluster changes for its own reasons; one repo per concern matches the fleet split (ADR-020).
- It is a leaf: no caller, so no access declaration is earned. A declaration with no reader is dead config.
- The one shared piece (`wait-options-coding`) has a natural fallback (the core format), so the move leaves no cross-layer reference behind.

---

## What to Build (Requirements)

**Core Requirements:**
- New public repo `agent-memory-wizards`: the moved procedures, components, templates, and plan templates, plus its own copied-and-adapted tooling (prefix `agent-wizards-`, placeholder `[path-to-agent-memory-wizards]`, manifest `.agent-memory-wizards-opencode-manifest`).
- The overlay's OpenCode installer drops the cluster from its install set and adds the wizards manifest to its sibling-manifest protection.
- The three doc generators repoint to the core `/wait-options`.
- Cross-repo periphery: core `ARCHITECTURE.md`/`README.md`/`SETUP.md`, store context + orientation map, overlay `README.md`/`MIGRATION.md`/`NOTICE`/`pyproject.toml`/tests.

**Success Criteria:**
- `agent-memory-wizards` compiles clean and installs the cluster as OpenCode skills with green CI.
- The overlay no longer installs or removes the cluster, and a reinstall leaves the wizards' commands intact.
- No overlay procedure references `wait-options-coding` or any cluster procedure.
- The core guard is green and every boundary description names four repos.

---

## Alternatives Rejected

- **Keep the cluster in the overlay**: couples a planning/QA capability to a repo whose job is the coding shell and project surface.
- **Omit the wizards without `implement-plan` + QA**: orphans `implement-plan` (its only producer is a wizard) and strips the QA pipeline of its only automated caller.
- **Keep `wait-options-coding` in the overlay**: rejected by [USER-NAME]; the three consumers fall back to the core format, which keeps the dependency one-way.
- **Declare `[WIZARDS-ACCESS]`**: no caller exists, so the declaration would have no reader.
- **Extract the project / localization surface instead**: deferred to a later plan — this one is wizards-only.
- **History-preserving extraction** (`git filter-repo`): unnecessary for a small capability; the fleet and the overlay's own extraction used a fresh repo plus a `MIGRATION.md`.

---

**Full context**: [High Wizard plan](../../plans/2026-10-08-agent-memory-wizards-extraction.md)

---
