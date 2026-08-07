# Archive Plan — Move to Completed (plan component)

Move a finished plan into `./plans/completed/`. **This is a component, not a standalone skill** — a wizard's "Move to Completed" step invokes it by reading and following this file. The caller supplies the plan **file** (`.md`) or **folder** name.

*Consumed by `/high-wizard`, `/pixel-wizard` (single plan file) and `/council-of-wizards`, `/forge-of-covenant`, `/rite-of-creation` (whole plan folder).*

---

`mkdir -p ./plans/completed && mv ./plans/[plan-file-or-folder] ./plans/completed/[plan-file-or-folder]`

**Note**: Episodic memory links to the plan will break after moving. This is accepted — completed plans are archival.
