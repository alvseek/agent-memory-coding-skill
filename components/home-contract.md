# HOME Contract (project component)

The four-value home a procedure reads or writes project memory from. **This is a component, not a standalone skill** — a procedure that touches project memory invokes it.

*Owned by `agent-memory-project`. It carries only the default home; a caller may inject different values.*

---

**`HOME` is four values:**

```
HOME = { MAP_PATH, CONTEXT_DIR, SESSION_DIR, KNOWLEDGE_DIR }
```

**Default home** (the values in force unless a caller injects different ones):

- `MAP_PATH` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/orientation-map.md`
- `CONTEXT_DIR` = `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/`
- `SESSION_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/episodes/`
- `KNOWLEDGE_DIR` = `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/[project]/`

A procedure here never resolves the home itself. It operates on the four values it is given.
