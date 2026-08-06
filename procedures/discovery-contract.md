# Doc Discovery Contract

Shared contract for the **bare discovery mode** of the four doc generators (`/generate-readme`, `/generate-flow-docs`, `/generate-domain-docs`, `/generate-architecture-docs`). This file is the single source of truth for *how discovery behaves*; each generator references it and supplies only its **lens-specific unit-scan**. Format, status-join, the relevance floor, and map-as-pick are defined once here so they cannot drift across the four skills.

Per [ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md): bare invocation **discovers** (lists a documented-vs-not inventory) instead of auto-generating; the human then generates one deep-dive at a time. The whole-system map is a pick, not the bare default.

---

## What Discovery Is

Bare `/generate-<lens>-docs` runs a **discovery pass**, not a generation:

1. **Scan disk** for the lens's units (each generator supplies the scan).
2. **Join** the orientation map for documented status.
3. **Apply the relevance floor** (bucket structureless units as collapsed-trivial).
4. **Present the inventory** — documented / not / trivial / `[M]` map pick.
5. **Wait for the human to pick** a unit (or `[M]`). Discovery generates nothing on its own.

Discovery is **cheap**: it lists and marks; it does NOT trace or synthesize each unit (that is the deep-dive's job).

---

## (a) Inventory Output Format

Uniform across all four lenses:

```
<Lens> inventory for <project/scope> — <D> documented, <N> not, <T> trivial:

  ✓ <unit>            <doc-path>
  ✓ <unit>            <doc-path>   ⚠ on disk, not in map — run /map-orientation --rescan
  ✗ <unit>            (<where it lives / the signal that detected it>)
  ✗ <unit>            (<…>)

  ▸ trivial (collapsed): <T> skipped — <one-line reason>. Override to document any.

  [M] whole-system map: <map-doc-path, or "not generated"> — pick to synthesize.

→ pick a unit to deep-dive, or [M] for the map.
```

- **✓ documented** — a deep-dive doc exists on disk for this unit.
- **✗ not documented** — the unit exists in code but has no doc yet; show where it lives / the detecting signal.
- **▸ trivial** — below the relevance floor; collapsed to one line (count + reason), never dropped.
- **`[M]` map** — the whole-system map altitude, offered as a pick (see (d)).
- **⚠ stale-map flag** — a doc exists on disk but the orientation map does not index it (see (b)).

## (b) Status-Join Rule

**Disk is authoritative for existence; the orientation map enriches status.**

1. **Existence** — a unit is *documented* iff a deep-dive doc for it exists on disk (glob the lens's `docs/` folder — `docs/flows/`, `docs/domain/`, `docs/architecture/`, or the README location).
2. **Richer status** — read the orientation map (via the `MAP_PATH` resolved by [map-orientation](map-orientation.md)'s Prelude) for each entry's `status` (useful / stale-but-valuable / unverified) and attach it.
3. **Staleness flag** — if a doc exists on disk but is **absent from the map**, mark it `⚠ on disk, not in map` and suggest `/map-orientation --rescan`. (Discovery is how map staleness surfaces — ADR-008.)
4. **No map** — if `MAP_EXISTS = false`, discovery still works from disk alone; note that the map is missing.

## (c) Relevance Floor

A unit earns a listed (non-collapsed) line only if a deep-dive would reveal **structure that isn't already obvious**. Each generator supplies a **cheap structural signal** (no full trace — that would defeat cheap discovery); units failing it are bucketed **trivial** and collapsed.

- **Cheap, not deep** — decide from light signals (participant / entity / component count, branch presence), never by generating the doc.
- **Collapse, never drop** — trivial units appear as one summarizing line with a count + reason. The human can override and document any of them. (No silent caps — ADR-008.)
- **The floor is the lower bound** — each lens's existing **readability ceiling** (README 500 lines; domain / architecture ~15–20; the map altitudes' equivalent) is the *upper* bound that splits oversized units. Discovery is bounded on both ends.

## (d) Map As a Pick

The whole-system **map altitude** (`flow-journey-map` / `domain-context-map` / `architecture-map`; for README, the project `docs/README.md`) is offered as the `[M]` inventory item — **never auto-synthesized on bare**. Picking `[M]` runs the map synthesis that the generator relocated out of bare. (Supersedes ADR-007's bare→map default.)

## (e) Discovery Is a Proposal

The inventory is a **best-guess the human confirms**, not a mechanical truth. Where the code is explicit (flow entrypoints, ORM entities) discovery is mechanical; where it isn't (bounded contexts without an ORM, cross-cutting aspects) it is judgment. Present the menu; let the human correct it **before** any deep-dive runs.

---

## What Each Generator Supplies (the lens plug-in)

This contract fixes the shared behavior; each generator defines its lens-specific slots:

| Slot | Provided by the generator |
|---|---|
| **Unit** | what one documentable thing is at this lens |
| **Disk scan** | how to find existing docs (glob) + undocumented units (signal scan) |
| **Cheap relevance signal** | the light structural test for the floor |
| **Map pick** | which map-altitude artifact `[M]` synthesizes |

Reference values (the authoritative list lives in each generator + the [doc-generation family ADRs](//@agent-memory/docs/adr/2026-07-07-doc-generation-family-architecture.md)):

| Lens | Unit | Disk scan | Cheap relevance floor | `[M]` map |
|---|---|---|---|---|
| Flow | a flow (traced behavior) | glob `**/docs/flows/*.md` + light-scan entrypoints | handler in ~1 file / ≤2 calls / no branch | `flow-journey-map` |
| Domain | a bounded context | glob `**/docs/domain/*.md` + scan modules owning entities | ≤1 entity | `domain-context-map` |
| Architecture (aspect) | an architectural concern | seed the aspect checklist + mark from signals | lone config / no multi-component → "not detected" | `architecture-map` |
| README | a documentable scope | glob README locations + scan module folders | empty / trivial module | project `docs/README.md` |

> **Architecture note**: the **aspect** axis is name-addressed and uses this discovery menu (bare). The **subsystem** axis is scope-addressed — a folder path, with **no discovery menu** (the repo tree is the menu). See [generate-architecture-docs](generate-architecture-docs.md).

---

## How a Generator Uses This Contract

In each generator's **Step 1 routing**:

- **Bare (no arg)** → **Discovery**: run the 5-step pass above with the lens's unit-scan + relevance signal, present the inventory, and STOP for the human's pick.
- **`[unit]` arg** → **deep-dive** (the generator's existing Steps 2–6).
- **`[M]` pick** → the generator's **map synthesis** (its former bare-map path).

Discovery does NOT run the orientation map's write modes and does NOT generate anything — it lists, marks, and waits.

---

## Integration

- **[map-orientation](map-orientation.md)** — supplies documented-status (`MAP_PATH`, per-entry `status`). Discovery reads it; a disk/map mismatch flags a stale map.
- **The four generators** — reference this contract for their bare discovery mode.
- **[ADR-008](//@agent-memory/docs/adr/2026-07-09-discovery-first-generation.md)** — the decision this contract implements.
