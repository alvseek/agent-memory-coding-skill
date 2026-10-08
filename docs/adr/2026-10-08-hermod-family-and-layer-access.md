# ADR-020: The Hermod Family and Per-Layer Access Declarations

**Date**: 2026-10-08

**Status**: Accepted

**Extends**: ADR-012 (*Memory Core / Coding-Skill Decoupling*) and the 2026-08-07 boundary plan (*Agent-Memory Ops to Hermod*) in this repo.

---

## Problem

Two gaps meet in one change.

**The fleet sits in the wrong repo.** `ask-agent`, `delegate-agent`, and `setup-fleet` live in the coding overlay (`agent-memory-coding-skill`), but they are neither coding nor memory: they are agent-to-agent orchestration over Claude Code sessions. Sharing a repo with the overlay couples two capabilities that change for different reasons, and it leaves the overlay as the only thing between "the memory core is fleet-free and project-blind" and a fleet that is not.

**A cross-layer handoff cannot be phrased safely under two delivery forms.** A layer's procedures can be *installed* as local commands/skills or *served* as MCP procedures. A pointer that hardcodes a slash command (`/load-fleet`) is correct only under the installed form and breaks under the served one. Today only `[CORE-ACCESS]` exists; the middle layer (coding) and the lower layer (fleet) have no declaration, so a handoff into either has no delivery-agnostic phrasing.

---

## Decision

**We decided to**: split the overlay into a **family** (`hermod-coding` and `hermod-fleet`) and introduce a **per-layer access declaration** that the caller reads.

The overlay becomes `hermod-coding`; the fleet becomes its own peer repo, `agent-memory-fleet` (`hermod-fleet`). `munnin` remains the memory core. The fleet's runtime **data** (`fleet-agents.md`, `fleet-map.csv`) stays in the central store; only the **operations** move. This is the 2026-08-07 "move the operations, leave the data" rule applied a second time.

Each layer declares how it is reached, and the **caller reads the target layer's declaration**:

- `[CORE-ACCESS]` / `[CORE-MCP-URL]`: read by coding and fleet when they call the core (exists).
- `[CODING-ACCESS]` / `[CODING-MCP-URL]`: read by the fleet when it calls coding (new).
- `[FLEET-ACCESS]` / `[FLEET-MCP-URL]`: read by coding when it calls the fleet (new).

The value is `markdown` (installed) or `mcp` (served). A pointer names the **capability**, and the access value picks the invocation form.

**Why we chose this:**
- The fleet's mechanism (spawn and resume Claude Code sessions) is not the overlay's mechanism (compile and install procedures), so they should version and release independently.
- Naming the layer, not the command, is delivery-agnostic: the same pointer text resolves whether the target is installed or served.
- The core already established the pattern with `[CORE-ACCESS]`; this extends it rather than inventing a second one.

---

## What to Build (Requirements)

**Core Requirements:**
- New public repo `agent-memory-fleet`: `procedures/{setup-fleet,load-fleet,ask-agent,delegate-agent}.md`, `fleet-scripts/`, `templates/`, and its own copied-and-adapted compile/install tooling (prefix `agent-fleet-`, placeholder `[path-to-agent-memory-fleet]`).
- `[CODING-ACCESS]`/`[CODING-MCP-URL]` stamped by the overlay installer and `[FLEET-ACCESS]`/`[FLEET-MCP-URL]` by the fleet installer, each per harness and uuid-guarded.
- The overlay loses the fleet files and keeps exactly one pointer: `awaken-coder` names `hermod-fleet` when the project has a roster, resolved through FLEET-ACCESS.
- The fleet's `build_awaken_prompt` reads CODING-ACCESS and instructs `/awaken-coder`, so a spawned agent gets the full coding awakening.
- Every installer's cleanup protects **all** sibling manifests (core, coding, fleet), so no repo's reinstall deletes another's commands.

**Success Criteria:**
- The fleet installs and runs from its own repo on all four harnesses; the overlay tree is fleet-free except the pointer.
- A coding agent awakening in a project with a roster surfaces the `hermod-fleet` pointer; `/load-fleet` lists the roster; `/ask-agent` spawns a coding agent.
- An overlay reinstall leaves the fleet's installed commands intact.
- The core's guard is green and every boundary description names three repos.

---

## Alternatives Rejected

- **Keep the fleet in the overlay**: keeps a session-orchestration capability coupled to a procedures repo that is not its reason to exist.
- **Move the fleet into the core**: the core is project-blind and its invariant forbids it naming addon commands; the fleet is not memory.
- **A pointer naming `/load-fleet` directly**: correct only under an installed overlay; the capability name plus an access rule survives both forms.
- **One central stamper for all access declarations**: reintroduces a shared component every repo must call, which is the coupling the split removes.
- **History-preserving extraction** (`git filter-repo`): unnecessary for a small capability, and the overlay's own extraction used a fresh repo plus a `MIGRATION.md`.

---

**Full context**: [High Wizard plan](../../plans/2026-10-08-agent-memory-fleet-extraction.md)

---
