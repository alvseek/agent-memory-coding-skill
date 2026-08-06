# Generate Architecture Docs

Generate an **architecture doc** — a Mermaid diagram of a project's *component/structure* lens (components, boundaries, how they connect + deploy) wrapped in a short markdown doc — by resolving a scope, synthesizing the structure from static signals, and placing the doc per the ADR-004 contract.

An architecture doc is one of the **atomic doc types**. Its siblings: `/generate-readme` (what a unit *is*), `/generate-flow-docs` (behavior over time), `/generate-domain-docs` (data model). The [`/generate-docs`](generate-docs.md) orchestrator composes them (the cross-lens map surface).

Architecture has **two axes** (per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md)) — and only one needs a discovery menu:
- **Aspect** (cross-cutting concern — CICD, DBMS, auth…) — *name-addressed*, invisible in the folder tree, so **bare invocation runs aspect discovery** (the concern inventory) per the [Doc Discovery Contract](discovery-contract.md).
- **Subsystem** (a module / service / area) — *scope-addressed*: the repo tree is already the menu, so a `[subsystem]` path arg goes straight to an **architecture-overview** (no discovery menu).

The whole-system **architecture-map** is the `[M]` pick from the aspect inventory (not the bare default). See [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md) for the two-altitude + 3-layer model.

## Arguments

`$ARGUMENTS`

- `/generate-architecture-docs` (bare) → **aspect discovery**: the concern inventory (2-layer — aspect → sub-topic; documented / not / `[M]` map). Pick one to generate. → **Step 1D**.
- `/generate-architecture-docs [subsystem]` → an **architecture-overview** of that subsystem (a module / service / bounded area path) — no discovery menu. → **Step 1S**, then Steps 2–6.
- `[M]` (from the aspect inventory) → the whole-system **architecture-map**. → **Step 1M**, then Steps 2–6 at project scope.

One doc per run. Bare discovers; you generate one at a time. The [`/generate-docs`](generate-docs.md) orchestrator generates the whole-system map of every lens at once (the cross-lens `[M]` pick).

---

## Procedure

### Step 1: Route by mode

- **Bare / no arg → aspect discovery**: go to **Step 1D** (the concern inventory). Nothing is generated until you pick.
- **`[subsystem]` path arg → architecture-overview**: go to **Step 1S**, then Steps 2–6. (No discovery menu — the repo tree is the menu.)
- **`[M]` pick (from discovery) → architecture-map**: go to **Step 1M**, then Steps 2–6 at project scope.

### Step 1D: Aspect discovery (bare)

*Run the bare **discovery** pass per the [Doc Discovery Contract](discovery-contract.md) over the **aspect** axis — cross-cutting concerns, which have no folder to see. List them documented-vs-not and STOP for the pick. Discovery generates nothing.*

1. **Seed the aspect checklist (hybrid — ADR-008 Decision 4A)**: start from the standard concerns — **deployment/CICD, persistence/DBMS, auth, caching, messaging, observability, config, API/integration**.
2. **Mark present/absent from signals**: use the same static signals Step 2 reads (`docker-compose` / k8s / `Procfile` → deployment; DB config / ORM → persistence; auth middleware → auth; CI config → CICD; queue/broker → messaging; etc.). Add any **detected-but-unlisted** aspect the signals reveal. An aspect with only a lone config file / no multi-component footprint → bucket **trivial** or "not detected" (collapsed).
3. **Join status**: glob `**/docs/architecture/*.md` for existing aspect docs (documented); enrich from the orientation map (`MAP_PATH`); a doc on disk absent from the map → `⚠ stale — /map-orientation --rescan`.
4. **Present the 2-layer inventory** in the contract's format (✓ / ✗ / ▸ trivial / `[M]` architecture-map). Layer 1 = the aspects; on picking an aspect, present **Layer 2** = its sub-topics (e.g. DBMS → connection · pooling · migrations · patterns). On a sub-topic pick → **Steps 2–6** with that concern's file-set as the scope (`doc_type: architecture-overview`). `[M]` → **Step 1M**.

### Step 1S: Subsystem overview (path arg)

Resolve the `[subsystem]` path as the scope. If the arg is ambiguous (matches several areas), ask [USER-NAME] which one. Filter already-documented scopes: glob `**/docs/architecture/*.md`, read their `scope:` frontmatter / titles, and don't regenerate one that exists (update instead). Altitude = **architecture-overview**. Continue to Step 2.

### Step 1M: Architecture-map (the `[M]` map pick)

The whole-system view — synthesized only when picked (`[M]`), never on bare. Altitude = **architecture-map**, scope = the whole project. Continue to Step 2 (its ~15–20-component readability check applies here).

### Step 2: Synthesize the structure + readability health-check

There is **no single authoritative source** (no entrypoints, no entity classes) — synthesize from the static signals, bounded to the resolved scope:

- **Top-level folders / module boundaries** — the coarse structure (a hint, not the truth).
- **Import / dependency graph** — what actually depends on what (the *real* boundaries; prefer this over folder layout when they disagree).
- **Deployment & service config** — `docker-compose`, k8s manifests, serverless config, `Procfile` — reveals the runtime components + topology.
- **Monorepo workspaces** — `apps/`, `packages/`, workspace manifests.
- **Tech-stack manifests** — `package.json`, `*.csproj`, `requirements.txt`, `go.mod` — per-component stacks.

Identify **components** (services / modules / layers), their **responsibilities**, **boundaries**, and the **dependencies / data-flow between them** (sync vs async, which talks to which DB/queue). Mark inferred boundaries `[CONFIRM]`; missing infra `[NOT FOUND]` (no deployment config → say so, don't invent a topology).

**Readability health-check**: for an architecture-map, if the system has **more than ~15–20 top-level components**, STOP and recommend splitting into per-subsystem `architecture-overview` docs rather than one unreadable map. Judgment trigger, not a hard cap — recommend, let [USER-NAME] decide.

### Step 3: Select the diagram grammar

| Shape | Grammar |
|---|---|
| Component / dependency graph (the common case) | `flowchart` (default) |
| Formal system with clear external actors + containers | `C4Context` / `C4Container` |

Default to `flowchart` unless C4 clearly fits (Mermaid's C4 support is newer/less universal).

### Step 4: Compute placement (LCA)

- **architecture-map** → project root `docs/architecture/{project}.md` (inherently project-wide).
- **architecture-overview** → the subsystem's **LCA** `docs/architecture/{subsystem}.md` (collect the subsystem's file paths → nearest existing common ancestor).

Use the nearest *existing* ancestor — never invent a parent folder. Create `docs/architecture/` at the target if it doesn't exist.

> **Placement Contract** (see [ADR-004](//@agent-memory/docs/adr/2026-07-06-docs-placement-contract.md)): **scope = location.** The doc lives in the **project's own tree** at its LCA.

### Step 5: Fill the doc

1. Copy [architecture-doc-template.md](//@agent-memory/control-files/templates/architecture-doc-template.md) to the target path.
2. Set `doc_type` per altitude (`architecture-map` or `architecture-overview`), update `scope:` + the `# Architecture: …` heading.
3. Remove the Convention preamble block.
4. Fill from the synthesis:
   - **Altitude / Scope / Type / Components** — the altitude, boundary, chosen grammar + why, component count + names.
   - **Diagram** — the `flowchart`/C4 (label edges with *how* components talk; show boundaries).
   - **Components** — responsibility + boundary + location per component.
   - **Dependencies & Boundaries** — how they connect, deployment topology, key cross-boundary contracts (the part only this doc gives).
   - **Related** — subsystem overviews (from a map), module READMEs, relevant flow/domain docs, architecture ADRs.

**Accuracy discipline** (inherited from [generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)): fill from actual structure, never invent a component or a connection. Use `[TODO]` / `[CONFIRM]` / `[NOT FOUND]`. An incomplete architecture doc is better than a fictional one.

### Step 6: Present for review

Present the architecture doc to [USER-NAME]:
- Show the diagram + prose.
- Group outstanding markers by type.
- State the placement, the **altitude** (map vs overview), and whether the health-check recommended a split.
- Ask if anything needs adjustment.

> **Vector export** (optional): extract the fenced Mermaid block to `{scope}.mmd` and run `mmdc -i {scope}.mmd -o {scope}.svg` (or `.pdf`).

---

## Integration With Other Procedures

- **[discovery-contract](//@agent-memory/control-files/procedures/discovery-contract.md)** — defines the bare **aspect discovery mode** (Step 1D): inventory format, disk+map status-join, relevance floor, map-as-pick. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md), bare discovers the aspect axis; the architecture-map is the `[M]` pick and subsystems stay path-addressed.
- **[generate-flow-docs](//@agent-memory/control-files/procedures/generate-flow-docs.md) / [generate-domain-docs](//@agent-memory/control-files/procedures/generate-domain-docs.md) / [generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)** — sibling atomic doc generators. Same shape: resolve → extract/synthesize → fill → review.
- **[map-orientation](//@agent-memory/control-files/procedures/map-orientation.md)** — indexes the generated doc as `architecture-map` or `architecture-overview` (via the `doc_type` frontmatter), and supplies the documented-status that Step 1D discovery joins. This skill does **not** run the map — indexing is `/wrap-up` or an explicit `/map-orientation --rescan`.
- **The 3-layer model** ([ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md)): this doc is a **map-altitude content artifact** — cleanly separate from the *orientation map* (navigation), which indexes it. The orientation map maps *docs*; an architecture-map maps the *system*.
- **[`/generate-docs`](generate-docs.md) orchestrator** — composes this generator's `[M]` (architecture-map) path with the other atomic generators to synthesize the whole-system doc surface. See [ADR-006](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md) + [ADR-009](//@agent-memory/docs/adr/2026-07-09-generate-docs-orchestrator.md).
- **Decision collection** — if Step 1S / Step 1D resolution is ambiguous, present the candidates using [wait-options](//@agent-memory/control-files/procedures/wait-options.md).

---

## Anti-Patterns

1. **Inventing components or connections.** If the structure/config doesn't show it, it doesn't go in the diagram. `[CONFIRM]` / `[NOT FOUND]`, never fabricate.
2. **Mixing altitudes.** A map with class-level internals is unreadable; an overview that's just "here's the whole system" is useless. Map = components; overview = one subsystem's internals.
3. **Listing modules instead of showing relationships.** The value is *how components connect + deploy* — a bare list is what the orientation map + READMEs already give.
4. **Trusting folders over the dependency graph.** Folder layout is a hint; actual imports + deployment are the real boundaries.
5. **Inventing a parent folder for placement.** Use the nearest *existing* common ancestor.
6. **Runtime introspection.** Synthesize from static code/config, not a running system.
7. **Auto-running the orientation map.** Generate + report only.
8. **Re-documenting an existing scope.** The scan filters out documented scopes — update, don't regenerate.
