# Push Agent Work

Commit and push **only the agent's own work** — the agent-memory repo (whole) + agent-produced paths in the working project — leaving the user's unrelated changes untouched. Built for **automatic** flows like `/wrap-up`. For a deliberate full-tree push, use `/push-all` / `/push-project` instead.

## Arguments

`$ARGUMENTS`

- `/push-agent-work [message]` → Use the provided commit message for every repo committed
- `/push-agent-work` → Auto-generate commit messages from the staged changes

---

## Procedure

> **In-scope repos.** The working project repo, its **owned git submodules** (recurse), and the agent-memory repo (`//@agent-memory/`) with its own submodules. A superproject's `git status` shows a dirty submodule only as a one-line gitlink — it does NOT reveal uncommitted files *inside* the submodule, and `git add` on the gitlink records only the pointer. So you MUST enter each owned submodule and commit/push agent-work **inside it first**, then commit the updated pointer in its superproject. Always process submodules **before** their superproject.

> **Push-exclude list (check first).** Honor the shared [Push Exclude Policy](//@agent-memory/control-files/procedures/push-exclude-policy.md) — excluded repos/submodules are never committed or pushed and never counted against completion (`skipped (excluded)`).

### Step 1: Define the Agent-Work Set

Per in-scope repo, the **only** thing this command may commit:

- **agent-memory repo** — entirely the agent's own repo → stage all (`git add -A`).
- **In each in-scope project repo / owned submodule, stage ONLY**:
  - `.agents/**` — always agent-owned (localized memory, [ADR-010](//@agent-memory/docs/adr/2026-07-13-work-product-memory-localization.md)).
  - files the agent created/edited **this session** — cross-check the newest episode's `Deliverables` / `Outcomes` plus your own Write/Edit history.
  - agent-produced files from **earlier sessions still uncommitted** — identify from prior episode deliverables and `.agents/` breadcrumbs.
- 🚨 **NEVER `git add -A` in a project repo.** Stage the agent-work paths explicitly. Every other dirty file is the **user's** — leave it untouched, report it as `left for user`, never commit it.
- ⚠️ **When the set is uncertain** (long or context-compacted session — recalled edit history may be incomplete, and the episode may miss late edits): do NOT silently drop a dirty file you can't confidently classify. Surface the ambiguous paths (whatever in `git status` you're not sure is the user's) and confirm before finishing. The completion gate can catch an agent path left *unpushed*, but it CANNOT detect an *under-inclusive* set — a missed agent file would be silently abandoned, so resolve the doubt here.

### Step 2: Commit & Push (submodules before superprojects)

For each in-scope repo, **innermost submodule first**:

1. **Stage** its agent-work set (Step 1): agent-memory → `git add -A`; project repo / submodule → `git add <agent-work paths>` (never `-A`).
2. Run `git diff --cached --stat` to confirm what's staged. **If nothing is staged AND the branch is not ahead of its remote** (`git status -sb` shows no `[ahead N]`), this repo is already done → skip it silently. Do **NOT** halt the procedure — continue to the next repo.
3. Otherwise **commit** the staged changes (provided message, or auto-generate — e.g. `chore(agent): wrap-up session work`), then **`git push`**. **Message style — self-contained**: describe *what changed + why* in plain prose; never reference plan-internal or process artifacts — decision letters (`A1`, `OQ2`), ADR numbers (`ADR-10`), or plan step/phase numbers (a `git log` reader won't have the plan). See the *Commit Message — Self-Contained* git fundamental.
4. After pushing a **submodule**, stage + commit its **updated pointer** in the superproject (the pointer bump is itself agent work).
5. Treat a **non-zero `git push` exit** as a failure for that repo — do not retry elaborately; carry it to Step 3.

### Step 3: Verify & Report

In every in-scope repo run **`git status -sb`** — the `-sb` branch header surfaces `[ahead N]`, i.e. locally-committed-but-**unpushed** work that plain `git status --short` hides. A repo is **done** only when **both**: (a) no agent-work path is dirty, AND (b) its branch is **not ahead of its remote** (every agent commit is actually pushed). Any files still dirty must be OUTSIDE the agent-work set (the user's) — expected, reported as `left for user`, never counted as a failure. Excluded repos → `skipped (excluded)`.

```
Push (agent work only):
- agent-memory: [pushed — commit-hash / no changes]
- [project/submodule]: [pushed — commit-hash — N user file(s) left for user / no agent changes]
- [excluded repo]: skipped (excluded — vendored/read-only)
```

---
