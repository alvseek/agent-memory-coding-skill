# ADR-019: Templates Are Copied, Not Inlined

**Date**: 2026-08-28

**Status**: Accepted

**Supersedes**: [ADR-018: The Coding Overlay Inlines Templates](2026-08-25-overlay-inlines-templates.md)

**Extends**: ADR-017 (*Composed Instruction Artifacts — Inline by Default, Separate When Materialized*), in the memory core — `control-files/docs/adr/2026-08-25-composed-artifact-inlining.md`.

---

## Problem

ADR-018 decided this repo inlines templates, and justified the one case that plainly broke ADR-017's rule — the plan template and the ADR template, both written to disk — by asserting that no fetch channel exists here, so a separate artifact would be a dangling reference rather than a file.

**That assertion was false when it was written.** The installer registers `[path-to-agent-memory-coding-skill]` in the global instructions file, the compiler already leaves references rooted at it untouched, and `/ask-agent` and `/delegate-agent` have depended on exactly that to execute `fleet-scripts/*.sh` for as long as they have existed. Scripts got a path; templates got their content inlined and their path taken away.

The consequence was a defect nobody had traced, and it had been shipping in installed commands. Step 3 of `/high-wizard` reads `cp {source} ./plans/…` and `{source}` is **defined nowhere in the repo** — because Step 1 had pointed at the template by path and the compiler rewrote that path to an in-doc anchor. **Seven commands** shipped an unresolvable `{source}`.

The wider misreading was the classification. ADR-018 treated inlining as this repo's rule and the copied artifacts as exceptions. Checking every reference site shows the opposite: **all 17 templates are copied to disk.** The two that read as exceptions — the README and quality-standard templates, whose procedures say *"Read the … Template"* — say *"Copy it to the target location"* on the very next line.

---

## Decision

**We decided to**: stop inlining templates entirely. A template reference is left exactly as authored and resolves at run time through the registered path placeholder.

This is not a new rule; it is ADR-017's rule applied correctly. Condition 1 — *the artifact must be materialized* — covers every template in this repo, because a template here always becomes a file: a plan template becomes a plan, a doc template becomes a doc, the ADR template becomes an ADR. What the agent needs is the source path. Inlining hands over the content and takes away the source, which is precisely how `cp {source}` came to have nothing to substitute.

**Components are unaffected.** They remain inlined at their reference point, because a component is prose the procedure reads in place and never writes anywhere. The two categories now differ by what they *are* rather than by a compiler habit: **a component is read, a template is copied.**

**Why we chose this:**
- It makes the two categories checkable from the reference site rather than from a flag someone must remember to set.
- It restores the ability to `cp` a template at all, which is what the procedures have been instructing for months.
- Classification lives in the directory, so a new template is classified by where its author puts it, and putting it in the wrong place shows up in a diff.

---

## What to Build (Requirements)

**Core Requirements:**
- The compiler resolves templates but never inlines them: no `## Templates` appendix, no anchor rewriting. `template_appendix`, `rewrite_template_refs`, `titlecase` and the three rewrite patterns are removed.
- Template references are still **validated**. A reference naming a template that does not exist is reported and fails `--strict`. A dangling path is the one failure this stage still exists to catch, and it is the failure ADR-017 names as the reason inlining was ever the default.
- Every `{source}` placeholder is replaced with the real template path.
- The self-containment tests assert the true rule: no component link may survive, and every surviving template reference must be **rooted at the path placeholder**. An unrooted path would not resolve and remains a failure.

**Success Criteria:**
- No compiled command contains `{source}` or a `## Templates` appendix the compiler generated.
- Every template reference in every installed command is placeholder-rooted.
- Planting an unrooted template reference fails the suite; restoring the inlining compiler fails the suite.

---

## Alternatives Rejected

- **Per-template frontmatter flag** (`inline: true|false`): a materialized template is copied **verbatim by the agent**, so a compiler directive in its frontmatter would land inside every generated plan and doc. Eight of the seventeen carry no frontmatter at all.
- **An allow-list inside the compiler**: two places to edit, and a newly added template silently inherits whichever default the list does not mention.
- **Detecting the verb in the referencing prose** ("Copy" vs "Read"): unfixable for the dual-use case — `qa-readme-template` is both read as a spine and copied — and it would have produced the same wrong answer that reading only the first line of the reference produced here.
- **Amending ADR-018 in place**: every ADR in this framework carries *"supersede only — ADRs are append-only history"*. ADR-018 recorded a real decision on a false premise; erasing it would hide that the premise was never checked.

---

## Measured

- **121,306 bytes** of template text removed from the command set (581,827 → 460,521). Fifteen commands shrank, twenty-three were unchanged, **none grew**.
- Largest: `high-wizard` and `pixel-wizard` −15,290 B each, `forge-of-covenant` −14,283 B.
- **89** template references now survive into compiled output, all placeholder-rooted, **0** unrooted.
- Seven commands no longer ship an unresolvable `{source}`.
