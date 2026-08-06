# Setup QA Instrument

Establish a reliable QA feedback loop for a project. Investigates the project's existing reset/inject/act/observe pieces, identifies gaps, then codifies them into 4 artifact types: **playbook(s)**, **run-script framework**, **aggregation manifest**, and **config templates**. Works across any stack — the loop is universal, the implementations are project-specific.

> *Output (`qa/` folder) is consumed by [`/integration-test`](integration-test.md) — the runtime verification procedure — invoked from the **Final Integration Test** step in [`/high-wizard`](high-wizard.md) (Step 17), [`/quick-wizard`](quick-wizard.md) (Step 8), and [`/pixel-wizard`](pixel-wizard.md) (Step 19), or standalone for ad-hoc runtime checks.*

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

For each `missing` item, ask [USER-NAME] what the **acquisition step** is (e.g., "sign up at resend.com, free tier", "request prod DB read-replica access from ops"). Capture as a note for the playbook.

For each `tribal` item, ask if [USER-NAME] wants to document it now or defer. Tribal config is a future-trap.

**Output**: feeds into Template 4's `REQUIRED.md` inventory file.

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
- What the playbook documents under "Inject → Realistic Data" in Template 1

### Step 5: Identify Modules and Connections (Aggregation)

Ask:

1. **Which modules need their own playbook?** Free text, one per line. Examples: `web`, `middleware`, `api`, `mobile`, `bff`, `worker`.
2. **How do they connect?** Pick from:
   - A) Aggregate with git submodules (each module = own repo)
   - B) Monorepo workspace (npm/pnpm/Cargo/Go workspaces)
   - C) Single-app single-repo (one playbook only — skip aggregation artifacts)
   - D) Bridge to external systems (focus playbook on the bridge contract)

The answer drives whether Template 3 (Aggregation) gets generated and what shape it takes.

### Step 6: Choose Runtime + Shell (No Defaults)

Ask:

1. **Orchestration tool**: `docker-compose` / `Makefile` / `Justfile` / `npm scripts` / `plain shell scripts` / `mix — describe` / `none needed (just app processes)`
2. **Shell for scripts**: `bash (.sh)` / `PowerShell (.ps1)` / `cmd (.bat)` / `cross-platform (generate both .sh and .ps1)`

Do NOT default to any shell. Use [USER-NAME]'s explicit answer. If the project has existing scripts of one type detected in Step 1, mention that as the suggested default but still ask.

### Step 7: Generate the 4 Templates

Generate **only** the templates that fill identified gaps from Steps 2–4. If a phase already exists & is documented, don't regenerate it — extend or link to it instead.

#### Template 1 — Playbook (one per module from Step 5)

File: `qa/playbooks/{module}.md`

Content shape (this is a runbook, NOT a 7Q README):

```markdown
# {Module} — QA Playbook

> Tells the whole story of QA-ing this module. Read top-to-bottom first time; jump-to-section later.

## Goal
<single sentence: what this playbook helps you accomplish>

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

Files at `qa/scripts/` (or `qa/` root if there will be ≤4 scripts). Naming follows the R/I/A/O category for fast playbook cross-reference:

| Category | Filename pattern | Examples |
|---|---|---|
| RESET | `reset-{scope}.{ext}` | `reset-stack`, `reset-db`, `reset-cache` |
| INJECT | `seed-{scope}.{ext}` | `seed-fixtures` (option A), `seed-from-snapshot` (option B), `anonymize-snapshot` (option B/C) |
| ACT | `start-{scope}.{ext}` | `start-stack`, `start-module` |
| OBSERVE | `smoke-{scope}.{ext}` | `smoke-check`, `tail-logs` |

Each generated script is a stub with:
- Header comment: `# R/I/A/O category: {RESET|INJECT|ACT|OBSERVE} — scope: {scope}`
- Single `TODO:` line for the user/agent to fill
- Nothing else — no boilerplate, no baked-in lessons

#### Template 3 — Aggregation (only if Step 5 = A/B/D)

Two files:

**(3a) Orchestration file** (chosen in Step 6) at the appropriate location:
- For `docker-compose`: stub `docker-compose.yml` with placeholder services + `depends_on` graph reflecting module connections
- For `Makefile` / `Justfile`: stub with composed targets (`make up`, `make down`, `make smoke`)
- For `npm workspaces`: stub `package.json` workspaces field

**(3b) Connections manifest** at `qa/connections.md`:

```markdown
# {Project} — Module Connections

## Connection Map

| From | To | Protocol | Port | Auth | Notes |
|---|---|---|---|---|---|
| <FE> | <BE> | HTTP | 3000 | session cookie | |
| <BE> | <DB> | TCP | 5432 | env var DB_URL | |

## Full-System Boot Order
1. <e.g., DB first>
2. <e.g., BE next>
3. <e.g., FE last>

## Full-System Smoke
<commands or steps to verify the whole connected stack at once>
```

#### Template 4 — Config (Inventory + Templates)

Two parts: a required-config inventory (from Step 3) + per-environment templates.

**(4a) `qa/config/REQUIRED.md`** — system-level config inventory:

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

**(4b) Per-environment templates** — use placeholders, NEVER real secrets:

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
- Playbooks generated: {count} ({list})
- Scripts generated: {count} (R={n}, I={n}, A={n}, O={n})
- Aggregation: {orchestration file + connections.md} or N/A
- Config templates: {count}

Next steps:
- Acquire missing config: {list missing items + acquisition steps}
- Fill the {phase} stub in {file}
- Run `qa/scripts/start-stack.{ext}` to bring stack up
- Read qa/playbooks/{first-module}.md for the full QA story
```

If any phase is still stubbed OR any required config is still missing, list those gaps explicitly so they don't get forgotten — per NO TODOS LEFT BEHIND (UUID a1b2c3d4).
