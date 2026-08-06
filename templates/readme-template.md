---
doc_type: 7q-readme
---

# [Project Name]

<!-- ============================================================
  7Q README TEMPLATE — 7 Questions Framework README

  HOW TO USE:
  1. Copy this file into your project as README.md (or docs/readme/README.md for large projects)
  2. Read the Documentation Convention section below, then delete it
  3. Fill each section — delete the HTML comments as you go
  4. Delete sections that don't apply (e.g., Q5 for a library with no deployment), but DO NOT DELETE section that's empty
  5. Keep it honest — an incomplete README is better than a fictional one
============================================================ -->

> **Documentation Convention** *(delete this section after reading)*
>
> This project follows the **7Q README** (7 Questions Framework README) documentation standard with these conventions:
>
> **Fractal docs**: Every buildable unit (service, app, module) can have its own README following this same template. A root README covers the whole project; a module README covers just that module.
>
> **Doc locations**:
> - Small projects: `README.md` at project root. Cross-cutting docs in `/docs/` (e.g., `docs/README-deployment.md`)
> - Large projects: Brief `README.md` at root linking to `/docs/readme/README.md` (full project 7Q README)
> - Module-specific: each buildable unit can have its own `README.md` — no need to maintain a central link list
>
> **Cross-referencing**: When describing architecture in Q1 below, naturally mention modules that have their own README. Example: *"Order processing lives in `business/orders` — see its README for internals."* This gives discoverability without maintaining fragile link lists.

---

## Table of Contents

- [What Is This?](#what-is-this)
- [How Do I Set It Up?](#how-do-i-set-it-up)
- [How Do I Use It?](#how-do-i-use-it)
- [How Does It Work Inside?](#how-does-it-work-inside)
- [How Is It Deployed?](#how-is-it-deployed)
- [What Decisions Were Made?](#what-decisions-were-made)
- [What's Broken / Known Debts?](#whats-broken--known-debts)

<!-- tip: Remove entries for sections you delete. -->

---

## What Is This?

<!-- tip: A new person should understand this project's reason to exist within 30 seconds.
     Think "elevator pitch + system map". Keep the architecture diagram to one screen. -->

[1-3 sentences: what this project does, who it's for, and why it exists.]

### Architecture

<!-- tip: Show how the major pieces connect. If this project has modules with their own
     READMEs, mention them here naturally — this is how readers discover child docs.
     Example: "Order processing lives in business/orders — see its README for internals." -->

<!-- tip: If this project follows an architecture pattern (e.g., A-Boxed L1), mention it here.
     This helps readers understand the structural conventions used throughout the project. -->

```
[Diagram or ASCII art showing major components and their relationships]
```

### Tech Stack

<!-- tip: Just the key technologies. Not every npm package — just what someone needs
     to know to understand what they're working with. -->

- **Runtime**: [e.g., Node.js 20 + NestJS 10]
- **Database**: [e.g., PostgreSQL 16]
- **Queue**: [e.g., RabbitMQ]
- **Cache**: [e.g., Redis]

---

## How Do I Set It Up?

<!-- tip: Write this as if the reader has NEVER seen this project before.
     Every step should be copy-pasteable. Include a "verify it works" step at the end. -->

### Prerequisites

- [Runtime and version] (`command --version`)
- [Database / service needed]
- [Any other tools]

### Setup

1. Clone and install:
   ```sh
   git clone <repo-url>
   cd [project-name]
   [install command]
   ```

2. Configure environment:
   ```sh
   cp .env.example .env
   # Edit .env — see Environment Variables below
   ```

3. Setup database:
   ```sh
   [migration command]
   [seed command]
   ```

4. Start:
   ```sh
   [start command]
   ```

5. Verify it works:
   ```sh
   [health check command]
   # Expected: [expected output]
   ```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| [VAR_NAME] | [What it controls] | [Example value] |

---

## How Do I Use It?

<!-- tip: This is the "daily driver" section. Keep it scannable — tables and command
     lists, not paragraphs. For APIs, a summary table is enough — detailed specs
     belong in auto-generated docs (Swagger/OpenAPI). -->

### Commands

| Command | Description |
|---------|-------------|
| `[dev command]` | Start development server |
| `[build command]` | Build for production |
| `[test command]` | Run all tests |
| `[lint command]` | Lint and format check |

<!-- tip: If this is a service with API endpoints, add an endpoints summary table.
     If it's a library, show usage examples. If it's a CLI, show key commands. -->

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| [METHOD] | [/path] | [What it does] |

---

## How Does It Work Inside?

<!-- tip: This is NOT a code dump — it's a MAP to help someone navigate the code.
     Focus on the flows that matter most (happy path of core features).
     Point to specific files/folders so someone knows where to start looking.
     The actual implementation details should be in clean code, not here. -->

### Core Flow: [Primary Feature Name]

1. **[Layer/Step 1]** (`[file path]`)
   - [What happens at this step]

2. **[Layer/Step 2]** (`[file path]`)
   - [What happens at this step]

3. **[Layer/Step 3]** (`[file path]`)
   - [What happens at this step]

### Data Model

<!-- tip: ERD diagram or key entities with relationships.
     Keep it high-level — column-level detail belongs in migration files. -->

```
[ERD or entity relationship overview]
```

### External Integrations

<!-- tip: What external services does this talk to? Include protocol and timeout
     so on-call engineers know what to expect. -->

| Service | Purpose | Protocol | Timeout |
|---------|---------|----------|---------|
| [Service name] | [Why we call it] | [REST/gRPC/Queue] | [e.g., 3s] |

---

## How Is It Deployed?

<!-- tip: Critical for on-call and incident response. Include actual URLs and
     dashboard links — not "check the monitoring tool". Include rollback instructions. -->

### Environments

| Environment | URL | Branch | Auto-deploy |
|-------------|-----|--------|-------------|
| Development | [URL] | [branch] | [Yes/No] |
| Staging | [URL] | [branch] | [Yes/No] |
| Production | [URL] | [branch] | [Yes/No] |

### CI/CD Pipeline

<!-- tip: Describe the flow: push → build → test → deploy. Note what's automatic
     vs what requires manual approval. -->

[Pipeline description]

### Infrastructure

- **Runtime**: [e.g., AWS ECS Fargate, 2 tasks]
- **Database**: [e.g., AWS RDS PostgreSQL]
- **Other**: [Cache, queue, CDN, etc.]

### Monitoring

- **Logs**: [Where to find logs]
- **Metrics**: [Dashboard link]
- **Alerts**: [Alert channel / on-call tool]

### Rollback

<!-- tip: Step-by-step instructions someone can follow at 3 AM during an incident. -->

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## What Decisions Were Made?

<!-- tip: Use ADR format: Context → Decision → Trade-off. Only record decisions
     that someone might QUESTION — obvious choices don't need ADRs.
     This prevents new people from re-debating settled decisions or
     "fixing" something that was intentional. Keep it chronological. -->

### ADR-001: [Decision Title] ([Date])

**Context**: [What problem or question prompted this decision?]
**Decision**: [What was decided and why.]
**Trade-off**: [What downside was accepted, and why it's acceptable.]

### ADR-002: [Decision Title] ([Date])

**Context**: [What problem or question prompted this decision?]
**Decision**: [What was decided and why.]
**Trade-off**: [What downside was accepted, and why it's acceptable.]

---

## What's Broken / Known Debts?

<!-- tip: Be brutally honest — this section saves future developers hours of confusion.
     Include WHY the debt exists. Prioritize: dangerous vs ugly.
     Update this as debts are created and resolved — stale lists are worse than none. -->

### High Priority

- **[Issue name]**: [What's wrong and impact.]
  *Why*: [Why this debt exists — time pressure? scope decision? knowledge gap?]

### Medium Priority

- **[Issue name]**: [What's wrong and impact.]
  *Why*: [Why this debt exists.]

### Low Priority

- **[Issue name]**: [What's wrong and impact.]
  *Why*: [Why this debt exists.]

### Known Limitations

- [Limitation 1 — what and why]
- [Limitation 2 — what and why]

---

<!-- ============================================================
  SCALING GUIDE — Fractal scaling for 7Q READMEs

  Single README: When all 7 sections fit in one readable file (~500 lines).
  Most small projects and individual modules.

  Too big? Use FRACTAL scaling — push detail into child unit READMEs:
  Each buildable unit (service, module, package) gets its own complete
  7Q README at its scope. The parent README stays high-level and
  naturally references child READMEs in Q1 Architecture.

  DO NOT split one README into section files (SETUP.md, ARCHITECTURE.md...)
  — that's decomposition, not fractal. Every README*.md is a complete
  7Q README at its scope.

  Cross-cutting topics that span multiple units get their own docs at
  the parent level using README-{topic}.md naming:

  Level 1 (small projects):
  README.md                          ← 7Q README at root
  /docs/
  ├── README-architecture.md         ← Cross-cutting 7Q README (optional)
  ├── README-deployment.md           ← Cross-cutting 7Q README (optional)
  └── STANDARDS.md                   ← Project standards (optional, not 7Q)

  Level 5 (large projects):
  README.md                          ← Brief entry point, links to docs/readme/
  /docs/
  ├── readme/
  │   ├── README.md                  ← Full project 7Q README
  │   ├── README-architecture.md
  │   └── flow/                      ← Category folders as needed
  │       ├── README.md              ← Flows overview (7Q)
  │       └── README-login.md        ← Login flow (7Q)
  ├── standards/
  │   ├── STANDARDS.md               ← Standards overview
  │   └── STANDARDS-logging.md       ← Logging standard
  └── planning/                      ← PRDs, ADRs, etc.

  Delete this comment block when you've decided your approach.
============================================================ -->
