# Push Project Files

Commit and push all changes in the current working project repository.

## Arguments

`$ARGUMENTS`

- `/push-project [message]` → Use provided commit message
- `/push-project` → Auto-generate commit message from changes

---

## Procedure

### Step 1: Check for Changes

Run `git status` in the current working directory.

If no changes (working tree clean), inform user: "No project changes to push." and stop.

### Step 2: Stage and Commit

1. Run `git add -A` in the current working directory
2. Run `git diff --cached --stat` to see what's staged
3. **If message argument provided**: Use it as commit message
4. **If no message**: Auto-generate a concise commit message from the staged changes
5. Commit with the message

> **Message style — self-contained.** Describe *what changed + why* in plain prose. Never reference plan-internal or process artifacts — decision letters (`A1`, `OQ2`, "based on decision A1"), ADR numbers (`ADR-10`), or plan step/phase numbers. A `git log` reader won't have the plan open. (See the *Commit Message — Self-Contained* git fundamental.)

### Step 3: Push

1. Run `git push`
2. Confirm to user: "Project pushed: [commit message]"
3. Also confirm if there are files in the project that hasn't been pushed and what is the reason

---
