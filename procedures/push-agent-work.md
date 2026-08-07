# Push Agent Work

Commit and push **only the agent's own work**, across both repos: the working project (agent-produced paths only) and the agent-memory store (this agent's own memory only). Built for **automatic** flows like `/wrap-up` — it leaves the user's unrelated project changes AND other agents' in-flight memory untouched. For a deliberate full-tree push, use `/push-all`.

This is a thin composition of the two leaf pushers in `agent` mode:

## Arguments

`$ARGUMENTS`

- `/push-agent-work [message]` → use the provided commit message for every repo committed
- `/push-agent-work` → auto-generate commit messages from the staged changes

---

## Procedure

*(Push-exclude policy + submodule ordering + the `[ahead N]` push-state gate are honored inside the delegated leaf pushers — this command adds no git logic of its own.)*

### Step 1: Push Project Work (agent mode)

Run **`/push-project agent [message]`** — stages only agent-produced paths in the working project + owned submodules (never `git add -A`); the user's unrelated changes are left for the user.

### Step 2: Push Memory (agent mode)

Run **`/push-memory agent [message]`** — stages only *this* agent's own memory (its `agent-<domain>/` folder + shared files touched this session), never `git add -A`, so a concurrently-running agent's in-flight memory is never swept up.

### Step 3: Report

Aggregate the two leaf-push reports:

```
Push (agent work only):
- [project/submodule]: [pushed — commit-hash — N user file(s) left for user / no agent changes]
- agent-memory: [pushed — commit-hash — other agents' files left untouched / no agent changes]
- [excluded repo]: skipped (excluded)
```

---
