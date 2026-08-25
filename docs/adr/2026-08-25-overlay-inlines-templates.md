# ADR-018: The Coding Overlay Inlines Templates

**Date**: 2026-08-25

**Status**: Accepted

**Extends**: ADR-017 (*Composed Instruction Artifacts — Inline by Default, Separate When Materialized*), in the memory core — `control-files/docs/adr/2026-08-25-composed-artifact-inlining.md`.

---

## Problem

ADR-017 sets the framework rule: inline by default, keep separate when the artifact must be materialized or when a server owns its format. The memory core applies it by leaving templates as references, because its templates are served as addressable Resources and inlining them would duplicate what the server already hands out.

**This repo has no server.** Its procedures compile to slash commands installed into the agent's own command directory, and from there the overlay's `components/` and `templates/` directories are not reachable — an installed command that references them points at nothing. Applying the core's *behaviour* here would produce exactly the silent degradation ADR-017 exists to prevent.

So the two compilers do opposite things with templates, and until now that difference lived only in two docstrings. Read cold, a deliberate divergence is indistinguishable from one of them being wrong.

---

## Decision

**We decided to**: inline templates in this repo, as a single appendix, and record the divergence as intended.

Compilation collects every template a procedure references — **transitively**, so a template referencing another pulls it in too — and emits them once as a bottom `## Templates` section, rewriting each reference to an in-doc anchor. Components are inlined at their reference point; templates are inlined once at the end, because a template is consulted rather than read in sequence and a procedure may reference the same one repeatedly.

This is not a departure from ADR-017. It is that rule's default, applied under the opposite reachability constraint: **the core separates templates because its reader can fetch them; this repo inlines them because its reader cannot.** The condition, not the behaviour, is what the two share.

**Why we chose this:**
- An installed command must be self-contained. This is the repo's stated compile goal — *"an installed slash command never points at a path the agent cannot reach"* — and it is a property of the delivery channel, not a preference.
- Inlining is what makes materialized artifacts work here at all. A procedure that copies a plan template into a project can only do so if it carries the template's text.
- The anchor rewrite keeps the reference readable, so the procedure's prose does not have to change to accommodate the transform.

---

## What to Build (Requirements)

**Core Requirements:**
- Templates are collected transitively and emitted once per compiled command as `## Templates`, with every reference rewritten to an in-doc anchor.
- Components remain inlined at their reference point. The two transforms stay distinct — a component is prose read in place, a template is an artifact consulted by name.
- Runtime references are left alone: memory-store paths and executable scripts are reachable at run time and must not be inlined.
- Anything this repo keeps separate carries a stated reason, per ADR-017.

**Success Criteria:**
- No compiled command references a `components/` or `templates/` path.
- A procedure that materializes a template produces the correct file content from the installed command alone, with the overlay repo absent.

---

## Known Divergence From the Rule's Intent

Two artifacts here meet ADR-017's **condition 1** — the plan template and the ADR template are both written to disk as files — and both are nevertheless **inlined today**.

That is deliberate and it is not the end state. Condition 1 assumes the agent can fetch the artifact it is told to write; this repo has no fetch channel, so keeping them separate would produce a dangling reference rather than a materialized file. ADR-017 already resolves this case: *keeping an artifact separate without a fetch channel is not condition 1 — inlining is the correct answer until a channel exists.*

**When a fetch channel exists**, these two should migrate to being fetched rather than inlined, and this ADR should be superseded rather than quietly ignored. Recording it here means the migration is a known follow-up rather than a rediscovery.

---

## Alternatives Rejected

- **Match the core's behaviour**: would leave installed commands pointing at overlay paths the agent cannot reach — a silent failure, not a smaller payload.
- **Inline templates at each reference point, like components**: a procedure referencing the same template three times would carry three copies. The appendix plus anchors gives one copy and keeps every reference readable.
- **One ADR covering both repos**: the core may not reference an add-on. ADR-012's one-way invariant means a shared document would either name this repo from the core — inverting the dependency — or be duplicated in both and drift. A base plus an extension is the shape the invariant already permits, and the same shape `/wait-options` and `/wait-options-coding` use.
- **Leave it in the compiler docstrings**: that is the state this ADR exists to end. Two docstrings disagreeing is not a record of a decision.
