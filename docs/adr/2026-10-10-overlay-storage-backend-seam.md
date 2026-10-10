# ADR-023: The Overlay Storage-Backend Seam (Markdown Live, DB Deferred)

**Date**: 2026-10-10

**Status**: Accepted

**Extends**: ADR-012 (*Memory Core / Coding-Skill Decoupling*) and the memory core's own storage-backend seam (`control-files/procedures/memory/storage-backends/`).

---

## Problem

The memory core's procedures are storage-agnostic: each carries its judgment in its body and delegates its storage mechanics to a swappable backend, `markdown` or `db`. The coding overlay is not. Its project-memory procedures (`update-project-context`, `load-project-context`, `map-orientation`) spell out `mkdir`, `cp`, `rm` and file paths inline, so their only storage is the markdown tree. When a db backend for the overlay ("Hermod") eventually lands, every one of those sites has to be rewritten — the exact second pass the core's seam exists to avoid.

## Decision

**We decided to**: give the overlay's project-memory procedures the same storage-backend seam the core has, with **markdown** implemented now and **db** declared and deferred.

- New `storage-backends/` in this repo: `README.md` (the contract), `markdown.md` (concrete ops), `db.md` (a deferral notice plus a per-op checklist), and `seam.py` (the substitution logic).
- Each seamed procedure gains exactly one `## Storage Mechanics` section — the swap point — and calls its storage abstractly as `§ op`.
- The compiler (`setup-scripts/compile-procedures.py`) swaps the marker for the markdown backend's ops before writing `output/`, so the installed commands carry the file mechanics as before.

**Scope.** Only project-**memory** access is seamed: `update-project-context`, `load-project-context`, `map-orientation`, and `awaken-coder`'s store reads. The push/pull family and `/project-wrap-up` are **out of scope** — they persist the working project repo (the user's code) and delegate memory persistence to the core's `/push-memory`; neither is a project-memory storage op, and seaming them would wrongly stop pushing code once a db backend turned them into no-ops.

**Why we chose this:** a partial seam re-creates the problem it exists to prevent, and the four procedures are every place project memory is read or written. The core already proved the shape, so this is a mirror, not an invention.

## What Was Built (Requirements)

- `storage-backends/` with the contract, the markdown backend, the deferred db backend, and the vendored `seam.py`.
- The four procedures refactored to `§ op` references plus a `## Storage Mechanics` swap section.
- The compiler composes the markdown backend and reports unresolved ops / a missing backend section (`--strict` fails on them).
- Tests: seam substitution, unresolved-op and missing-backend reporting, no marker in the real output, every referenced op resolves, and the db checklist covers every referenced op.

**Success Criteria:** the compiled `output/` preserves every mechanic of the previous commands (verified by a baseline diff); every `§ op` resolves; no marker survives; the suite is green.

## Alternatives Rejected

- **Byte-identical compiled output.** Not achievable — a real seam moves the mechanics out of the procedure bodies, so the compiled text changes shape even where behaviour is identical. The guarantee is mechanic accounting, which the core's own fidelity gate uses.
- **Seaming the push/pull family.** They persist the code repo, not project memory (see Scope).
- **A shared `seam.py` package now** (the correct long-term target). Too much packaging for one small file right now. `seam.py` is vendored as a copy, marked as tech debt, to be replaced by a shared package imported by the core compiler, Munnin and this overlay — the intended end state alongside the microservices monorepo.
- **Writing real `db.md` mechanics now.** The target store does not exist; mechanics would be invented. `db.md` is a deferral notice plus the op checklist.

## Consequences

- Adding a db backend later is a pure addition: implement `db.md`'s sections; no procedure changes.
- The vendored `seam.py` is a known duplication of the core's copy — keep the two byte-identical until the shared package exists.
- `output/` is a build artifact (gitignored), so the behavioural fidelity proof is a one-time diff; the lasting guard is the structural test.
