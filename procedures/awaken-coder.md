# Awaken Coder — Coding-Agent Awakening Overlay

Orchestrating overlay for **coding agents** (working in a repo). It composes the memory-core awakening with repo/environment context: the core loads central memory; this overlay adds coding-scoped reasoning, localization, orientation map, fleet, and task-system.

**Delivery**: as a local skill/command (Claude Code CLI) or an MCP prompt (`agent-memory-coding-skill` server). Either way, the composition is agent-side — this overlay *invokes* the core `/awaken-agent`; it never reaches into the core repo/server directly.

## Arguments

`[domain]` — the agent domain to awaken (e.g. `invintiry`, `aquazone`).

## Procedure

1. **Run core awakening** — invoke the memory core `/awaken-agent [domain]` (Phase 1 identity + Phase 2 **central** memory + report). This loads identity, **universal** reasoning, emotional, knowledge, and the latest **central** episodic entry. (The core is **project-blind** — this overlay owns coding-scoped reasoning and project-context loading, in steps 2-3.)

2. **Load coding reasoning** — read `[AGENT-MEMORY-PATH]/shared-memory/coding-reasoning-memory.md` into your own context (silently skip if missing — not every store has one yet). These are the reasoning patterns that only fire for a coding agent: they name repo artifacts, plan logs, foreign code, and fleet teammates, so the project-blind core does not carry them. Process them alongside the core reasoning patterns the core awakening already loaded — same lean shape, same weight.

3. **Load project context + resolve localized home** — apply `/localize-context`'s Localized Home Resolution for the current project (cwd):
   - **Project context** — read the shared context index + the private (per-agent) context index (silently skip whichever is missing), resolved by home:
     - **Central** (no `home: project`): `[AGENT-MEMORY-PATH]/shared-memory/[project]/context/context-index.md` (shared) + `[AGENT-MEMORY-PATH]/agent-[domain]/knowledge-base/[project]/context-index.md` (private).
     - **Localized** (`home: project`): `<project-root>/docs/context-index.md` (shared) + `<project-root>/.agents/knowledge/index.md` (private).
   - **Episodic (localized only)**: if `home: project`, read the repo index `.agents/session/index.md` (authoritative, newest-first); take its **top** entry → read that theme file from `.agents/session/`. **This supersedes** the central episodic the core loaded. **Reachability guard**: if `.agents/session/` is absent at cwd → report *"[project] is localized but not checked out here"* + skip open items.
   - For memory **writes** this session, follow `/localized-memory-workflow`.

4. **Orientation map + fleet roster** — Call `/map-orientation` (bare, load-only) to load the orientation map if it exists — never auto-create. Then read the project's fleet roster `[AGENT-MEMORY-PATH]/shared-memory/[project]/fleet-agents.md` (silently skip if missing) — the team of agents you can consult or hand off to. (The core awakening no longer loads the roster — fleet is an overlay capability.)

5. **Task system check** — match the working directory to its task system and run that project's Awakening Hook: **Todoist** (`aquazone`, `invintiry`) → query `@agent-[my-domain]` + `@waiting-human`; **Jira/Linear** (`plko` / `ocx-platform`, `ocx-data`) → the Awakening Hook section in that project's context. Report counts. No matching project → skip silently.

6. **Augment the core report** — fold these additions into the core's report block:
   - **Current project + orientation map status**: if no map → *"No orientation map for [project] yet — use `/map-orientation create` to scan and create when ready."*
   - **Project context**: if either context-index was found, show a merged numbered list with `[shared]` / `[private]` prefixes; offer to load (auto-loads on relevance). If neither: *"No project context for [project] yet — use `/update-project-context` to capture some."*
   - **Fleet**: if `fleet-agents.md` was found, mention `/ask-agent` + `/delegate-agent` (consult or hand off to a teammate). Else: *"No fleet for this project yet — use `/setup-fleet` to define one."*
   - **Task system**: report the queried counts.
   - **Coding reasoning**: if `coding-reasoning-memory.md` was missing, say so once — those patterns are simply absent this session, not silently substituted.
   - If localized: note that localized episodic/context superseded the central load.

*(Proactive project-context loading — standing behavior for the session: when the task shifts and the **project context** index has a relevant entry (shared `context/context-index.md` · private `knowledge-base/[project]/context-index.md`; localized: `docs/context-index.md` · `.agents/knowledge/index.md`), proactively load it — don't wait to be asked. Load silently, report briefly; never load everything. This is the coding half of Proactive Memory Loading; the general-knowledge + episodic half lives in the core knowledge foundation.)*
