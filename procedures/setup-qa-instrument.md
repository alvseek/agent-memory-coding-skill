# Setup QA Instrument

Establish a reliable QA feedback loop for a project. Investigates the project's existing reset/inject/act/observe pieces, identifies gaps, then codifies them into 6 artifact types: **runbook(s)** (per-module how-to-run), **run-script framework** (R/I/A/O scripts), **fixtures** (composable per-stage precondition-builders), **playbook** (cross-module orchestration + end-to-end scenarios), **checklist(s)** (per-feature verification), and **config templates**. Works across any stack — the loop is universal, the implementations are project-specific.

> **Artifact ontology (runbook vs playbook vs checklist vs fixture)** — distinct tiers, each named per the SRE/ops convention:
> - **Runbook** (`qa/runbooks/{module}.md`) — the operational how-to for **one module**: preconditions, launch, reset/inject/act/observe for that module, config-switching, gotchas. Evergreen. Atomic.
> - **Playbook** (`qa/playbook.md`) — the **cross-module** strategy layer: connection map, full-system boot order, full-system smoke, and end-to-end scenarios that span modules. *References* the runbooks. Evergreen.
> - **Checklist** (`qa/checklists/{feature}.md` → `completed/`) — **per-feature** manual verification tied to a specific shipped change. Ephemeral; archived on sign-off.
> - **Fixture** (`qa/fixtures/{stage}.*`) — a **per-stage precondition-builder** that cheaply reproduces the end-state of one flow stage ("as if create-order completed"), so `/integration-test` Tactic B can reach a deep precondition without paying the full e2e cost for every upstream stage. Composable (each fixture feeds the next stage) and **fidelity-bound** (must mirror what the real stage writes). Built per-flow when needed, like checklists — not up front.

> *Output (`qa/` folder) is consumed by /integration-test — the runtime verification procedure — invoked from the **Final Integration Test** step in /high-wizard (Step 17), /quick-wizard (Step 8), and /pixel-wizard (Step 19), or standalone for ad-hoc runtime checks.*

## The Universal QA Loop

Every QA setup, regardless of stack, is a single feedback loop:

```
RESET → INJECT → ACT → OBSERVE
```

- **RESET** — back to a known clean state (drop DBs, clear caches, uninstall APK, `compose down -v`)
- **INJECT** — get realistic-but-safe data in (fixtures, prod snapshots, seed scripts, generators)
- **ACT** — exercise the system the way users do (run app, click flows, send requests)
- **OBSERVE** — see what happened (logs, asserts, screenshots, traces, manual inspection)

This loop is the conceptual lens. The 4 artifact templates are what gets generated to implement and document it.

Target folder: `./qa/`. If it already exists with content, ask [USER-NAME] before overwriting — "QA folder already exists. Overwrite, merge gap-fill, or pick a different location?"

---

## Procedure

### Step 1: Detect Environment

Search the project for existing R/I/A/O pieces and project-shape signals. Run Glob + Read in parallel:

| Signal | What it tells you |
|---|---|
| `.gitmodules` | Aggregate-with-submodules shape |
| `package.json` with `workspaces` field | Monorepo workspace |
| `docker-compose.yml` / `compose.yml` | Existing orchestration |
| `Makefile` / `Justfile` / `Taskfile.yml` | Existing run-script framework |
| `package.json` `scripts` field with `dev`/`start`/`test` | npm/pnpm run convention |
| `.env*` files (excluding `.env.production`) | Existing env-template convention |
| `Web.*.config` / `App.*.config` | .NET XML transform convention |
| `manage.py` + `settings_*.py` / `fixtures/` | Django convention |
| `Dockerfile` per submodule | Likely needs per-component orchestration |
| `*.csproj` / `*.sln` | .NET project — likely PowerShell scripts, Web.config |
| `*.unity` files / `ProjectSettings/` | Unity — emulator/device-based ACT |

Report findings briefly — one line per detected signal.

### Step 2: Map the R/I/A/O Loop (THE POWERFUL STEP)

For each of the 4 phases, classify what was found:

| Phase | Categories |
|---|---|
| RESET | `exists & documented` / `exists but tribal` / `missing` |
| INJECT | `exists & documented` / `exists but tribal` / `missing` |
| ACT | `exists & documented` / `exists but tribal` / `missing` |
| OBSERVE | `exists & documented` / `exists but tribal` / `missing` |

Present a 4-row table to [USER-NAME] showing **what was detected** vs **what's likely tribal** vs **what's missing**. For each tribal/missing phase, ask:

- RESET missing → "How do you currently get back to a known clean state? (or do you not, today?)"
- INJECT missing → "Where does realistic test data come from? (fixtures / prod snapshot / generator / none)"
- ACT missing → "How do you exercise the system locally? (which command, which UI flow)"
- OBSERVE missing → "How do you confirm something worked or broke? (logs / UI / asserts / smoke checks)"

This step is the highest-value step. **It makes implicit tribal knowledge visible BEFORE generating any files.** Don't skip it.

### Step 3: Inventory Required Config & Secrets

Many projects need external config (API keys, OAuth tokens, DB URLs, cloud credentials) just to start. Identifying these UP FRONT prevents the painful "I tried to start and it crashed with 'AUTH_TOKEN not set'" loop.

**Scan sources** (run Grep in parallel across these patterns):
- `.env.example` / `.env.template` / `env.sample` files
- `os.environ.get(...)` / `os.getenv(...)` in Python
- `process.env.X` in JS/TS
- `Configuration["X"]` / `IConfiguration` in .NET
- `ConfigurationManager.AppSettings["X"]` in .NET Framework
- `Web.config` `<appSettings>` and `<connectionStrings>`
- Config keys mentioned in README / docs

**Classify each discovered config key** as:

| Status | Meaning |
|---|---|
| `exists & documented` | Value is in `.env.example` (or similar) AND [USER-NAME] confirms it's accessible |
| `tribal` | Value lives in someone's local machine / password manager but not documented |
| `missing` | Value isn't anywhere yet — needs acquisition (sign up for API key, request access, etc.) |

For each `missing` item, ask [USER-NAME] what the **acquisition step** is (e.g., "sign up at resend.com, free tier", "request prod DB read-replica access from ops"). Capture as a note for the runbook.

For each `tribal` item, ask if [USER-NAME] wants to document it now or defer. Tribal config is a future-trap.

**Output**: feeds into Template 5's `REQUIRED.md` inventory file.

### Step 4: Choose Seed Strategy

Seed strategy is an **honest cost/benefit choice**, not a dogma. Dummy seed is always ideal in principle — deterministic, fast, no prod dependency, no PII risk. But for projects with already-large connected-data schemas, building dummy fixtures can cost 10x the bug-fix time it was meant to support. *Match the strategy to the project's seed-burden reality.*

Present options:

**A) Dummy seed** (fixtures / factories / generators)
- Pros: deterministic, fast, no prod access needed, no PII risk
- Cons: must keep schema-in-sync with prod; cost scales with schema complexity
- Best when: small/medium schema, rapidly evolving, low connected-data complexity

**B) Prod snapshot** (anonymized export of prod DB)
- Pros: trivially matches prod shape; no dummy-data maintenance burden
- Cons: requires prod access; needs anonymization for PII/secrets; refresh cadence matters
- Best when: large connected-data schemas where dummy seed would take 10x the bug-fix time (Aquazone-shape: 100+ tables, multi-tenant, reference data sprawl)

**C) Hybrid** (dummy for core/transactional, prod-derived for reference/lookup)
- Pros: balance — anonymize only the small reference set, generate the rest
- Cons: more pieces to maintain
- Best when: clear split between user/transactional data (dummy) and reference data (prod-like)

**D) None needed** (system has no persistent seeded data)
- Best when: stateless apps, in-memory tests only

**Guidance baked in**: Don't force dummy when prod-snapshot is honestly simpler. Don't bypass dummy when the schema is small enough. The wrong choice creates either rotting fixtures (option A misapplied) or constant prod-dependency friction (option B misapplied).

The chosen strategy influences:
- Which seed scripts get generated in Template 2 (`seed-fixtures.*` vs `seed-from-snapshot.*` vs both)
- What `REQUIRED.md` lists (option B adds prod-DB-access credentials as required config)
- What the runbook documents under "Inject → Realistic Data" in Template 1

### Step 5: Identify Modules and Connections (Playbook Scope)

Ask:

1. **Which modules need their own runbook?** Free text, one per line. Examples: `web`, `middleware`, `api`, `mobile`, `bff`, `worker`.
2. **How do they connect?** Pick from:
   - A) Aggregate with git submodules (each module = own repo)
   - B) Monorepo workspace (npm/pnpm/Cargo/Go workspaces)
   - C) Single-app single-repo (one runbook only — skip the cross-module playbook)
   - D) Bridge to external systems (focus the runbook on the bridge contract)

The answer drives whether Template 3 (Playbook) gets generated and what shape it takes. A multi-module answer (A/B/D) means the cross-module **playbook** is warranted; a single-app answer (C) means the runbook alone carries the whole story.

### Step 6: Choose Runtime + Shell (No Defaults)

Ask:

1. **Orchestration tool**: `docker-compose` / `Makefile` / `Justfile` / `npm scripts` / `plain shell scripts` / `mix — describe` / `none needed (just app processes)`
2. **Shell for scripts**: `bash (.sh)` / `PowerShell (.ps1)` / `cmd (.bat)` / `cross-platform (generate both .sh and .ps1)`

Do NOT default to any shell. Use [USER-NAME]'s explicit answer. If the project has existing scripts of one type detected in Step 1, mention that as the suggested default but still ask.

### Step 7: Generate the Templates

Generate **only** the templates that fill identified gaps from Steps 2–4. If a phase already exists & is documented, don't regenerate it — extend or link to it instead.

#### Template 1 — Runbook (one per module from Step 5)

File: `qa/runbooks/{module}.md`

Content shape (an operational how-to — NOT a 7Q README). Per-feature scenarios belong in a **checklist** (Template 4); cross-module scenarios belong in the **playbook** (Template 3). Keep the runbook's Act section to the module's *invariant* smoke path:

```markdown
# {Module} — QA Runbook

> Tells the whole story of QA-ing this module. Read top-to-bottom first time; jump-to-section later.

## Goal
<single sentence: what this runbook helps you accomplish>

## Preconditions
<what must be running first; reference orchestration commands from scripts/ below>
<reference required config from qa/config/REQUIRED.md>

## Reset → Clean State
<exact commands to get this module back to known-clean>

## Inject → Realistic Data
<seed strategy chosen in Step 4: dummy / prod-snapshot / hybrid / none>
<exact commands or steps>

## Act → Exercise the System
<numbered scenarios: step + expected result. Cover invariants, NOT every variant.>

## Observe → Confirm Result
<where to look: logs, UI, asserts. How to tell pass from fail.>

## Config Switching
<files/lines to edit when going local ↔ deployed. Committed config = deploy target; local config is the swap-IN.>

## Troubleshooting
<symptoms → causes → fixes>

## Known Gotchas
<things that broke before, with workarounds>
```

#### Template 2 — Run-Script Framework (categorized by R/I/A/O)

Files at `qa/scripts/` (or `qa/` root if there will be ≤4 scripts). The **`# R/I/A/O category:` header is the machine contract** — `/integration-test` resolves each script by reading that header, NOT by its filename. So existing project scripts keep their natural names (`teardown`, `import-seed`, `start-stack`, `smoke-check`); just ensure each carries the category header. The filename patterns below are a **human-readability suggestion for new scripts**, not a requirement:

| Category | Suggested filename | Examples |
|---|---|---|
| RESET | `reset-{scope}.{ext}` | `reset-stack`, `reset-db`, `teardown` |
| INJECT | `seed-{scope}.{ext}` | `seed-fixtures` (option A), `seed-from-snapshot` (option B), `import-seed` |
| ACT | `start-{scope}.{ext}` | `start-stack`, `start-module` |
| OBSERVE | `smoke-{scope}.{ext}` | `smoke-check`, `tail-logs` |

Each generated (or adopted) script MUST carry:
- Header comment: `# R/I/A/O category: {RESET|INJECT|ACT|OBSERVE} — scope: {scope}` — **required**; this is how the consumer finds it regardless of filename.
- A newly generated stub adds a single `TODO:` line for the user/agent to fill, and nothing else — no boilerplate, no baked-in lessons.
- When adopting an existing script that already works, just prepend the header — do not rewrite it.

#### Template 2b — Fixtures (composable per-stage preconditions; scaffold the folder, not the content)

Where INJECT (Template 2) seeds one realistic-data baseline, a **fixture** cheaply reproduces the end-state of **one flow stage** ("as if create-order completed") so `/integration-test` **Tactic B** can reach a deep precondition without paying the full e2e cost for every upstream stage. They compose (each stage's fixture feeds the next) and are the cost lever that makes e2e affordable: pay the *real* cost only for the one step under test; reach everything before it via fixtures.

**Scaffold the folder only** — do NOT generate fixtures up front (there's no flow to fixture yet; they're built per-flow when a Tactic-B run needs one, like checklists):

- `qa/fixtures/` — per-stage precondition-builders live here
- `qa/fixtures/README.md` — one-paragraph note: what a fixture is, the header convention, the fidelity rule, and the golden rule *"fixture the preconditions; never fixture the step under test."*

Each fixture (created later, per flow) carries a header:
- `# fixture: {stage} — produces: {end-state it reproduces} — fidelity: {how it mirrors the real stage's output (reuse-snapshot / real-API-with-token / DB-seed-mirroring-writes)}`

**Fidelity is the discipline that keeps fixtures honest**: a fixture must produce a state *equivalent* to the real stage's output, or Tactic-B runs validate states the system could never reach. Prefer the highest-fidelity buildable form (reuse existing snapshot rows > call the real stage's API > hand-rolled DB seed). Note in the README that `/integration-test` should periodically run the REAL stage and assert its output matches the fixture (drift check).

#### Template 3 — Playbook (cross-module; only if Step 5 = A/B/D)

The **playbook** is the system-wide strategy layer — connection map, boot order, full-system smoke, and the end-to-end scenarios that span modules. It *references* the per-module runbooks. A single-app project (Step 5 = C) has no playbook; its one runbook carries the whole story. Two parts:

**(3a) Orchestration file** (chosen in Step 6) at the appropriate location:
- For `docker-compose`: stub `docker-compose.yml` with placeholder services + `depends_on` graph reflecting module connections
- For `Makefile` / `Justfile`: stub with composed targets (`make up`, `make down`, `make smoke`)
- For `npm workspaces`: stub `package.json` workspaces field

**(3b) Playbook doc** at `qa/playbook.md`:

```markdown
# {Project} — QA Playbook

> The cross-module strategy layer: connection map + boot order + full-system smoke + end-to-end scenarios that span modules. References the per-module runbooks in qa/runbooks/.

## Connection Map

| From | To | Protocol | Port | Auth | Notes |
|---|---|---|---|---|---|
| <FE> | <BE> | HTTP | 3000 | session cookie | |
| <BE> | <DB> | TCP | 5432 | env var DB_URL | |

## Full-System Boot Order
1. <e.g., DB first — see qa/runbooks/{db}.md>
2. <e.g., BE next — see qa/runbooks/{be}.md>
3. <e.g., FE last — see qa/runbooks/{fe}.md>

## Full-System Smoke
<commands or steps to verify the whole connected stack at once>

## End-to-End Scenarios
<numbered cross-module scenarios — the paths that touch multiple modules (e.g. "customer order: FE → BE → queue → worker → DB"). Each step names the module + points at its runbook. Cover system invariants, not every variant.>
```

> **Naming note**: this file was historically the "aggregation manifest" / `connections.md`. It is a **playbook** — the cross-module orchestration + scenario layer, distinct from the per-module runbooks and the per-feature checklists.

#### Template 4 — Checklist(s) (per-feature; scaffold the folder, not the content)

Checklists are **per-feature, ephemeral** manual-verification plans — created when a specific feature ships, run during QA, archived on sign-off. Unlike runbooks (evergreen "how to run") and the playbook (evergreen "how the system connects"), a checklist is tied to one change and has a lifecycle.

**Scaffold the folder structure only** — do NOT generate feature checklists up front (there's no feature to verify yet):

- `qa/checklists/` — active per-feature checklists live here
- `qa/checklists/completed/` — archived here after sign-off (add a `.gitkeep`)
- `qa/checklists/README.md` — one-paragraph lifecycle note: create on ship → run + tick + note defects inline → move to `completed/` on sign-off

Checklist content shape (created later, per feature, by the shipping wizard — not now):

```markdown
# {Feature} — QA Checklist

> Per-feature verification for {feature/plan}. Tick as you go; note defects inline; archive to completed/ on sign-off.

## Preconditions
<which runbook(s) / the playbook to bring the stack up first>

## Checks
- [ ] <observable behavior + expected result>
- [ ] <edge case + expected result>

## Result
<sign-off + date, or defects found>
```

#### Template 5 — Config (Inventory + Templates)

Two parts: a required-config inventory (from Step 3) + per-environment templates.

**(5a) `qa/config/REQUIRED.md`** — system-level config inventory:

```markdown
# {Project} — Required Config Inventory

> Every config key the system needs to start at all. Status from Step 3 scan.

| Key | Used by | Status | Acquisition step / source |
|---|---|---|---|
| `RESEND_API_KEY` | bff (email send) | missing | Sign up at resend.com, free tier sufficient for QA |
| `DB_URL` | api | exists & documented | See `.env.local.template` |
| `STRIPE_WEBHOOK_SECRET` | api (webhooks) | tribal | Currently in Alvi's password manager — TODO: document |
| `PROD_DB_READONLY_URL` | seed-from-snapshot script | missing | Request from ops; needed only if seed strategy = prod-snapshot |

## Acquisition Notes
<expand on any item that needs more than one line>
```

**(5b) Per-environment templates** — use placeholders, NEVER real secrets:

- `qa/config/.env.local.template` — local development values, one-line comment per var
- `qa/config/.env.qa.template` — QA-environment values
- `qa/config/.env.production.template` — production placeholders only

For .NET projects with detected `Web.config` / `App.config`:
- `qa/config/Web.Local.config.template` / `qa/config/App.Local.config.template` — local swap-IN values

Every template starts with a 2-line header:

```
# Committed config = deploy target. This template is the swap-IN for local mode.
# Never commit actual secrets — placeholders only.
```

### Step 8: Run the Loop Once

Before reporting success, attempt to walk RESET → INJECT → ACT → OBSERVE end-to-end using the generated scripts. For each phase:
- If the script is filled in → execute it, report result
- If the script is still a stub → flag which phase needs [USER-NAME] input + show exact next-step command

The loop completing once end-to-end is the proof the instrument works. **No green light without this step.**

### Step 9: Report

Present summary:

```
QA instrument set up at qa/:
- R/I/A/O loop status: RESET={status}, INJECT={status}, ACT={status}, OBSERVE={status}
- Required config inventory: {n} keys ({n_exists} exist, {n_tribal} tribal, {n_missing} missing)
- Seed strategy: {A/B/C/D} — {brief why}
- Runbooks generated: {count} ({list})
- Scripts generated: {count} (R={n}, I={n}, A={n}, O={n}) — each with the `# R/I/A/O category:` header
- Playbook (cross-module): {qa/playbook.md + orchestration file} or N/A (single-app)
- Checklists: folder scaffolded (per-feature checklists created on ship)
- Fixtures: folder scaffolded (per-stage fixtures created per-flow by /integration-test Tactic B)
- Config templates: {count}

Next steps:
- Acquire missing config: {list missing items + acquisition steps}
- Fill the {phase} stub in {file}
- Run `qa/scripts/start-stack.{ext}` to bring stack up
- Read qa/runbooks/{first-module}.md for a module's QA story, or qa/playbook.md for the full-system view
```

If any phase is still stubbed OR any required config is still missing, list those gaps explicitly so they don't get forgotten — per NO TODOS LEFT BEHIND (UUID a1b2c3d4).
