---
doc_type: qa-riao-readme
---

# [Project] — QA Instrument

<!-- ============================================================
  QA README TEMPLATE — the RIAO definition + front door for qa/

  This file is /build-qa-instrument Step 1's output: it becomes qa/README.md,
  the single front-door doc for the QA instrument.

  HOW TO USE:
  1. Fill the R/I/A/O table FIRST — it is the point of this doc. Pull each phase's
     Mechanism + Status straight from qa/qa-map.md (the audit /map-qa-instrument wrote).
  2. A `missing` phase = write the INTENT (the "what it means here" cell) even before the
     mechanism exists, so build knows the target it must create.
  3. Fill the rest from the map's category sub-maps + the project's real setup.
  4. Delete every <!-- tip --> and this HOW-TO block as you go.
  5. Keep it honest — a phase that isn't built yet says so; never fictionalize a green loop.
============================================================ -->

> **What this is** *(one line)*: the QA instrument for [Project] — how to reset, seed, run, and observe it locally, and where every QA artifact lives.

---

## The R/I/A/O Loop

<!-- tip: THIS IS THE HEART OF THE DOC. Every QA cycle — a bug fix, an integration test,
     a pre-deploy check — is one turn of this loop. Define what each phase MEANS in THIS
     project (concrete, not the generic definition). Fill Mechanism + Status from qa/qa-map.md. -->

Every QA cycle here is one turn of **RESET → INJECT → ACT → OBSERVE**:

| Phase | What it means in [Project] | Mechanism | Status |
|---|---|---|---|
| **RESET** — back to known-clean | [e.g. tear down containers; DBs back to last seed] | [`scripts/teardown.ps1`](scripts/teardown.ps1) | [documented / tribal / missing] |
| **INJECT** — realistic data in | [e.g. restore the prod-snapshot `.bak` files into the QA DBs] | [`scripts/import-seed.ps1`](scripts/import-seed.ps1) · [seeds](seeds/) | [status] |
| **ACT** — exercise the system | [e.g. bring the dependency stack up; run the app from the IDE] | [`scripts/start-stack.ps1`](scripts/start-stack.ps1) | [status] |
| **OBSERVE** — see what happened | [e.g. confirm services reachable; check logs / SQL asserts] | [`scripts/smoke-check.ps1`](scripts/smoke-check.ps1) | [status] |

<!-- tip: A `missing` phase is a gap /build-qa-instrument fills — the "what it means" cell is
     the spec build works to. A `tribal` phase means the mechanism exists but isn't discoverable;
     build promotes it (adds the header / links it here). -->

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

<!-- tip: The front-door map. Link each category to its folder + the audit map. Drop rows for
     categories this project doesn't have. -->

| Layer | What | Where |
|---|---|---|
| Per-module "how to run" | Runbooks | [runbooks/](runbooks/) |
| Cross-module orchestration + E2E | Playbook | [playbook.md](playbook.md) |
| Per-feature manual QA | Checklists | [checklists/](checklists/) |
| Per-stage test preconditions | Fixtures | [fixtures/](fixtures/) |
| Required config + templates | Config | [config/](config/) |
| R/I/A/O scripts | Scripts | [scripts/](scripts/) |
| Test-data sources | Seeds | [seeds/](seeds/) |
| Repeatable integration/e2e procedure | — | [integration-testing.md](integration-testing.md) |
| What exists + maturity audit | Map | [qa-map.md](qa-map.md) |

---

## Config Switching

<!-- tip: Project-specific. The invariant: committed config = deploy target; local overrides are
     working-tree-only and never committed. Spell out the exact swap for THIS project. -->

[How local ↔ deployed config switching works here — e.g. hand-edit connection strings to
localhost and never commit the edit. Link the config inventory / REQUIRED.md.]

---

## Known Gaps / Debts

<!-- tip: Pull the tribal + missing rows straight from qa/qa-map.md. Be honest — this is what's
     NOT yet trustworthy in the instrument. -->

- [e.g. Fixtures are tribal — inline in the test suite, not extracted to fixtures/.]
- [e.g. No REQUIRED.md config inventory yet.]

---

## Where To Go Next

- Run **one module** → its [runbook](runbooks/).
- Verify the **whole connected system** → the [playbook](playbook.md).
- Write a **repeatable** integration/e2e test → [integration-testing.md](integration-testing.md).
- See **what exists + how mature** → [qa-map.md](qa-map.md).
