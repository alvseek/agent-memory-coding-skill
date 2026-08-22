# Push Exclude Policy (push component)

Some repos must never be auto-committed or pushed. **This is a component, not a standalone skill** — a push flow's "check the exclude list first" step invokes it by reading and following this file.

*Consumed by `/push-project`, and inherited from there by `/push-all` and by any wrap-up that composes them.*

---

**Before pushing, consult the project's push-exclude list** — `push-policy.md` in the project's shared context. It is ordinary project context, so resolve its home the same way every other context file is resolved (`/localize-context`'s Localized Home Resolution): a **central** project keeps it at `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/push-policy.md`, while a **localized** one — its orientation map carries `home: project` — keeps it at `<project-root>/docs/push-policy.md`.

Repos and submodules listed there are **vendored / third-party / read-only**: never commit or push them, and do not count their state against completion. Report each as `skipped (excluded)` so the skip is visible rather than silent. An absent file means no exclusions — push everything in scope as normal.

**How one comes to exist**: `/update-project-context` writes it. Describe what must not be pushed and why, and it creates or updates `push-policy.md` under the resolved home and registers the entry in that project's context index. Nothing creates the file automatically during a push — an exclusion is a deliberate statement about ownership, not something a push flow should infer from a repo looking untouched.
