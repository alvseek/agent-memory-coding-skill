# Generate Flow Docs

Generate **flow docs** — Mermaid diagrams of a project's *behavior* — placed per the ADR-004 contract. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md), bare invocation runs **discovery** (lists the project's flows, documented-vs-not, per the [Doc Discovery Contract](discovery-contract.md)); you then generate one at a time. The scope picks the mode —
- **bare / no arg → discovery** (the flow inventory; pick one to deep-dive, or `[M]` for the journey-map)
- **`[flow]` arg → one flow-diagram** (the deep-dive: one flow's sequence over time)
- **`[M]` pick → the flow-journey-map** (the whole-system map altitude: how flows chain into journeys)

A flow doc is one of the **atomic doc types**. Its siblings: `/generate-readme` (what a unit *is*), `/generate-domain-docs` (data model), `/generate-architecture-docs` (component structure). The [`/generate-docs`](generate-docs.md) orchestrator composes them (the cross-lens map surface). See [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md) for the two-altitude model and [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md) for discovery-first.

## Arguments

`$ARGUMENTS`

- `/generate-flow-docs` (bare) → **discovery**: the flow inventory (documented / not / trivial-collapsed / `[M]` map). Pick one to deep-dive. → **Step 1D**.
- `/generate-flow-docs [flow]` → one **flow-diagram** (deep-dive altitude). `[flow]` is a **flow name** ("order checkout") or an **entrypoint reference** (route, handler, cron job, consumer, CLI command). → **Step 1B**.
- `[M]` (from the discovery menu) → the **flow-journey-map** (map altitude): the whole system's flows + how they chain. → **Step 1M**.

Bare discovers; you generate one deep-dive at a time. The [`/generate-docs`](generate-docs.md) orchestrator generates the whole-system map of every lens at once (the cross-lens `[M]` pick) — deep-dives still go one at a time.

---

## Procedure

### Step 1: Route by mode

- **Bare / no arg → Discovery**: go to **Step 1D** (the flow inventory). Nothing is generated until you pick.
- **`[flow]` arg → one flow-diagram** (deep-dive): go to **Step 1B**, then Steps 2–6.
- **`[M]` pick (from discovery) → flow-journey-map**: go to **Step 1M**. Self-contained — Steps 2–6 are the deep-dive and don't apply.

### Step 1D: Discovery (bare)

*Run the bare **discovery** pass per the [Doc Discovery Contract](discovery-contract.md) — list the project's flows, marked documented-vs-not, and STOP for the human's pick. Discovery generates nothing.*

1. **Scan (unit = a flow)**: glob `**/docs/flows/*.md` (existing flow-diagram docs → documented) + light-scan entrypoints (routes / cron / consumers / CLI / UI handlers) for flows not yet documented (→ not).
2. **Join status**: mark documented-vs-not from disk; enrich from the orientation map (`MAP_PATH`); a doc on disk absent from the map → `⚠ stale — /map-orientation --rescan` (per the contract).
3. **Relevance floor (cheap signal)**: a flow whose entrypoint handler is confined to ~1 file / ≤2 calls / no branch → bucket **trivial** (collapsed, overridable); multi-participant / branching / external-call flows are listed.
4. **Present the inventory** in the contract's format (✓ documented / ✗ not / ▸ trivial / `[M]` flow-journey-map) and STOP for the pick — a `[flow]` pick → **Step 1B**; `[M]` → **Step 1M**.

### Step 1M: Flow-journey-map (the `[M]` map pick)

*The whole-system view of behavior: how flows chain into journeys — synthesized only when picked (`[M]`), never on bare. Per [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md), a map-altitude content artifact indexed by, but separate from, the orientation map.*

1. **Discover the flows + readability check**: glob `**/docs/flows/*.md` + light-scan entrypoints for undocumented flows. **Readability ceiling** (flag-3): if the system has **more than ~15–20 flows**, STOP and recommend grouping into named sub-journeys / per-area journey sub-maps rather than one unreadable map — a judgment trigger, not a hard cap (recommend, let [USER-NAME] decide).
2. **Infer the chains**: how one flow's outcome hands off to the next — an emitted event another flow consumes, a success redirect into another entrypoint, shared state. `[CONFIRM]` inferred chains; `[NOT FOUND]` where a handoff is expected but unclear.
3. **Build the diagram**: a Mermaid `flowchart` — flows as nodes, edges labelled with the handoff (`then` / `triggers` / `emits …`).
4. **Place**: root `docs/flows/journey-map.md` (project-wide; lives in the project tree per ADR-004).
5. **Fill**: copy [flow-journey-map-template.md](//@agent-memory/control-files/templates/flow-journey-map-template.md), set `doc_type: flow-journey-map`, fill the diagram + named journeys + links to each flow's deep-dive (note flows lacking one). Fill-from-code, no fiction, typed markers.
6. **Review**: show the map, group markers, state placement, note which flows still lack a deep-dive doc. **Done** — skip Steps 2–6.

### Step 1B: Resolve the target flow (deep-dive)

1. Resolve the `[flow]` arg to a concrete **entrypoint** — the seed the flow starts from. Search for the matching route / controller / handler / cron job / consumer / CLI command.
2. If the arg matches more than one plausible entrypoint, STOP and ask [USER-NAME] which one (verify first — a flow doc traced from the wrong seed is wasted work).

Then continue to Step 2.

### Step 2: Trace the flow

From the resolved entrypoint, follow the call path across files to reconstruct what actually happens:

- **Participants** — the actors, modules, services, and externals the flow passes through (e.g. Client, API controller, a service class, Postgres, a third-party API).
- **Ordered steps** — the sequence of calls, in order.
- **Branches** — conditionals / error paths → become `alt` / `else` blocks.
- **Loops** — iteration → `loop` blocks.
- **External calls** — DB queries, HTTP calls, queue publishes, cache reads.
- **Async boundaries** — fire-and-forget, awaited calls, queued handoffs.

**Bound the trace**: follow the path to a reasonable depth and STOP at external boundaries (third-party APIs, the DB, the queue). Do not recurse into library internals. Where a branch or handler is unclear, mark it `[CONFIRM: ...]`; where an expected handler can't be located, mark it `[NOT FOUND: ...]`. Never invent a step.

### Step 3: Select the diagram type

Pick the Mermaid grammar that fits the traced shape:

| Shape | Grammar |
|---|---|
| Multiple participants interacting over time (the common case) | `sequenceDiagram` (default) |
| Single actor, branch-heavy decision logic | `flowchart` |
| An entity moving through a lifecycle of states | `stateDiagram-v2` |

When in doubt, default to `sequenceDiagram`.

### Step 4: Compute placement (LCA)

1. Collect the file paths of every **code participant** the flow runs through (exclude externals like third-party APIs).
2. Compute their **nearest existing common ancestor** folder.
3. Target = `[LCA]/docs/flows/{flow-name}.md`.
   - A flow contained in one module → LCA = that module → co-located `[module]/docs/flows/`.
   - A flow spanning modules → LCA = their nearest common ancestor's `docs/flows/`.
4. Use the nearest *existing* ancestor — never invent a parent folder. If `docs/flows/` doesn't exist at the LCA, create it there.

> **Placement Contract** (see [ADR-004](//@agent-memory/docs/adr/2026-07-06-docs-placement-contract.md)): **scope = location.** A flow doc lives at the LCA of the files it runs through — measured by *blast radius, not casual references* (only files the flow actually executes through count). A flow doc always lives in the **project's own tree** at its LCA; ADR-005 localization only governs where the orientation map that later indexes it lives, not the doc.

### Step 5: Fill the doc

1. Copy [flow-doc-template.md](//@agent-memory/control-files/templates/flow-doc-template.md) to the target path.
2. Update the `flow:` frontmatter and the `# Flow: ...` heading with the flow's name. **Keep `doc_type: flow`** — the orientation map keys on it.
3. Remove the Convention preamble block (the blockquote marked "delete after reading").
4. Fill from the trace:
   - **Trigger** — what starts the flow (the entrypoint).
   - **Type** — the chosen grammar + one line on why.
   - **Participants** — the list from Step 2.
   - **Diagram** — the Mermaid diagram. Honor the **alt-block rule**: a participant activated before an `alt` stays active through all branches; deactivate after `end`, never inside a branch.
   - **Steps** — only if the diagram alone isn't self-explanatory.
   - **Preconditions & Notes** — preconditions, branch/error paths, external deps.
   - **Related** — links to the crossed modules' READMEs, sibling flows, relevant ADRs.

**Accuracy discipline** (inherited from [generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)): fill from actual code, never invent. Use `[TODO: ...]` (needs human input), `[CONFIRM: ...]` (found but unverified), `[NOT FOUND: ...]` (expected but missing). An incomplete flow doc is better than a fictional one.

### Step 6: Present for review

Present the flow doc to [USER-NAME]:
- Show the diagram + prose.
- Group outstanding markers by type (`[TODO]` needs input · `[CONFIRM]` needs verification · `[NOT FOUND]` missing from code).
- State the placement (the LCA folder chosen) so [USER-NAME] can confirm it.
- Ask if anything needs adjustment.

> **Vector export** (optional): to produce a sharable image, extract the fenced Mermaid block to `{flow}.mmd` and run `mmdc -i {flow}.mmd -o {flow}.svg` (or `.pdf`). Prefer SVG/PDF over PNG for dense diagrams.

---

## Integration With Other Procedures

- **[discovery-contract](//@agent-memory/control-files/procedures/discovery-contract.md)** — defines the bare **discovery mode** (Step 1D): inventory format, disk+map status-join, relevance floor, map-as-pick. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md), bare discovers; the journey-map is the `[M]` pick, not the bare default.
- **[generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)** — sibling atomic doc generator (7Q README). Same shape: resolve → investigate → fill → review.
- **[map-orientation](//@agent-memory/control-files/procedures/map-orientation.md)** — indexes the deep-dive as `flow-diagram` (`doc_type: flow`) and the map as `flow-journey-map` (`doc_type: flow-journey-map`), and supplies the documented-status that Step 1D discovery joins. This skill does **not** run the map itself — indexing happens at `/wrap-up` or an explicit `/map-orientation --rescan`.
- **The two altitudes** (see [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md)): the **flow-journey-map** is the *map altitude* (a content map of how flows relate); the **flow-diagram** is the *deep-dive*. Both are content docs, separate from the orientation map (navigation), which indexes them.
- **[`/generate-docs`](generate-docs.md) orchestrator** — composes this generator's `[M]` (journey-map) path with the sibling generators to synthesize the whole-system doc surface. See [ADR-006](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md) + [ADR-009](//@agent-memory/docs/adr/2026-07-09-generate-docs-orchestrator.md).
- **Decision collection** — if Step 1B resolution is ambiguous, present the candidates using [wait-options](//@agent-memory/control-files/procedures/wait-options.md).

---

## Anti-Patterns

1. **Inventing steps.** If the code doesn't show it, it doesn't go in the diagram. Use `[CONFIRM]` / `[NOT FOUND]`, never fabricate a path.
2. **Unbounded tracing.** Following the call path into library internals or across every transitive dependency produces noise. Stop at external boundaries.
3. **Inventing a parent folder for placement.** Use the nearest *existing* common ancestor. Don't fabricate a `/flows/` root or a `/software/` parent.
4. **Auto-running the orientation map.** This skill generates + reports only. Indexing is `/wrap-up`'s or an explicit `/map-orientation`'s job.
5. **Re-documenting an existing flow.** For the deep-dive, update an existing flow doc rather than regenerating it.
6. **Mixing altitudes.** Don't put one flow's step-by-step internals into the journey-map (that's the deep-dive), and don't cram every flow into one deep-dive (that's the map). The mode picks the altitude — a `[flow]` deep-dive vs the `[M]` journey-map.
7. **Stitching deep-dives to fake a map.** The whole-system view is the journey-map (the `[M]` pick) — one synthesized artifact, not N flow-diagrams glued together.
