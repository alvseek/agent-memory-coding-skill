# Project Wrap Up Session

End-of-session **full** orchestrator (coding/environment add-on): push the project's work → memory wrap-up → orientation map refresh → push memory → final summary with a push-completion gate. Composes the core memory-only /wrap-up with git + orientation-map steps.

**Delta-aware**: the memory wrap-up (Step 2) re-scopes to the delta on re-run. `/project-wrap-up fresh` forces full-session re-eval.

**Execution style**: silent. Run Steps 1-5 silently — tool calls (bash, edit, write) stay visible, but no prose narration of phases. Produce ONE summary block at Step 5 as the only user-facing output.

## Arguments

`$ARGUMENTS`

- `/project-wrap-up` → Default (delta vs fresh auto-detected by `/update-memory`)
- `/project-wrap-up fresh` → Force fresh mode (pass-through to the memory wrap-up)

---

## Procedure

### Step 1: Push the Project's Work (silent) — MANDATORY

Push the agent's **project** work FIRST, so a merge request / PR can be opened immediately without waiting for the memory update that follows. Execute /push-agent-work scoped to the **working project repo and its owned submodules only** — do NOT touch the agent-memory repo yet (this session's memory isn't written until Step 2, so pushing it now would miss it). The conservative rule still holds: stage only agent-produced project paths (never `git add -A`); the user's unrelated changes are left for the user.

Tool calls visible (git commands); capture per-repo commit hashes + user-files-left counts for Step 5.

### Step 2: Memory Wrap-Up (silent)

Execute the core /wrap-up **memory steps** (Save Memory via `/update-memory` + Extract Open Items), passing `fresh` through if present. Capture its memory-update results (mode, gate decisions, episodic entry, carry-forward count, promotions, emotional status) and the open-item lists as data for Step 5. Do NOT print `/wrap-up`'s own Memory Summary separately — it folds into Step 5.

### Step 3: Refresh Orientation Map (silent)

If this session touched orientation docs (READMEs, architecture, flow diagrams, ADRs):

`/map-orientation --session-touched [path1,path2,...]`

Silent no-op if no map exists or no orientation docs touched. Capture refresh count / no-op reason for Step 5.

### Step 4: Push Memory (silent) — MANDATORY

Execute /push-agent-work for the **agent-memory repo** (whole) plus any **project memory files** Steps 2–3 just wrote (localized `.agents/**` + refreshed `docs/` orientation/context docs). Invoking `/project-wrap-up` IS the authorization to commit + push. This captures the episodic / emotional / reasoning / knowledge writes that the Step 1 project push ran too early to include. Same scope discipline — never a blanket `git add -A` on the project (only the memory paths above); explicit `/push-all` / `/push-project` stay full-tree as a deliberate user choice.

Tool calls visible (git commands); capture per-repo commit hashes + agent-work-pushed status for Step 5.

**Then verify (drives the Step 5 completion gate)**: from Push Agent Work's Step 3 verification across BOTH pushes (Step 1 project + Step 4 memory), record per repo whether **every agent-work path is committed AND pushed** (branch not ahead of remote) + a count of user files left. **Excluded repos are exempt** (report as `skipped (excluded)`). Do NOT attempt elaborate recovery — if an *agent-work* push fails or any agent-work path remains, that is carried to Step 5, where the wrap-up fails loudly.

### Step 5: Final Summary (only visible output)

**Completion gate (per NO TODOS LEFT BEHIND, UUID a1b2c3d4)**: using the Step 4 verification (covering both the Step 1 project push and the Step 4 memory push), the wrap-up is **complete ONLY if every agent-work path is committed AND pushed** in every in-scope repo. A project repo that still holds the **user's own** uncommitted changes is still complete — leftover user files are expected and exempt (so are push-excluded repos). The wrap-up is **NOT complete** only if an **agent-work** path is uncommitted, a branch carrying agent commits is ahead of its remote, or an agent-work push failed → print the *WRAP-UP INCOMPLETE* block (at the bottom of this step) instead, and never claim completion.

**On success (every agent-work path committed + pushed)**, print this block:

```
Wrap-up complete (mode: [fresh / delta from CUTOFF]):

Memory update:
- Phase 1 — Promoted artifacts: project context: [updated/created — file / skipped] / reasoning: [added — pattern name / skipped] / knowledge: [added — entry name / skipped]
- Phase 2 — Session captured: [appended to / created] [filename] ([H3 timestamp]) — [brief theme]; carry-forward: [N items / N/A]; promotions: [N markers / none]
- Phase 3 — Feeling captured: emotional [captured — polarity + clearest criterion / skipped — brief reason]

Orientation map: [refreshed N entries / no-op: reason]

Push — agent work only (every agent-work path must be ✅):
- [project/submodule]: ✅ [commit-hash] pushed (project work) — [N user file(s) left for user / no user files left]
- agent-memory: ✅ [commit-hash] pushed (memory) / no changes
- [project memory files]: ✅ pushed with memory (localized .agents/docs)   ← only if the project is localized
- [excluded repo]: ⏭️ skipped (excluded — vendored/read-only)   ← only if the project has exclusions

📋 Open items going forward:

Tech debts:
- [item 1]
- [item 2]
(or "None declared")

Next steps:
- [item 1]
- [item 2]
(or "None declared")
```

If both Tech Debts and Next Steps are empty → replace both lists with *"No open items declared from this session."*

---

**On failure (ANY agent-work path not committed + pushed)** — do NOT print "Wrap-up complete". Print this block instead:

```
🚨 WRAP-UP INCOMPLETE — UNPUSHED AGENT WORK. NEED CONFIRMATION.

[Memory update / Orientation map / Open items sections — same as above]

Push — FAILED / INCOMPLETE (agent work not fully saved):
- [repo]: ⚠️ agent-work [uncommitted N files / branch ahead by N / push error: <reason>]
- [repo]: ✅ [commit-hash] pushed

⚠️ The agent's work is NOT fully saved to the remote. What remains, and where:
- [repo → which agent-work path is uncommitted/unpushed]
(User's own uncommitted files are expected and NOT listed here — only agent work blocks completion.)

Retry the push (or resolve the blocker) before leaving — the wrap-up is only complete when every agent-work path is committed AND pushed.
```
