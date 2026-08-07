# Awaken Coder — Coding-Agent Awakening Overlay

Orchestrating overlay for **coding agents** (working in a repo). It composes the memory-core awakening with repo/environment context: the core loads central memory + the fleet roster; this overlay adds localization, orientation map, and task-system.

**Delivery**: as a local skill/command (Claude Code CLI) or an MCP prompt (`agent-memory-coding-skill` server). Either way, the composition is agent-side — this overlay *invokes* the core `/awaken-agent`; it never reaches into the core repo/server directly.

## Arguments

`[domain]` — the agent domain to awaken (e.g. `invintiry`, `aquazone`).

## Procedure

1. **Run core awakening** — invoke the memory core `/awaken-agent [domain]` (Phase 1 identity + Phase 2 **central** memory + report). This loads identity, reasoning, emotional, knowledge, the latest **central** episodic entry, and **central** project context.

2. **Resolve localized home** — apply /localize-context for the current project (cwd). If the central map frontmatter has `home: project`:
   - **Episodic**: read the repo index `.agents/session/index.md` (authoritative, newest-first); take its **top** entry → read that theme file from `.agents/session/`. **This supersedes** the central episodic the core loaded. **Reachability guard**: if `.agents/session/` is absent at cwd → report *"[project] is localized but not checked out here"* + skip open items.
   - **Context**: shared entries resolve to `<project-root>/docs/`, private to `<project-root>/.agents/knowledge/` (instead of the central paths the core loaded).
   - For memory **writes** this session, follow /localized-memory-workflow.

3. **Orientation map** — Call `/map-orientation` (bare, load-only) to load the orientation map if it exists — never auto-create. (The core awakening already loaded the project's `fleet-agents.md` roster + surfaced the fleet in its report.)

4. **Task system check** — match the working directory to its task system and run that project's Awakening Hook: **Todoist** (`aquazone`, `invintiry`) → query `@agent-[my-domain]` + `@waiting-human`; **Jira/Linear** (`plko` / `ocx-platform`, `ocx-data`) → the Awakening Hook section in that project's context. Report counts. No matching project → skip silently.

5. **Augment the core report** — fold these additions into the core's report block:
   - **Current project + orientation map status**: if no map → *"No orientation map for [project] yet — use `/map-orientation create` to scan and create when ready."*
   - **Task system**: report the queried counts.
   - If localized: note that localized episodic/context superseded the central load.

*(Domain Boundary Awareness — consult `fleet-agents.md` and name the right specialist when asked outside your domain — is inherited from the core awakening; no need to restate it here.)*
