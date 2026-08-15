# Archive Plan — Move to Completed (plan component)

Move a finished artifact into its `completed/` archive. **This is a component, not a standalone skill** — a caller's "Move to Completed" / "archive on sign-off" step invokes it by reading and following this file. The caller supplies the **item** (a `.md` file or a folder) and, optionally, a **destination root**.

*Consumed by `/high-wizard`, `/pixel-wizard` (single plan file), `/council-of-wizards`, `/forge-of-covenant`, `/rite-of-creation` (whole plan folder), and `/run-qa-test` (a signed-off QA checklist).*

---

**Destination root** — defaults to `./plans/completed` when the caller doesn't name one.

```sh
mkdir -p [destination-root] && mv [source-path] [destination-root]/[item-name]
```

Callers in use:

| Caller | Item | Destination root |
|---|---|---|
| the wizards | `./plans/[plan-file-or-folder]` | `./plans/completed` (default) |
| `/run-qa-test` | `qa/checklists/[checklist].md` | `qa/checklists/completed` |

**Archive only on an explicit decision.** Completion is a result; archiving is a sign-off. The caller confirms with [USER-NAME] before invoking this — never archive because a run came back green.

**Note**: links pointing *into* the moved artifact will break after the move (episodic memory entries, a runbook referencing a checklist). This is accepted — archived items are historical records, not live references.
