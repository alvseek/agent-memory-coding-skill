# WAIT Options — Coding Extension

Extends the core `/wait-options` format with the vocabulary and variants that only apply when the decision is about code. Coding and repo procedures invoke **this** rather than `/wait-options` directly: it inherits the base format — zone taxonomy, context depth, options, confidence signals, reason paragraph, open questions, presentation style — and adds what implementation altitude needs on top.

The division follows the core file's own rule. `/wait-options` owns the **shape** of a presented decision, and it is deliberately altitude-blind: it states that the technical core must be named at the altitude the decision lives, without knowing what nouns that altitude is made of. This file supplies those nouns for code, and nothing else. Anything here that stops being code-specific belongs upstream in the core.

**Invoke the core `/wait-options` command procedure first** — its format rules are not in context, and this file does not restate them.

---

## Critical Technical Disclosure at Implementation Altitude

The core mandates naming the mechanism a decision commits to. At implementation altitude that mechanism is typically:

1. **Main function(s) or module entrypoint(s)** — the primary function/class/module that drives the behavior
2. **Engine algorithm or core logic pattern** — the key algorithm, transformation flow, or decision mechanism
3. **Execution flow touchpoints** — critical call path, integration boundary, or state transition that matters for this decision

Do not hide the mechanism just because there is no ambiguity. WAIT Options should surface it so [USER-NAME] can make informed decisions.

A decision that lives higher up — where a milestone boundary falls, which phase owns a requirement — is not made of these nouns. Disclosing it in this vocabulary either commits prematurely or invents detail; use the altitude your own procedure declares.

## Matching Examples to a Software Domain

The core says to include a concrete example when words alone aren't enough to evaluate the options. For code, match the example type to the domain:

- **UI/UX** → simple ASCII wireframe
- **Architecture / data model** → code snippet or schema fragment
- **Business logic** → example scenario showing behavior
- **Integration** → data flow or sequence sketch

## Quality Review Variant

Use this template when presenting code quality findings or implementation review results. It replaces the core's context-topic grouping with severity grouping, and addresses each finding by `[File:line]` — the two things that make it code-specific.

````
[preamble] (e.g., "Quality review for implementation:", "Code quality review for [scope]:"):

**Critical:**

**1. [File:line] [Issue]:**

- [What's wrong and why it matters.]

  > A) [Fix] `✓✓`
  > B) [Alternative]

  ([Why this matters.])

**Medium:**

**2. [File:line] [Issue]:**

- [What's wrong.]

  > A) [Fix] `✓✓`
  > B) [Alternative]

  ([Analysis.])

**Low:**

**3. [File:line] [Issue]:**

  > A) [Fix] `✓✓`
  > B) Skip

  ([Minor polish.])

**Summary**: X critical, Y medium, Z low

Reply with changes (e.g., "skip 3", "change 1 to B") or "proceed" to accept defaults, or "ship it" to skip all.
````

If no findings: report *"Quality looks good — no findings."* and proceed.
