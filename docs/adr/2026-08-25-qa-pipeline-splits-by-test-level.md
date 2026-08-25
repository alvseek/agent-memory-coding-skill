# ADR-019: The QA Pipeline Splits by Test Level, and `/build-qa-test` Is Superseded

**Date**: 2026-08-25

**Status**: Accepted

---

## Problem

The QA instrument pipeline names only the top of the test pyramid. Across all five of its procedures the words *unit test* and *integration test* appear **zero** times; the only level vocabulary present is `e2e` / `end-to-end`. Unit tests do get written — high-wizard's plan template makes *"Tests written and passing"* a completion criterion — but the pipeline only ever **cites** them in a checklist's Automated column. Integration has no name, no owner, and no artifact, so the level that should carry the most tests is the one nothing decides about.

`/build-qa-test` had also been multiplexing unrelated procedures behind one name. Checklist mode was extracted on 2026-08-24. What remained still multiplexed: flow mode (`[flow]` or bare) and fixture mode (`--fixture`), where fixture mode enters the procedure at F5 while F5 and F7 read inputs — F3's deliverable list, F2's stage chain — that this entry point never produces. Both open defects in the file trace to that mid-procedure entry.

Reading what it owns makes the incoherence sharper. A runbook has ten sections and only two, `Act` and `Observe`, are test content; the other eight document how to reset, inject, start, configure and troubleshoot the bench, and the template's own first line calls it *"An operational how-to."* The playbook is the same shape. So a skill named for building tests spends most of its output documenting the rig.

Meanwhile the wizard barely reaches any of it. Every QA reference in `high-wizard.md` sits in Steps 17 and 19 of 19, and `/build-qa-test` is referenced zero times from any wizard — so the QA pipeline is invisible to the process that produces the code it exists to verify.

## Decision

**We decided to**: split the test layer by **test level**, define levels by what they substitute rather than by scope, and retire `/build-qa-test` as a name.

A level is decided by one question: *did you construct it, or did you start it?* **Integration** means your test process constructs the component and hands it one real dependency — the test provisions its own world, so it can run wherever that world can be provisioned. **System** means the thing is already running as it runs in production and you enter over a wire, with the environment providing the world. In-process HTTP (`WebApplicationFactory`, `TestServer`, `supertest`) is integration at the top of its range, not system. That distinction is load-bearing rather than taxonomic: it is exactly the line between what a stack-down wizard sweep can run and what it cannot.

`/integration-test` is new and owns one level end to end — the fixtures that reach a precondition, the test itself, and the run that proves it. It runs its own tests, which the old design could not, because a test that provisions its own world does not need the QA bench to be up.

`/qa-status` is new and answers *what is the state of QA here* — bench built, stack up, fixtures still unproven, checklists still unwalked. It never blocks; it reports, and the caller decides.

Runbooks and `qa/playbook.md` move to `/build-qa-bench`, which already owns the rig those documents link to and the `qa/README.md` index they are listed in. The `Act` / `Observe` scenarios inside them are deferred to a future system-test procedure. With fixtures gone to `/integration-test`, documents gone to the bench, and scenarios deferred, nothing is left that needs the name `/build-qa-test`.

**Why we chose this:**
- Levels differ by what they substitute, and substitution determines *where each level can run* — the only question that matters when the wizard sweep has the stack down and the QA session has it up.
- A runbook is a view onto the bench, not a test: eight of its ten sections are the rig, and it links the bench's mechanisms rather than restating them.
- An argument should vary a parameter of one procedure, never select between different procedures. Every remaining defect in `/build-qa-test` came from an argument doing the latter.

## What to Build (Requirements)

**Core Requirements:**
- `/integration-test [boundary]` gates on `/qa-status`, then DEFINE (name the boundary, name what stays doubled, name the fixtures and the assertion) with a stop before building, BUILD (fixtures down the existing fidelity-rung ladder, then the test), RUN (it must fail against unfixed code when it guards a defect; fidelity-check any rung 2 or 3 fixture; prove zero residue), RECORD.
- `/integration-test` has **no** fixture-only mode. A fixture with no test to consume it has no purpose, and a narrow entry into the middle of a procedure is what produced the defects this ADR retires.
- `/qa-status` reports its four checks under a single `## Result`, is generic rather than integration-specific, never blocks, and has no machine-readable mode — nothing in this framework parses output.
- `/high-wizard` Step 14, the last step before implementation, calls `/qa-status`. Not ready means confirming with the user that this plan carries no integration coverage, and **recording that answer in the plan** — an archived plan must never show absent coverage with no reason attached.
- The runbook and playbook templates, and the host-document handling that creates and links them, move to `/build-qa-bench`.
- `/build-qa-test` is deleted, with references updated in `/map-qa-instrument`, `/run-qa-test` and the overlay README.

**Success Criteria:**
- No reference to `/build-qa-test` survives outside this record.
- `/run-qa-test` Tactic A either names a producer for the runbook scenarios it consumes, or states in its own text that the producer is deferred.
- The four level definitions live somewhere an agent loads on relevance, not only inside a procedure.

**Deferred deliberately:**
- A system-test procedure owning `Act` / `Observe` scenarios. Until it exists, Tactic A consumes scenarios nothing produces. This is accepted, not overlooked.
- `/unit-test`. Current unit-test authoring inside the wizard's implementation phases already works.
- Per-phase wizard rewiring beyond the Step 14 gate — the plan-time instrument probe, the per-phase test-level column, and splitting `/analyze-code-quality` into per-phase analysis and batched decision.

## Alternatives Rejected

- **Keep `--fixture` as a mode.** It enters at F5 and reads F2's stage chain and F3's deliverable list, which it never runs. Both known defects in the file trace to it, and removing the entry point retires them without a patch.
- **Keep `/build-qa-test` narrowed to the system half.** The name would then describe runbooks, which are bench documentation, and scenarios, which are deferred — a skill named for tests owning neither.
- **Move runbooks to the deferred system-test procedure instead of the bench.** That leaves Tactic A without a producer for an unknown period, and it misfiles eight of ten runbook sections as test content.
- **Split `/qa-status` into a readiness gate and a separate debt surface.** They answer the same question at different granularity; one report serves both, and two names would drift.
- **Define levels by scope.** Scope is ambiguous in argument where substitution is answerable, and the ambiguity has already cost a real misunderstanding once (2025-09-04, in-process HTTP read as system testing).

**Full context**: [implementation plan](../../plans/2026-08-25-qa-pipeline-level-split.md).
