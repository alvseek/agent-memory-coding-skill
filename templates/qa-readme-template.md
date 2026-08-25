---
doc_type: qa-riao-readme
---

# [Project] — QA Instrument

<!-- ============================================================
  QA README TEMPLATE — the R/I/A/O definition + front door for qa/

  This file is /build-qa-bench's SPINE — one doc filled progressively across its
  4 PHASES (not a one-shot). It becomes qa/README.md, the single front-door doc.

  THE ONE CONTRACT: the R/I/A/O table below is the INDEX. Its Mechanism links are
  how /run-qa-test finds each phase's script — not filenames, not in-script headers.
  /build-qa-bench is this table's only writer. (An in-script `# R/I/A/O category:`
  header is the RETIRED model; if you see one, it is inert — do not add new ones.)

  THE 4-PHASE LIFECYCLE (each phase reads/writes this doc):
  1. DEFINE   — fill ## The R/I/A/O Loop ONLY: what each phase MEANS in this project.
                Pull Mechanism + Status from qa/qa-map.md. A `missing` phase still gets its
                INTENT written (the "what it means" cell) — that's the spec phase 2 builds to.
  2. BUILD    — make each phase executable, by its map grade:
                  documented -> confirm it runs (no-op)
                  tribal     -> LINK it in the Mechanism cell (that link IS the promotion;
                                leave the script's name and location alone)
                  missing    -> build it from scratch, then link it
  3. TEST     — self-smoke the loop; only now may a Status become a real `documented`.
                Never fictionalize a green loop — an unbuilt/untested phase says so.
  4. DOCUMENT — write the REST of this doc back from what now actually exists + works
                (First-Time Setup, Daily Loop, Config Switching, Where Everything Lives,
                Known Gaps), THEN re-run /map-qa-instrument --rescan so the map reflects
                reality. The loop closes: map -> build -> map.

  SCOPE: this doc, the rig (scripts/seeds/config), the runbooks and the playbook are
  /build-qa-bench's. Checklists are /generate-qa-checklist's and fixtures are
  /integration-test's — link them here, don't author them here.

  As you fill: delete every <!-- tip --> and this HOW-TO block. Keep it honest.
============================================================ -->

> **What this is** *(one line)*: the QA instrument for [Project] — how to reset, seed, run, and observe it locally, and where every QA artifact lives.

---

## The R/I/A/O Loop

<!-- tip: THIS IS THE HEART OF THE DOC, and the index /run-qa-test resolves from. Define what
     each phase MEANS in THIS project (concrete, not the generic definition). Fill Mechanism +
     Status from qa/qa-map.md. Every Mechanism cell must link a file that actually exists. -->

Every QA cycle here is one turn of **RESET → INJECT → ACT → OBSERVE**:

| Phase | What it means in [Project] | Mechanism | Status |
|---|---|---|---|
| **RESET** — back to known-clean | [e.g. tear down containers; DBs back to last seed] | [`scripts/teardown.ps1`](scripts/teardown.ps1) | [documented / tribal / missing] |
| **INJECT** — realistic data in | [e.g. restore the prod-snapshot `.bak` files into the QA DBs] | [`scripts/import-seed.ps1`](scripts/import-seed.ps1) · [seeds](seeds/) | [status] |
| **ACT** — exercise the system | [e.g. bring the dependency stack up; run the app from the IDE] | [`scripts/start-stack.ps1`](scripts/start-stack.ps1) | [status] |
| **OBSERVE** — see what happened | [e.g. confirm services reachable; check logs / SQL asserts] | [`scripts/smoke-check.ps1`](scripts/smoke-check.ps1) | [status] |

<!-- tip: A `missing` phase is a gap /build-qa-bench fills — the "what it means" cell is the spec
     it builds to. A `tribal` phase means the mechanism exists but nothing pointed at it; adding
     the link above IS the promotion. Never rename or move an adopted script. -->

---

## First-Time Setup

<!-- tip: What a brand-new machine needs before the daily loop works. Keep it copy-pasteable;
     defer per-module detail to the runbooks. End with a "verify it worked" step. -->

**Prerequisites**: [runtimes / tools / container engine + mode]

1. [clone / submodule init]
2. [bring dependencies up — link the ACT script]
3. [get + inject seed data — link seeds/ workflow]
4. [verify — link the OBSERVE script; state the expected green result]

---

## Daily Loop

<!-- tip: The copy-pasteable happy path — the commands run each day. -->

```sh
[reset command]     # RESET — only when you need a clean slate
[inject command]    # INJECT — first run / after a reset
[act command]       # ACT — bring the stack up
[observe command]   # OBSERVE — confirm green
# then: run the app / feature under test from the IDE
```

---

## Where Everything Lives

<!-- tip: The front-door map. DROP any row this project doesn't have — never link a file that
     isn't there. Add rows as runbooks, checklists, and fixtures get created. -->

| Layer | What | Where | Built by |
|---|---|---|---|
| Per-module "how to run" | Runbooks | [runbooks/](runbooks/) | /build-qa-bench |
| Cross-module orchestration + E2E | Playbook | [playbook.md](playbook.md) | /build-qa-bench |
| Per-feature verification | Checklists | [checklists/](checklists/) | /generate-qa-checklist |
| Per-stage test preconditions | Fixtures | [fixtures/](fixtures/) | /integration-test |
| R/I/A/O scripts | Scripts | [scripts/](scripts/) | /build-qa-bench |
| Required config + templates | Config | [config/](config/) | /build-qa-bench |
| Test-data sources | Seeds | [seeds/](seeds/) | /build-qa-bench |
| What exists + maturity audit | Map | [qa-map.md](qa-map.md) | /map-qa-instrument |

---

## Config Switching

<!-- tip: Project-specific. The invariant: committed config = deploy target; local overrides are
     working-tree-only and never committed. Spell out the exact swap for THIS project. -->

[How local ↔ deployed config switching works here — e.g. hand-edit connection strings to
localhost and never commit the edit. Link the config inventory / REQUIRED.md.]

---

## Known Gaps / Debts

<!-- tip: Pull the tribal + missing rows straight from qa/qa-map.md, and mark which builder owns
     each. Be honest — this is what's NOT yet trustworthy in the instrument. -->

- [e.g. Fixtures are tribal — inline in the test suite, not extracted to fixtures/. → /integration-test]
- [e.g. No REQUIRED.md config inventory yet. → /build-qa-bench]

---

## Where To Go Next

- Run **one module** → its [runbook](runbooks/).
- Verify the **whole connected system** → the [playbook](playbook.md).
- See **what exists + how mature** → [qa-map.md](qa-map.md).
- **Build** a missing piece → `/build-qa-bench` (rig, runbooks, playbook) or `/integration-test` (fixtures + tests).
- **Run** the verification → `/run-qa-test`.
