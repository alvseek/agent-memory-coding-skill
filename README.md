# agent-memory-coding-skill

The **coding/repo add-on overlay** for the [agent-memory](https://github.com/alvseek/agent-memory-system) framework.

This repo holds every coding- and repository-oriented procedure that sits **on top of** the memory core: wizards, doc generation, QA, project localization, and push/pull. A coding agent installs the memory core **plus** this overlay; a plain chat agent installs the core alone.

## Relationship to the memory core

- **Standalone, independent repo** — a *peer* of the core ([`agent-memory-system`](https://github.com/alvseek/agent-memory-system) / `control-files`). It is **not** a git submodule of the core or of the parent aggregator.
- **One-way dependency**: this overlay references the core; the **core never references this overlay by name** (enforced by the core's `check-core-invariant.sh` guard).
- **Additive composition, not override**: the consuming agent is the composition point. `procedures/awaken-coder.md` simply orchestrates *"run the core `/awaken-agent`, then localized-home + orientation map + fleet."* Nothing here overrides a core procedure.

## Contents (`procedures/`)

- **Awakening overlay**: `awaken-coder.md` (composes the core awaken), `localized-memory-workflow.md` (repo-authoritative localized memory behavior)
- **Lifecycle**: `project-wrap-up.md` (composes the core `/wrap-up`, then push + map-orientation)
- **Wizards**: `high-wizard`, `quick-wizard`, `council-of-wizards`, `rite-of-creation`, `forge-of-covenant`, `implement-plan`
- **Doc-gen**: `generate-readme`, `generate-docs`, `generate-architecture-docs`, `generate-domain-docs`, `generate-flow-docs`, `discovery-contract`
- **QA**: `analyze-code-quality`, `generate-standard`, `integration-test`, `setup-qa-instrument`, `setup-qa-visual-instrument`, `pixel-wizard`
- **Repo / integration**: `map-orientation`, `localize-context`, `pull-all`/`pull-project`, `push-all`/`push-project`/`push-agent-work`, `push-exclude-policy`

> **Fleet** (`ask-agent`, `delegate-agent`, `setup-fleet` + their scripts/templates) moved to the memory **core** on 2026-08-07 — agent-to-agent orchestration operates on core entities (awakening + agent identity), so it belongs with the core, not this overlay. `awaken-coder` still surfaces the fleet at awakening by composing the core's fleet commands. Likewise **`push-memory`/`pull-memory`** moved to the core the same day — persisting the memory store is the memory server's own job; the overlay's `push-all`/`pull-all` compose `/push-project` (overlay) + the core's `/push-memory`.

## Setup

This overlay ships its **own** installers (`setup-scripts/`) — it does not depend on the core's installer, and the core's installer does not reach into this repo. Install the **memory core first**, then this overlay:

```bash
# 1. Memory core (agent-memory-system / control-files):
bash /path/to/control-files/procedures/setup-scripts/setup-all-claude-code.sh

# 2. This overlay:
bash setup-scripts/setup-all-claude-code.sh
```

Both target `~/.claude/commands/` but keep **separate manifests** (core = `.agent-memory-manifest`, overlay = `.agent-memory-coding-skill-manifest`), so re-running either one cleans up only its own commands. Codex (`setup-all-codex.sh`) and Antigravity (`setup-all-antigravity.sh`) installers are provided too.

## Status

Extracted from the memory core on **2026-08-06** (Phase 2 of the memory-core / coding-skill decoupling — see [ADR-012](https://github.com/alvseek/agent-memory-system) in the core repo). Wrapping this overlay as a 2nd-layer **MCP server** is the target delivery model but a **separate future project** — this repo is currently the procedure content that such a server will serve.

See [MIGRATION.md](MIGRATION.md) for the move details.
