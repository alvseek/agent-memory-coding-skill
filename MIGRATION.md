# Migration Note — extracted from the memory core (2026-08-06)

The procedures under [`procedures/`](procedures/) were **moved out of** the memory core repo
(`agent-memory-system` / `control-files/procedures/`) into this standalone overlay repo as part of
**Phase 2** of the memory-core / coding-skill decoupling (ADR-012).

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
