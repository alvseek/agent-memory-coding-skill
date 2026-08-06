# Pull Project Files

Pull the latest changes from the remote for the current working project repository.

## Arguments

`$ARGUMENTS`

- `/pull-project` → Pull latest changes from remote

---

## Procedure

### Step 1: Check Repository State

Run `git status` in the current working directory.

If there are uncommitted changes, warn user: "You have uncommitted changes. Pull may cause merge conflicts. Continue?" and wait for confirmation.

### Step 2: Pull

1. Run `git pull` in the current working directory
2. Report result to user: "Project pulled: [result summary]"

If pull fails (e.g., merge conflict), report the error and stop.

---
