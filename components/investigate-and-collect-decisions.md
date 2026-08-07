# Investigate & Collect Decisions (plan component)

Shared investigation checklist for the planning wizards. **This is a component, not a standalone skill** — a wizard's "Investigate and Collect Decisions" step invokes it by reading and following this file. It produces decision items for the WAIT Options form.

*Consumed by `/quick-wizard` and `/high-wizard` (identical decision-collection discipline). Wizards with a different investigation shape — e.g. `/pixel-wizard` (visual framework check), `/council-of-wizards` (feature decomposition), `/forge-of-covenant` (7Q exploration) — keep their own variant.*

---

This is where the thinking happens — NOT in the plan document. Follow the investigation checklist below IN ORDER. Each item can produce decision items for the WAIT Options form.

Read and follow the /wait-options for collecting decisions.

**Investigation checklist (in order):**

1. **Requirements clarity** - Is the intent already clear? Is there ambiguity within the context? If ambiguous, create decisions to clarify before proceeding
2. **Codebase scan** - Scan relevant files, modules, and architecture related to the task to understand current state
3. **Critical technical points disclosure** - Identify the main function/module entrypoints, core engine algorithm/logic pattern, and key execution flow touchpoints. Surface these in WAIT Options even when the implementation direction is already clear
4. **Alternative approaches** - Based on the requirement, discover what ways this can be done (there's usually more than one) → offer as decisions
5. **Reusable components** - Identify existing functions, utilities, patterns that could be leveraged → offer to reuse the related/reusable ones as decisions
6. **Conflicts and constraints** - Note what could go wrong, what limits exist → if any, offer options based on pros and cons as decisions
7. **Integration points** - Check what existing code/systems will be affected → if concerning, offer options as decisions
8. **Quality standard discovery** - Search for `quality-standard.md` in the project via glob (`**/quality-standard.md`). If found, load it as additional implementation criteria to apply during this plan. If not found, note it and proceed
