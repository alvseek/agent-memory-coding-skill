# Compute Doc Placement — LCA (doc-generation component)

Shared placement rule for the doc generators. **This is a component, not a standalone skill** — a generator's "Compute placement" step invokes it by reading and following this file.

*Consumed by `/generate-architecture-docs`, `/generate-domain-docs`, `/generate-flow-docs`. The caller supplies the **lens** and **what files count as scope**; everything else is identical.*

---

**Caller supplies:**
- **lens** — `architecture` / `domain` / `flows` (the `docs/{lens}/` subfolder).
- **scope files** — what counts for this lens: *architecture* = the subsystem's file paths · *domain* = the entity files · *flows* = every code participant the flow runs through (exclude externals like third-party APIs).
- **name** — the doc's `{name}` (subsystem / model / flow name).

**Compute:**

1. Collect the file paths in scope (per the caller's definition above).
2. Compute their **nearest existing common ancestor** folder. Use the nearest *existing* ancestor — **never invent a parent folder**.
3. Target = `[LCA]/docs/{lens}/{name}.md`.
   - Contained in one module → LCA = that module → co-located `[module]/docs/{lens}/`.
   - Spanning modules → LCA = their nearest common ancestor's `docs/{lens}/`.
4. Create `docs/{lens}/` at the LCA if it doesn't exist.

> **Placement Contract**: **scope = location.** The doc lives in the **project's own tree** at the LCA of what it covers — measured by *blast radius, not casual references* (only the files the doc actually covers/executes-through count). Project-wide maps (architecture-map, etc.) live at the project-root `docs/{lens}/` by nature.
