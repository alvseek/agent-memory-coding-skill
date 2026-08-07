# Present Doc For Review (doc-generation component)

Shared review-handoff for the doc generators. **This is a component, not a standalone skill** — a generator's "Present for review" step invokes it by reading and following this file.

*Consumed by `/generate-architecture-docs`, `/generate-domain-docs`, `/generate-flow-docs`. The caller supplies **what artifact to show**; the marker taxonomy and the present-and-confirm shape are identical. `/generate-readme` keeps its own variant (section-removal note, fixed placement).*

---

Present the completed doc to [USER-NAME]:

- **Show the artifact** (caller-specific): the diagram + prose / ERD + prose / README sections.
- **Group outstanding markers by type** so [USER-NAME] can address them efficiently:
  - `[TODO]` — **needs input**: items only a human can provide
  - `[CONFIRM]` — **needs verification**: items found but uncertain
  - `[NOT FOUND]` — **missing from code**: items expected but not present in the codebase
- **State the placement** (the LCA folder chosen) — and, where the lens has them, the **altitude** (map vs deep-dive) and whether the readability health-check recommended a **split**.
- **Ask if anything needs adjustment.**
