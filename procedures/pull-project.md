# Pull Project Files

Pull the latest changes from the remote for the current working project repository.

## Arguments

`$ARGUMENTS`

- `/pull-project` → Pull latest changes from remote

---

## Procedure

### Step 1: Pull

1. Run `git pull` in the current working directory 
2. Run `git submodule update --remote --merge` and all of its submodules.
3. Report result to user: "Project pulled: [result summary]"

If pull fails (e.g., merge conflict), report the error and stop.

---
