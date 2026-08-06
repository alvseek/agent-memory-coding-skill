# Pull Agent Memory

Pull the latest changes for the agent-memory repository and update the control-files submodule.

## Arguments

`$ARGUMENTS`

- `/pull-memory` → Pull agent memory + update control-files submodule

---

## Procedure

### Step 1: Check Repository State

Run `git status` in the agent-memory repo (`//@agent-memory/`).

If there are uncommitted changes, warn user: "You have uncommitted changes in agent-memory. Pull may cause merge conflicts. Continue?" and wait for confirmation.

### Step 2: Pull Agent Memory

1. Run `git pull` in the agent-memory repo
2. Report result: "Agent memory pulled: [result summary]"

If pull fails, report the error and stop.

### Step 3: Update Control Files Submodule

1. Run `git submodule update --remote --merge` in the agent-memory repo
2. Report result: "Control files updated: [result summary]"

If submodule update fails, report the error.

---
