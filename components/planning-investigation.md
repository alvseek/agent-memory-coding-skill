# Planning Investigation (plan component)

Shared investigation checklist for the planning wizards. **This is a component, not a standalone skill** — a wizard's investigation step invokes it by reading and following this file. It produces **findings**: what exists, what could be done, and what would break. Turning findings into a decision form is the Planning Decision component's job, which your procedure reads separately.

*Consumed by `/quick-wizard` and `/high-wizard`, which share an investigation shape. Wizards with a different one — `/pixel-wizard` (visual framework check), `/council-of-wizards` (feature decomposition), `/forge-of-covenant` (7Q exploration) — keep their own variant. A leaf wizard reads whatever was settled before it started — a parent's handoff, or a pre-planning discussion — in its own procedure before reaching this checklist; that read is a precondition to investigating, not a step within it.*

---

This is where the thinking happens — NOT in the plan document. Work the checklist below IN ORDER and write down what you find. Do not decide yet what [USER-NAME] sees: everything here is a candidate, and candidates are filtered, framed and ordered afterwards. **Your own procedure's opening states what your altitude collects decisions about** — re-read it before you start, because it tells you which findings are yours to gather and which belong to a level above or below.

**Investigation checklist (in order):**

1. **Requirements clarity** - Is the intent already clear? Is there ambiguity within the context? Note every ambiguity you cannot resolve from the material in front of you
2. **Codebase scan** - Scan relevant files, modules, and architecture related to the task to understand current state
3. **Critical technical points** - Identify the main function/module entrypoints, core engine algorithm/logic pattern, and key execution flow touchpoints. Note them even when the implementation direction is already clear — they are what the work commits to
4. **Alternative approaches** - Based on the requirement, discover what ways this can be done (there's usually more than one) → record each with what it costs
5. **Reusable components** - Identify existing functions, utilities, patterns that could be leveraged → note which of them genuinely fit
6. **Conflicts and constraints** - Note what could go wrong, what limits exist → with the pros and cons of living with each
7. **Integration points** - Check what existing code/systems will be affected, and how
8. **Quality standard discovery** - Search for `quality-standard.md` in the project via glob (`**/quality-standard.md`). If found, load it as additional implementation criteria to apply during this plan. If not found, note it and proceed

When the checklist is done, hand the findings to the Planning Decision component your procedure names — it sorts what earns a place, writes the frame, and orders what survives.
