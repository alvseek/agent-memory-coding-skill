# Generate Domain Docs

Generate **domain docs** — Mermaid diagrams of a project's *data / domain structure* — placed per the ADR-004 contract. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md), bare invocation runs **discovery** (lists the project's bounded contexts, documented-vs-not, per the [Doc Discovery Contract](discovery-contract.md)); you then generate one at a time. The scope picks the mode —
- **bare / no arg → discovery** (the context inventory; pick one to deep-dive, or `[M]` for the context-map)
- **`[context]` arg → one domain-model** (the deep-dive: one context's `erDiagram`)
- **`[M]` pick → the domain-context-map** (the whole-system map altitude: how bounded contexts relate)

A domain doc is one of the **atomic doc types**. Its siblings: `/generate-readme` (what a unit *is*), `/generate-flow-docs` (behavior), `/generate-architecture-docs` (component structure). The [`/generate-docs`](generate-docs.md) orchestrator composes them (the cross-lens map surface). See [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md) for the two-altitude model and [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md) for discovery-first.

## Arguments

`$ARGUMENTS`

- `/generate-domain-docs` (bare) → **discovery**: the context inventory (documented / not / trivial-collapsed / `[M]` map). Pick one to deep-dive. → **Step 1D**.
- `/generate-domain-docs [context]` → one **domain-model** ERD (deep-dive altitude). `[context]` is a **module / bounded-context path** (e.g. `src/orders`). → **Step 1B**.
- `[M]` (from the discovery menu) → the **domain-context-map** (map altitude): the whole system's bounded contexts + how they relate. → **Step 1M**.

Bare discovers; you generate one deep-dive at a time. The [`/generate-docs`](generate-docs.md) orchestrator generates the whole-system map of every lens at once (the cross-lens `[M]` pick) — deep-dives still go one at a time.

---

## Procedure

### Step 1: Route by mode

- **Bare / no arg → Discovery**: go to **Step 1D** (the context inventory). Nothing is generated until you pick.
- **`[context]` arg → one domain-model** (deep-dive): go to **Step 1B**, then Steps 2–6.
- **`[M]` pick (from discovery) → domain-context-map**: go to **Step 1M**. Self-contained — Steps 2–6 are the deep-dive and don't apply.

### Step 1D: Discovery (bare)

*Run the bare **discovery** pass per the [Doc Discovery Contract](discovery-contract.md) — list the project's bounded contexts, marked documented-vs-not, and STOP for the human's pick. Discovery generates nothing.*

1. **Scan (unit = a bounded context)**: glob `**/docs/domain/*.md` (existing per-context ERDs → documented) + scan module boundaries for contexts that own entities but aren't yet documented (→ not).
2. **Join status**: mark documented-vs-not from disk; enrich from the orientation map (`MAP_PATH`); a doc on disk absent from the map → `⚠ stale — /map-orientation --rescan` (per the contract).
3. **Relevance floor (cheap signal)**: a context with ≤1 entity → bucket **trivial** (collapsed, overridable); contexts with ≥2 entities + a relationship are listed.
4. **Present the inventory** in the contract's format (✓ documented / ✗ not / ▸ trivial / `[M]` domain-context-map) and STOP for the pick — a `[context]` pick → **Step 1B**; `[M]` → **Step 1M**.

### Step 1M: Domain-context-map (the `[M]` map pick)

*The whole-system view of the domain: how bounded contexts relate — synthesized only when picked (`[M]`), never on bare. Per [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md), a map-altitude content artifact indexed by, but separate from, the orientation map.*

1. **Identify the bounded contexts + readability check**: glob `**/docs/domain/*.md` for existing per-context ERDs; scan module boundaries for contexts not yet documented. **Readability ceiling** (flag-3): if the system has **more than ~15–20 bounded contexts**, STOP and recommend grouping into sub-context-maps (per area / subsystem) rather than one unreadable map — a judgment trigger, not a hard cap (recommend, let [USER-NAME] decide).
2. **Infer the relationships**: how contexts integrate — the DDD patterns: upstream/downstream (U/D), shared kernel, customer/supplier, conformist, anti-corruption layer (ACL), open-host service (OHS). Read cross-context references / imports / shared types. `[CONFIRM]` where the pattern is a design intention code doesn't spell out; `[NOT FOUND]` where an integration is expected but unclear.
3. **Build the diagram**: a Mermaid `flowchart` — contexts as nodes, edges labelled with the DDD pattern + direction.
4. **Place**: root `docs/domain/context-map.md` (project-wide; lives in the project tree per ADR-004).
5. **Fill**: copy [domain-context-map-template.md](//@agent-memory/control-files/templates/domain-context-map-template.md), set `doc_type: domain-context-map`, fill the diagram + contexts + relationships + links to each context's ERD (note contexts lacking one). Fill-from-code, no fiction, typed markers.
6. **Review**: show the map, group markers, state placement, note which contexts still lack a deep-dive ERD. **Done** — skip Steps 2–6.

### Step 1B: Resolve the context (deep-dive)

Use the `[context]` arg as the boundary (a module/context path). If it's ambiguous (a name matching several modules), ask [USER-NAME] which one. Then continue to Step 2.

### Step 2: Extract the data model + readability health-check

**Locate the model source** (adapt to the stack — prefer the ORM/schema as source of truth, use migrations to fill gaps):
- ORM entity classes — TypeORM `@Entity`, Django `models.Model`, SQLAlchemy models, EF Core `DbContext` + entities, Sequelize / Mongoose models
- `schema.prisma`
- Migration files (the authoritative history of the schema)
- Raw SQL DDL (`CREATE TABLE …`)
- **Convention / document-based models** — when there is no ORM: a memory/store system, file-structure conventions, or a config-driven schema. The model is still real; it just isn't persisted in a database. Reconstruct entities + relationships from the **architecture docs + folder structure/conventions**, not from ORM code. (Don't conclude "no data model" just because there's no ORM — a structured store is a domain model.)

**Extract**, bounded to the resolved scope:
- **Entities** + their **key fields** (PK, FKs, and relationship-bearing / identifying fields — NOT every column)
- **Relationships** — foreign keys, ORM associations, join / through tables
- **Cardinality** — 1:1 / 1:N / M:N. 1:1 and 1:N are usually explicit (FK + uniqueness). **M:N**: recognize a join / through table (two FKs, few/no business fields) and collapse it into a single M:N relationship — keep it explicit only if it carries attributes. Mark `[CONFIRM]` when cardinality isn't determinable from code; `[NOT FOUND]` when an expected entity/relationship can't be located.

**Readability health-check**: if the resolved scope yields **more than ~15–20 entities**, STOP and recommend a **per-bounded-context fractal split** (one domain doc per context) rather than one unreadable wall-of-entities diagram — the same principle as `/generate-readme`'s 500-line rule. The threshold is a judgment trigger, not a hard cap: recommend, and let [USER-NAME] decide.

### Step 3: Select the diagram grammar

| Model shape | Grammar |
|---|---|
| Relational / persistence data model (the common case) | `erDiagram` (default) |
| Behavior-rich OO domain (aggregates with methods, inheritance) where behavior matters as much as data | `classDiagram` |

When in doubt, default to `erDiagram`.

### Step 4: Compute placement (LCA)

1. Collect the file paths of the **entity files** in scope.
2. Compute their **nearest existing common ancestor** folder.
3. Target = `[LCA]/docs/domain/{scope-name}.md`.
   - A model contained in one module → LCA = that module → co-located `[module]/docs/domain/`.
   - A model shared across modules → LCA = their nearest common ancestor's `docs/domain/` (data models often sit higher than flows).
4. Use the nearest *existing* ancestor — never invent a parent folder. Create `docs/domain/` at the LCA if it doesn't exist.

> **Placement Contract** (see [ADR-004](//@agent-memory/docs/adr/2026-07-06-docs-placement-contract.md)): **scope = location.** A domain doc lives at the LCA of the entity files it covers — *blast radius, not casual references*. It always lives in the **project's own tree**.

### Step 5: Fill the doc

1. Copy [domain-doc-template.md](//@agent-memory/control-files/templates/domain-doc-template.md) to the target path.
2. Update the `domain:` frontmatter and the `# Domain: …` heading with the scope name. **Keep `doc_type: domain`** — the map keys on it.
3. Remove the Convention preamble block (the blockquote marked "delete after reading").
4. Fill from the extracted model:
   - **Scope / Type / Entities** — the boundary, the chosen grammar + why, entity count + names.
   - **Diagram** — the `erDiagram` (key fields only; collapse pure join tables into M:N).
   - **Entities** — one line per entity (purpose + file), only if names aren't self-explanatory.
   - **Relationships & Invariants** — cardinalities + business rules (uniqueness, cascade, soft-delete, required FKs).
   - **Related** — owning module READMEs, the migrations folder, data-model ADRs.

**Accuracy discipline** (inherited from [generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)): fill from actual code, never invent an entity or relationship. Use `[TODO: ...]` (needs human input), `[CONFIRM: ...]` (found but unverified), `[NOT FOUND: ...]` (expected but missing). An incomplete domain doc is better than a fictional one.

### Step 6: Present for review

Present the domain doc to [USER-NAME]:
- Show the ERD + prose.
- Group outstanding markers by type (`[TODO]` needs input · `[CONFIRM]` needs verification · `[NOT FOUND]` missing from code).
- State the placement (the LCA folder chosen) + whether the health-check recommended a split.
- Ask if anything needs adjustment.

> **Vector export** (optional): extract the fenced Mermaid block to `{scope}.mmd` and run `mmdc -i {scope}.mmd -o {scope}.svg` (or `.pdf`). Prefer SVG/PDF over PNG for dense diagrams.

---

## Integration With Other Procedures

- **[discovery-contract](//@agent-memory/control-files/procedures/discovery-contract.md)** — defines the bare **discovery mode** (Step 1D): inventory format, disk+map status-join, relevance floor, map-as-pick. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md), bare discovers; the context-map is the `[M]` pick, not the bare default.
- **[generate-flow-docs](//@agent-memory/control-files/procedures/generate-flow-docs.md) / [generate-readme](//@agent-memory/control-files/procedures/generate-readme.md)** — sibling atomic doc generators. Same shape: resolve → extract/investigate → fill → review.
- **[map-orientation](//@agent-memory/control-files/procedures/map-orientation.md)** — indexes the deep-dive as `domain-model` (`doc_type: domain`) and the map as `domain-context-map` (`doc_type: domain-context-map`), and supplies the documented-status that Step 1D discovery joins. This skill does **not** run the map — indexing is `/wrap-up` or an explicit `/map-orientation --rescan`.
- **The two altitudes** (see [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md)): the **domain-context-map** is the *map altitude* (how bounded contexts relate); the **domain-model** ERD is the *deep-dive*. Both are content docs, separate from the orientation map (navigation), which indexes them.
- **[`/generate-docs`](generate-docs.md) orchestrator** — composes this generator's `[M]` (context-map) path with the other atomic generators to synthesize the whole-system doc surface. See [ADR-006](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md) + [ADR-009](//@agent-memory/docs/adr/2026-07-09-generate-docs-orchestrator.md).
- **Decision collection** — if Step 1B scope resolution is ambiguous, present the candidates using [wait-options](//@agent-memory/control-files/procedures/wait-options.md).

---

## Anti-Patterns

1. **Inventing entities or relationships.** If the code doesn't show it, it doesn't go in the ERD. `[CONFIRM]` / `[NOT FOUND]`, never fabricate.
2. **Dumping the full schema.** Show key fields (PK/FK + relationship-bearing), not every column. The full schema lives in the migrations/entities the doc links to.
3. **Ignoring the readability health-check.** A 40-entity wall-of-boxes ERD is useless. Above ~15–20, recommend a per-bounded-context split.
4. **Inventing a parent folder for placement.** Use the nearest *existing* common ancestor.
5. **Runtime DB introspection.** Reconstruct from static code (entities / migrations / schema), not a live database.
6. **Auto-running the orientation map.** This skill generates + reports only.
7. **Re-documenting an existing context.** For the deep-dive, update an existing context's ERD rather than regenerating it.
8. **Mixing altitudes.** Don't cram every entity into one ERD, and don't reduce the context-map to a single mega-ERD — the context-map shows *contexts + relationships*, the deep-dive shows one context's *entities*. The mode picks the altitude — a `[context]` deep-dive vs the `[M]` context-map.
9. **Stitching ERDs to fake a map.** The whole-system view is the context-map (the `[M]` pick) — one synthesized artifact of context *relationships*, not N ERDs glued together.
