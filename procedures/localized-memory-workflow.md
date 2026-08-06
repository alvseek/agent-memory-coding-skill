# Localized Memory Workflow (coding overlay)

The localized behavior lifted out of the memory-core primitives (Decision A). A coding agent applies this **only when the current project is localized** (`home: project`, per /localize-context). Otherwise the core's central behavior stands unchanged.

Localization is **behavioral**, not just path-based: the repo owns the authoritative index, entries flat-merge across agents, and archives live repo-side. This doc is the override the coding agent follows for each memory operation on a localized project.

## Storage resolution

For a localized project, the storage-location resolver returns **repo-side** paths:
- `SESSION_DIR` = `<project-root>/.agents/session/` (episodic)
- `KNOWLEDGE_DIR` = `<project-root>/.agents/knowledge/` (private project knowledge)
- `CONTEXT_DIR` = `<project-root>/docs/` (shared project context)
- Reachability guard everywhere: if the resolved dir is absent at cwd → STOP + report *"localized but not checked out here"*, never fall back to writing centrally.

## Episodic write (`/update-episodic` override)

- Episode files **and the episodic index** live in `SESSION_DIR`, **not** `agent-[domain]/episodes/` or the central index. Write/append the theme file there and refresh the repo index `.agents/session/index.md` (the **MOVE-TO-TODAY** rule applies to *this* repo index).
- The H3 header's `(agent: [domain])` tag is **required** here — episodic is flat-merged across agents in `.agents/session/`, so the folder no longer implies authorship.
- In the central `agent-memory-index.md`, do **not** write a per-theme breadcrumb — ensure/refresh **one** bounded pointer in a `## Localized Projects` subsection: `- [PROJECT](→ <root>/.agents/session/index.md) — localized YYYY-MM-DD (index in repo). Latest: [theme] (YYYY-MM-DD)`.
- **Lazy migration**: if legacy per-theme breadcrumbs for this project still exist centrally, collapse them into that single pointer on this touch.

## Archive (`/archive-old-memories` override)

- The episodic index + its archive live in the repo:
  ```
  <project-root>/.agents/session/
  ├── index.md                          # authoritative newest-first index (read source)
  ├── [context-theme].md                # active rolling theme files (kept)
  └── archive/[YYYY]-archived-context.md # archived index entries by year (repo-side)
  ```
- The central `## Localized Projects` pointer is bounded (one line) → **skip it, never archive it**.
- Repo-side change → **commit the project repo** (the archive lives there, not in `@agent-memory`).
- Emotional moments never localize — they always archive to central `agent-[domain]/archive/[YYYY]-archived-moments.md`.

## Reads (`/load-episodic`, `/load-project-context` override)

- Episodic: the list came from the repo index — read each selected file from `SESSION_DIR`.
- Project context: shared entries from `CONTEXT_DIR` (`docs/`), private from `KNOWLEDGE_DIR` (`.agents/knowledge/`).

## Project-context write (`/update-project-context` override)

- **Shared** scope → the in-project `CONTEXT_DIR` (`docs/`) instead of central `shared-memory/[project]/context/`.
- **Private** scope → the in-project `KNOWLEDGE_DIR` (`.agents/knowledge/`) instead of central `agent-[domain]/knowledge-base/[project]/`. Refresh `.agents/knowledge/index.md` and repoint the central index breadcrumb.

## Graduation

Promoting a project to localized (creating `.agents/` + moving memory in) is `/localize-context`'s job — see /localize-context.
