# Plan Self-Review + Auto-Fix (plan component)

Shared self-review pass for the planning wizards. **This is a component, not a standalone skill** — a wizard's "Self-Review + Auto-Fix" step invokes it by reading and following this file.

*Consumed by `/high-wizard` and `/pixel-wizard` (identical generic checklist). Wizards with domain-specific review criteria — `/forge-of-covenant` (milestones/principles/risks), `/rite-of-creation` (phases/exit-criteria) — keep their own checklist.*

---

Do a self-review by thinking critically:
- a. Is there anything missing that should be in scope?
- b. Is there anything that should be out of scope?
- c. Is there any conflict between confirmed decisions and the solution/implementation?
- d. Is there anything redundant?
- e. Are implementation phases in the right order?

**If issues are found**: Auto-fix consistency issues (conflicts, redundancies, ordering) directly in the plan file. For issues that require a NEW decision (scope changes, missing requirements), STOP and present to [USER-NAME] by invoking the `/wait-options` command procedure before continuing.

**Report**: Briefly list any auto-fixes made. If no issues found, proceed silently to the next step.
