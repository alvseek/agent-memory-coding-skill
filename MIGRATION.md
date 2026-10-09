# Migration Note — extracted from the memory core (2026-08-06)

The procedures under [`procedures/`](procedures/) were **moved out of** the memory core repo
(`agent-memory-system` / `control-files/procedures/`) into this standalone overlay repo as part of
**Phase 2** of the memory-core / coding-skill decoupling (ADR-012).

## Later move — the fleet (2026-10-08)

The **fleet** procedures (`ask-agent`, `delegate-agent`, `setup-fleet`), scripts (`fleet-scripts/`),
and templates were moved **out** of this overlay into the sibling repo
[`agent-memory-fleet`](https://github.com/alvseek/agent-memory-fleet) (`hermod-fleet`). The overlay
keeps exactly one pointer to it, in `awaken-coder`. See that repo's `MIGRATION.md`.

## Later move — the wizards (2026-10-09)

The **wizard + QA + implement-plan cluster** was moved **out** of this overlay into the sibling repo
[`agent-memory-wizards`](https://github.com/alvseek/agent-memory-wizards) (`hermod-wizards`):
the six wizard protocols, `implement-plan`, the QA pipeline, `wait-options-coding`, their components,
the plan templates, and three templates. The overlay keeps the shell (`awaken-coder`,
`project-wrap-up`, `dockerize`, push/pull) and the project / doc surface. Nothing calls the wizards
layer, so it declares no access; it reads only the core. The three doc generators now fall back to
the core `/wait-options` on their ambiguous-scope branch. See that repo's `MIGRATION.md` and the
overlay's `docs/adr/2026-10-09-hermod-wizards-extraction.md`.

## What moved

31 add-on procedures relocated from `control-files/procedures/` — wizards, doc-gen, QA, fleet,
`map-orientation`, `localize-context`, and `pull-*`/`push-*` — joined by the 3 overlay files authored
in Phase 1 (`awaken-coder.md`, `localized-memory-workflow.md`, `project-wrap-up.md`).

## History

Per-file commit history for the moved procedures **remains in the core repo** (`agent-memory-system`).
This overlay starts with a **fresh initial commit** rather than a filtered history graft (decision:
fresh repo + migration note — simpler and safe; the authoritative history is preserved in the core).

## Accepted broken links

~230 references to the old `control-files/procedures/<name>.md` paths live in **frozen** episodic
memory and completed plans across the framework. These are **append-only archival records** and are
**left as-is** (framework convention already accepts broken links in `plans/completed/`). Only
**active** cross-references (per-agent memory files, `new-agent-template`, README/ARCHITECTURE, the
orientation map) are repointed — see the core repo's Phase 3 work.
