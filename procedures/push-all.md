# Push All (Project + Agent Memory)

Commit and push changes in both the current working project and the agent-memory repository.

## Arguments

`$ARGUMENTS`

- `/push-all` → Auto-generate commit messages for both repos
- `/push-all [message]` → Use provided message for both commits

---

## Procedure

> **Push-exclude list (check first).** Honor the shared [Push Exclude Policy](//@agent-memory/control-files/procedures/push-exclude-policy.md) — excluded repos/submodules are never committed or pushed and never counted against completion (`skipped (excluded)`).

### Step 1: Push Project Files

Follow the [Push Project](/push-project) procedure for the current working directory.

### Step 2: Push Agent Memory

Follow the [Push Memory](/push-memory) procedure for the agent-memory repo (`//@agent-memory/`).

### Step 3: Summary

Report results for both:
```
Push summary:
  - Project: [pushed/no changes] — [commit message if pushed]
  - Agent memory: [pushed/no changes] — [commit message if pushed]
```

---
