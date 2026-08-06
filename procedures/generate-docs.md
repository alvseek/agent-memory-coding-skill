# Generate Docs (Orchestrator)

Generate a project's **whole-system documentation surface** in one pass — the **map altitude of all four doc lenses** at once. `/generate-docs` is the **cross-lens `[M]` pick**: it delegates to each atomic generator's map path and assembles a consolidated report. It is **thin and delegation-only** — it owns no scanning or synthesis logic; every map is produced by the lens's own generator.

Per [ADR-006](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md) it composes the atomic generators the way `/wrap-up` composes `/map-orientation` + `/update-memory` (delegation, never embedded logic), and it is built only now that all four parts exist. Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md) the whole-system map survives as a **pick** — and invoking `/generate-docs` **is** that pick, across all lenses. See [ADR-009](//@agent-memory/docs/adr/2026-07-09-generate-docs-orchestrator.md) for the orchestrator decision.

**When to use which:**
- **`/generate-docs`** — the deliberate *"orient me in this whole codebase"* act: synthesize the 4 surface maps. Real synthesis effort, run intentionally.
- **A single `/generate-<lens>-docs`** (bare) — the cheap *incremental* path: discover one lens's documented-vs-not inventory and generate one deep-dive at a time (per the [Doc Discovery Contract](discovery-contract.md)).

## Arguments

`$ARGUMENTS`

- `/generate-docs` (bare) → generate the **4 lens maps** (README → architecture-map → domain-context-map → flow-journey-map), then report. → **Step 1**.

One invocation, one surface. Deep-dives are NOT generated here — the maps enumerate their units and flag what lacks a deep-dive; the developer drills in afterward with the atomic generators (discovery-first preserved).

---

## Procedure

### Step 1: Preflight

1. **Resolve the project root** (the codebase being documented — the current project cwd).
2. **Resolve the orientation-map path** (`MAP_PATH`) via [map-orientation](map-orientation.md)'s Prelude, so each delegated `[M]` run can join documented-status. If no map exists, note it — the maps still generate from disk (per the [Doc Discovery Contract](discovery-contract.md)).
3. **State intent + non-destructiveness**: announce that `/generate-docs` will synthesize the 4 whole-system maps, updating any that already exist **in place** (never clobbering). No deep-dives are generated.

### Step 2: Delegate per lens, in order

For each lens **in this order** — README → architecture → domain → flow (orientation-first, structure before behavior) — **Execute** that generator's map (`[M]`) path. This is delegation, exactly like `/wrap-up`: name the sub-skill + its `[M]` arg and follow that procedure; do **not** reimplement its scan/synthesis logic here.

| Order | Delegate to | Map altitude produced | Typical path |
|---|---|---|---|
| 1 | [generate-readme](generate-readme.md) `[M]` | root 7Q README (README lens map) | `docs/README.md` |
| 2 | [generate-architecture-docs](generate-architecture-docs.md) `[M]` | architecture-map | `docs/architecture/{project}.md` |
| 3 | [generate-domain-docs](generate-domain-docs.md) `[M]` | domain-context-map | `docs/domain/context-map.md` |
| 4 | [generate-flow-docs](generate-flow-docs.md) `[M]` | flow-journey-map | `docs/flows/journey-map.md` |

For each lens, **capture the outcome** for the Step 3 report:

- **generated** — a new map was created.
- **updated** — an existing map was refreshed in place.
- **skipped-empty** — the lens has nothing worth mapping (below the generator's relevance floor: no multi-step flows / ≤1 entity / no multi-component aspect). Record the reason; do **not** force an empty map.
- **ceiling-split-recommended** — the lens exceeded its readability ceiling (~15–20 units; README 500 lines) and the generator recommended a per-area split. Surface the recommendation; move on. Do **not** bulldoze the ceiling into one unreadable map.
- **error / needs-input** — the generator stopped for a `[CONFIRM]`/ambiguity it couldn't resolve. Record it; continue to the next lens (one lens failing must not abort the others).

Run the lenses independently — a skip, ceiling, or error on one does not stop the rest.

### Step 3: Consolidated report

Present one cross-lens summary so the developer sees the whole surface + every gap in one place:

```
Documentation surface for <project> — <G> generated, <U> updated, <S> skipped:

  Lens            Map                              Status                Gaps
  README          docs/README.md                   ✓ generated           —
  Architecture    docs/architecture/<proj>.md      ✓ updated             2 subsystems lack an overview
  Domain          docs/domain/context-map.md       ▸ skipped (≤1 entity) —
  Flow            docs/flows/journey-map.md         ⚠ split recommended   34 flows — recommend per-area journeys

→ Next: drill into any gap with the atomic generator, e.g. `/generate-flow-docs "order checkout"`,
  `/generate-architecture-docs src/orders`, `/generate-domain-docs src/billing`.
→ To index the new maps into the orientation map: `/map-orientation --rescan` (or it happens at `/wrap-up`).
```

Each map's own body already lists which units lack a deep-dive — the "Gaps" column points there, it does not re-enumerate.

### Step 4: No auto-map-orientation

Like the atomic generators, `/generate-docs` **generates + reports only**. It does **not** run the orientation map's write modes. Indexing the new maps is `/wrap-up`'s job or an explicit `/map-orientation --rescan`. The maps carry known `doc_type`s (`7q-readme`, `architecture-map`, `domain-context-map`, `flow-journey-map`) the scanner already recognizes.

---

## Integration With Other Procedures

- **The four atomic generators** — [generate-readme](generate-readme.md) · [generate-architecture-docs](generate-architecture-docs.md) · [generate-domain-docs](generate-domain-docs.md) · [generate-flow-docs](generate-flow-docs.md). `/generate-docs` invokes each one's `[M]` (map) path and nothing else; every lens generator remains fully usable standalone (bare discovery + deep-dive) without this orchestrator.
- **[discovery-contract](discovery-contract.md)** — governs each generator's *bare discovery* mode (the cheap incremental path). `/generate-docs` is the complementary *whole-surface* path; it does not run discovery itself.
- **[map-orientation](map-orientation.md)** — supplies `MAP_PATH` (documented-status join) at preflight; indexes the produced maps later (at `/wrap-up` or `--rescan`). `/generate-docs` never runs its write modes.
- **[wrap-up](wrap-up.md)** — the delegation precedent: `/generate-docs` composes the generators the same way `/wrap-up` composes `/map-orientation` + `/update-memory`.
- **ADRs** — [ADR-006](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md) (atomic-generators-plus-orchestrator), [ADR-007](//@agent-memory/docs/adr/2026-07-08-doc-altitudes-and-three-layer-map-model.md) (the map altitude this synthesizes ×4), [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md) (map-as-a-pick), [ADR-009](//@agent-memory/docs/adr/2026-07-09-generate-docs-orchestrator.md) (this orchestrator = the cross-lens `[M]` pick).

---

## Anti-Patterns

1. **Reimplementing a generator's logic.** `/generate-docs` delegates; it never inlines a lens's scan or synthesis. If you find yourself scanning entrypoints or entities here, stop — call the generator's `[M]` path.
2. **Generating deep-dives.** The orchestrator produces *maps only*. Per-unit deep-dives stay with the atomic generators (discovery-first). A "generate everything including deep-dives" batch was explicitly rejected (ADR-006 `all`-scope, ADR-008 bare mass-generation).
3. **Forcing an empty map.** A lens below its relevance floor is reported as `skipped-empty`, not padded into a fictional near-empty artifact.
4. **Bulldozing the readability ceiling.** If a generator recommends a split (>~15–20 units), surface it — don't override into one unreadable mega-map.
5. **Aborting on one lens's failure.** Lenses run independently; a skip/ceiling/error on one must not stop the others.
6. **Auto-running the orientation map.** Generate + report only; indexing is `/wrap-up` or an explicit `/map-orientation --rescan`.
7. **Clobbering an existing map.** Existing maps update in place (the generators' update-not-regenerate rule), never overwrite-from-scratch.
