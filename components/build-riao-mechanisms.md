# Build R/I/A/O Mechanisms

The per-phase scaffold recipes for `/build-qa-bench` **Step 5**. Run a recipe when a phase is graded `missing` and its mechanism must be created from scratch. Each recipe is **technology-agnostic** — the shape holds across stacks; the commands are project-specific (stub them with a single `TODO:`).

## Shared discipline (every recipe)

- **Loop engine only** — you're building `scripts` / `seeds` / `config`, never docs, checklists, or fixtures (the map links those).
- **One mechanism per phase**, then **link it** in the `qa/README.md` R/I/A/O table's Mechanism cell — that link is how `/run-qa-test` resolves the phase.
- **Build in loop order** — RESET → INJECT → ACT → OBSERVE — because each phase's output is the next phase's precondition.
- **Stub, don't guess** — where a project specific is unknown, leave one `TODO:` line rather than invent it.
- **QA-scoped + idempotent** — a mechanism must be safe to run twice and physically unable to touch a prod/shared store.

Each recipe below has the same four beats: **Find → Build → Needs → Done when** (the "Done when" is exactly what Step 6 self-smokes).

---

## RESET — back to a known-clean baseline

*Goal: one command returns the system to an identical baseline, so every run starts the same.*

- **Find** — every place state lives: databases, caches, message queues, container volumes, uploaded files, installed app data. RESET must clear **all** of them, or residue leaks between runs.
- **Build** — a script that tears down and recreates the clean baseline. Common shapes: `compose down -v` then `up` (containers + volumes); drop + recreate schema; flush cache; wipe + re-init app storage. Guard it so it can only hit the QA stores.
- **Needs** — the config that names the QA stores (connection strings, container/project name).
- **Done when** — the stores exist and are empty/baseline; nothing from a prior run remains. This is the state INJECT fills.

---

## INJECT — realistic data into the clean state

*Goal: load the data the system needs to behave realistically, on top of RESET's baseline.*

- **Find** — the **seed strategy** the map/README recorded: `prod-snapshot` / `dummy` / `hybrid` / `none`. It decides the mechanism.
- **Build** —
  - `prod-snapshot` → a restore script loading the `.bak` / `.sql` / dump from `qa/seeds/` into the reset stores.
  - `dummy` → a generator/factory/seed script that creates the baseline entities deterministically.
  - `hybrid` → both: restore reference data, generate transactional.
  - `none` → no mechanism; mark the INJECT row `—` and move on.
- **Needs** — RESET already ran (clean target); the seed source in `qa/seeds/`; config for the load (credentials).
- **Done when** — a known baseline entity is queryable in the store — the data ACT's scenarios assume is present.

---

## ACT — bring the system up and exercise it

*Goal: start the system the way it really runs, so scenarios can drive it.*

- **Find** — how the app is launched: a server process, `compose up` for the app tier, or (native/desktop apps) "start dependencies + launch from the IDE." Note which parts are scriptable vs. inherently manual.
- **Build** — a start script for everything ACT can automate (dependencies, servers). For an inherently-manual launch (a desktop/mobile app started by hand), the mechanism is the **documented launch step** plus the scriptable prep around it — say which is which; never label a manual launch as scripted.
- **Needs** — INJECT done (data present); **config switched to local** (the config category's local↔deploy swap) so ACT hits the QA stores, not prod.
- **Done when** — the system is up and the entry point OBSERVE will check responds.

---

## OBSERVE — confirm what happened

*Goal: a mechanism that tells pass from fail at the loop level — is the system alive and in the expected state after ACT.*

- **Find** — the cheapest reliable health signal: a health endpoint, a "services reachable" probe, a smoke query, a known log line.
- **Build** — a smoke script that asserts those signals and **exits non-zero on failure**. Keep it to loop-level invariants ("SQL Server + MySQL + Dolibarr reachable"), **not** per-feature assertions — those are the tests, authored per feature.
- **Needs** — ACT done (system up).
- **Done when** — the script runs green against a healthy stack and red against a broken one — the signal `/run-qa-test` and the daily loop rely on.

---

*After all four: every `missing` row in the R/I/A/O table now links a real script, and Step 6 self-smokes each "Done when" before any Status flips to `documented`.*
