# HOME Contract (project component)

The four-value home a procedure reads or writes project memory from. **This is a component, not a standalone skill** — a procedure that touches project memory invokes it.

*Owned by `agent-memory-project`. The localized override and the localized-home detection live in `agent-memory-local` (`components/localized-home-resolution.md`); this component carries only the central default.*

---

**`HOME` is four values:**

```
HOME = { MAP_PATH, CONTEXT_DIR, SESSION_DIR, KNOWLEDGE_DIR }
```

**Central default** (the values in force unless `agent-memory-local` has resolved a localized home):

- `MAP_PATH` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/orientation-map.md`
- `CONTEXT_DIR` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/`
- `SESSION_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/episodes/`
- `KNOWLEDGE_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/[project]/`

A procedure here never reads the central map's frontmatter to detect localization, and never reads the repo home itself. When the current project is localized, `agent-memory-local` resolves the repo-side override and these four names carry those values instead.
