# agent-memory-coding-skill

The **coding/repo add-on overlay** for the [agent-memory](https://github.com/alvseek/agent-memory-system) framework.

This repo holds every coding- and repository-oriented procedure that sits **on top of** the memory core: wizards, doc generation, QA, project localization, and push/pull. A coding agent installs the memory core **plus** this overlay; a plain chat agent installs the core alone.

## Relationship to the memory core

- **Standalone, independent repo** — a *peer* of the core ([`agent-memory-system`](https://github.com/alvseek/agent-memory-system) / `control-files`). It is **not** a git submodule of the core or of the parent aggregator.
- **One-way dependency**: this overlay references the core; the **core never references this overlay by name** (enforced by the core's `check-core-invariant.sh` guard).
- **Additive composition, not override**: the consuming agent is the composition point. `procedures/awaken-coder.md` simply orchestrates *"run the core `/awaken-agent`, then coding reasoning + localized-home + orientation map + fleet."* Nothing here overrides a core procedure.

## Contents (`procedures/`)

- **Awakening overlay**: `awaken-coder.md` (composes the core awaken), `localized-memory-workflow.md` (repo-authoritative localized memory behavior)
- **Lifecycle**: `project-wrap-up.md` (composes the core `/wrap-up`, then push + map-orientation)
- **Wizards**: `high-wizard`, `quick-wizard`, `council-of-wizards`, `rite-of-creation`, `forge-of-covenant`, `implement-plan`
- **Doc-gen**: `generate-readme`, `generate-docs`, `generate-architecture-docs`, `generate-domain-docs`, `generate-flow-docs`, `discovery-contract`
- **QA**: `analyze-code-quality`, `generate-standard`, `pixel-wizard`, `setup-qa-visual-instrument` — plus the QA instrument pipeline: `map-qa-instrument` (audit) → `build-qa-bench` (build the rig) → `build-qa-test` (build the evergreen tests) → `run-qa-test` (run them), with `generate-qa-checklist` producing the per-feature checklist a wizard hands off at its QA Handoff step
- **Repo / integration**: `map-orientation`, `localize-context`, `update-project-context`, `load-project-context`, `pull-all`/`pull-project`, `push-all`/`push-project`
- **Fleet**: `ask-agent`, `delegate-agent`, `setup-fleet` (+ `fleet-scripts/` and fleet templates) — agent-to-agent consult/delegate via Claude-Code session spawn/resume (a mechanism a chat agent can't use, so it's an overlay capability)

> **`push-memory`/`pull-memory`** live in the memory **core** (moved 2026-08-07) — persisting the memory store is the memory server's own job; the overlay's `push-all`/`pull-all` compose `/push-project` (overlay) + the core's `/push-memory`.

## Setup

This overlay ships its **own** installers (`setup-scripts/`) — it does not depend on the core's installer, and the core's installer does not reach into this repo. Install the **memory core first**, then this overlay:

```bash
# 1. Memory core (agent-memory-system / control-files):
python /path/to/control-files/procedures/setup-scripts/setup-all-claude-code.py

# 2. This overlay:
python setup-scripts/setup-all-claude-code.py
```

On Windows, double-click (or run) `setup-scripts\setup-all-claude-code.bat` — a thin wrapper that finds Python and runs the same installer. Requires Python 3; no other dependencies.

Both target `~/.claude/commands/` but keep **separate manifests** (core = `.agent-memory-manifest`, overlay = `.agent-memory-coding-skill-manifest`), so re-running either one cleans up only its own commands. Codex (`setup-all-codex.sh`) and Antigravity (`setup-all-antigravity.sh`) installers are provided too.

## Status

Extracted from the memory core on **2026-08-06** (Phase 2 of the memory-core / coding-skill decoupling — see [ADR-012](https://github.com/alvseek/agent-memory-system) in the core repo). Wrapping this overlay as a 2nd-layer **MCP server** is the target delivery model but a **separate future project** — this repo is currently the procedure content that such a server will serve.

See [MIGRATION.md](MIGRATION.md) for the move details.
