# Push Agent Memory

Commit and push all changes in the agent-memory repository.

## Arguments

`$ARGUMENTS`

- `/push-memory [message]` → Use provided commit message
- `/push-memory` → Auto-generate commit message from changes

---

## Procedure

### Step 1: Check for Changes

Run `git status` in the agent-memory repo (`//@agent-memory/`).

If no changes (working tree clean), inform user: "No agent memory changes to push." and stop.

### Step 2: Stage and Commit

1. Run `git add -A` in the agent-memory repo
2. Run `git diff --cached --stat` to see what's staged
3. **If message argument provided**: Use it as commit message
4. **If no message**: Auto-generate a concise commit message from the staged changes (e.g., `update: episodic memories + reasoning patterns`, `feat: add project context procedures`)
5. Commit with the message

> **Message style — self-contained.** Describe *what changed + why* in plain prose. Never reference plan-internal or process artifacts — decision letters (`A1`, `OQ2`, "based on decision A1"), ADR numbers (`ADR-10`), or plan step/phase numbers. A `git log` reader won't have the plan open. (See the *Commit Message — Self-Contained* git fundamental.)

### Step 3: Push

1. Run `git push`
2. Confirm to user: "Agent memory pushed: [commit message]"
3. Also confirm if there are files in the agent-memory repo that hasn't been pushed and what is the reason

---
