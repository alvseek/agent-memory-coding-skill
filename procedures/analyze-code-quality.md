# Analyze Code Quality

Comprehensive code quality analysis for features, milestones, or any code scope. Walks through structured quality dimensions, documents findings with severity, and presents WAIT Options so [USER-NAME] controls what gets fixed. Uses a working document copied from the analysis template to track the full investigation.

## Arguments

`$ARGUMENTS`

### Standalone invocation (user-invoked)

- `/analyze-code-quality [scope]` → Analyze code quality for the given scope (creates a standalone working doc)
- `/analyze-code-quality` → Will ask for scope

**Scope examples:**
- File path(s): `src/api/users.ts`, `src/components/Modal.tsx`
- Directory: `src/features/auth/`
- Feature description: `the login feature we just built`
- Git-based: `all changes since last commit`
- Milestone: `everything in M1`

If no arguments provided, ask: "What code should I review? (file paths, directory, feature, or 'all changes since last commit')"

### Embedded invocation (wizard-delegated)

When called from `/high-wizard` Step 16, `/quick-wizard` Step 7, or `/pixel-wizard` Step 18, this procedure runs in **embedded mode** with two caller-passed inputs:

- `scope`: list of files from the caller's Execution Log (HW/pixel-wizard) or QW plan execution
- `embedded_mode=true`: signals to skip standalone working-doc creation and write findings directly into the caller's plan Quality Review section (HW plan template's `## QUALITY REVIEW` heading)

Embedded mode flow: caller hands off control → this procedure runs Steps 1-8 with embedded behavior (Step 1 skips working-doc creation; Step 3 runs Scope Reconciliation; Steps 7-8 target the caller's plan) → caller resumes its next step.

---

## Procedure

### Step 1: Read Template + Create Working Document (Mode-Branched)

Read the [Code Quality Analysis Template](//@agent-memory/control-files/plan-templates/code-quality-analysis-template.md) — used as a read-only checklist reference in both modes.

**Mode branch**:

- **Standalone mode** (no `embedded_mode` arg): Copy the template to a working document at the project's plans folder, then fill its Analysis Info section.
  ```
  cp {source} ./plans/[YYYY-MM-DD]-[project]-code-quality-analysis.md
  ```
  Fill the **Analysis Info** section (Project, Date, Agent, Scope, Quality Standard). This working doc IS the standalone audit trail.

- **Embedded mode** (`embedded_mode=true`, caller-passed from a wizard): **SKIP working-doc creation.** Findings will be written directly into the caller's plan Quality Review section (e.g., HW plan's `## QUALITY REVIEW` heading). The caller's plan IS the audit trail. No standalone analysis doc is created.
  - The caller's plan already has its own Project Info section (Project, Date, Agent) — no separate Analysis Info needed.
  - Capture `scope` (file list from caller) for use in Step 2.
  - Capture `embedded_mode=true` flag for use in Steps 3, 7, 8 (Scope Reconciliation runs only in embedded mode; Steps 7-8 target caller's plan instead of standalone Resolution Log).

### Step 2: Determine Scope

Resolve the scope to a concrete list of files to review:
- **File paths / directory**: Use directly
- **Feature description**: Identify related files via grep/glob
- **Git-based**: Use `git diff --name-only HEAD~1` (or appropriate range) to get changed files
- **Milestone**: Identify all files created/modified during the milestone

List the files that will be reviewed. If the scope resolves to more than 20 files, ask [USER-NAME] if they want to narrow it down or proceed with the full scope.

### Step 3: Scope Reconciliation (Embedded Mode Only)

*Runs only when `embedded_mode=true`. Standalone mode skips this step and proceeds directly to Step 4.*

When called from a wizard, the caller-passed `scope` (from its Execution Log) is the **authoritative intent**. Git diff is the **ground truth** (what actually changed on disk). Discrepancies need [USER-NAME] reconciliation before review proceeds — the agent never silently includes or excludes files.

**Algorithm**:

1. **Skip if standalone**: If `embedded_mode` is not set, skip this step entirely. Proceed to Step 4.

2. **Run git diff** to capture actual changed files in the workspace:
   ```
   git diff --name-only
   ```
   Capture as `actual_changed`.

3. **Compute discrepancy sets** against the caller-passed scope:
   - `in_diff_not_in_scope = actual_changed - caller_scope` (files changed on disk but not logged)
   - `in_scope_not_in_diff = caller_scope - actual_changed` (files logged as touched but show no diff)

4. **If both sets are empty**: no discrepancy. Silently proceed to Step 4 with `final_scope = caller_scope`.

5. **If either set is non-empty**, surface to [USER-NAME] before continuing:

   **Case A — `in_diff_not_in_scope` non-empty** (files changed but NOT in Execution Log):
   ```
   The following files changed on disk but weren't recorded in the Execution Log:
   [list]

   Include them in this quality review?
   A) Yes — add to scope
   B) No — skip them (review only Execution Log files)
   C) Review each one — I'll ask file by file
   ```

   **Case B — `in_scope_not_in_diff` non-empty** (files in Execution Log but NOT in git diff):
   ```
   The following files were logged as touched but show no git diff:
   [list]

   Likely causes: missed log update, reverted edit, or staged-but-not-committed.
   Proceed without these in scope?
   A) Yes — they're correctly not in review scope
   B) Re-check — I'll re-investigate why these aren't showing in diff
   ```

   If both cases apply, present both prompts sequentially.

6. **Apply [USER-NAME]'s reconciliation** to produce `final_scope`. Use `final_scope` for all subsequent steps (Step 5 Read Files in Scope, Step 6 Analyze Quality Dimensions, etc.).

STOP at the prompts above if either case fires. Wait for [USER-NAME]'s response before proceeding to Step 4.

### Step 4: Discover Quality Standard

Search for a project quality standard via glob: `**/quality-standard.md`

- **If found**: Read the quality standard file. Update the Analysis Info section with the path (standalone mode) or note the path for use in Dimension 8 (embedded mode — no Analysis Info doc). This will be used in Dimension 8 (Project Quality Standard Compliance) of the analysis.
- **If not found**: Note "None — freeform analysis" (standalone: in Analysis Info; embedded: in caller's plan Quality Review section). Skip Dimension 8 during analysis.

### Step 5: Read Files in Scope

Read all files identified in Step 2 (standalone) or reconciled in Step 3 (`final_scope`, embedded). For each file, understand:
- What the code does (purpose and context)
- How it integrates with surrounding code
- What patterns and conventions are used

### Step 6: Analyze Quality Dimensions

Walk through each quality dimension in the [Code Quality Analysis Template](//@agent-memory/control-files/plan-templates/code-quality-analysis-template.md). For each dimension:

1. **Evaluate**: Check each item in the dimension against the code in scope
2. **Mark**: Check off items that pass (`[x]`), leave unchecked items that fail or don't apply
3. **Document findings**: For each failed check, add a row to the **Findings** table with:
   - Severity: **Critical** (bugs, data loss, security), **Medium** (UX gaps, maintainability), **Low** (polish, cleanup)
   - File and line reference
   - Description of the issue
   - 2-3 fix options where meaningful, or single recommended fix for straightforward issues

**Skip dimensions that don't apply** to the scope (e.g., skip "State Completeness" for backend-only code, skip "Security" for a CSS-only change).

**Use judgment beyond the checklist** — the dimensions are guidelines, not an exhaustive list. If you spot an issue that doesn't fit any dimension, document it anyway.

**Findings storage target**:
- **Standalone**: write findings into the working document's Findings table
- **Embedded**: write findings into the caller's plan `## QUALITY REVIEW` section (Findings field — mirrors the same table shape)

### Step 7: Present Findings

Present findings to [USER-NAME] using the [WAIT Options Quality Review variant](//@agent-memory/control-files/procedures/wait-options.md#quality-review-variant).
Preamble: "Code quality review for [scope]:"

STOP. Wait for [USER-NAME]'s response before fixing anything.

**If no findings**, report and proceed:
```
Quality looks good — no findings for [scope]. Proceeding.
```

**Mode-specific note**:
- **Standalone**: WAIT Options section is filled in the standalone working document before presenting
- **Embedded**: WAIT Options are presented inline (no separate working doc); findings already written into caller's plan Quality Review section from Step 6

### Step 8: Fix Approved Items

After [USER-NAME] responds:
- **"fix all"**: Apply all recommended fixes (option A for each finding) in one pass
- **Selective**: Apply only the approved fixes, skip the rest
- **"ship it"**: Skip all fixes, proceed

Fix all approved items in a single batch. After fixing:

1. **Update the Resolution Log**:
   - **Standalone**: update the **Resolution Log** in the standalone working document with what was decided and done
   - **Embedded**: update the **Fixed** field in the caller's plan `## QUALITY REVIEW` section with what was fixed
2. **Briefly report** what was changed to [USER-NAME]

**Embedded mode return**: After Step 8 completes, control returns to the wizard caller (HW Step 16, QW Step 7, or pixel-wizard Step 18), which then proceeds to its next step (Final Integration Test).

---
