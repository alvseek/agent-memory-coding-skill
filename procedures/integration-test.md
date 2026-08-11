# Integration Test

Run runtime verification through the qa/ instrument — execute the R/I/A/O loop per touched module to verify the system runs end-to-end. Closes the loop on *"does it actually work?"*.

- **Standalone**: invoke directly after manual changes, bug fixes, or pre-deploy checks to verify runtime behavior on a scope.
- **Embedded (wizard-delegated)**: called by `/high-wizard` Step 17, `/quick-wizard` Step 8, and `/pixel-wizard` Step 19 as the "Final Integration Test" step in their lifecycle.

## Arguments

`$ARGUMENTS`

### Standalone invocation (user-invoked)

- `/integration-test [scope]` → Run integration tests on the given scope of touched modules
- `/integration-test` → Will ask for scope

**Scope examples:**
- Module names: `auth`, `api`, `worker`
- File paths: `src/auth/login.ts`, `src/api/users.ts`
- Git-based: `all changes since last commit`

If no arguments provided, ask: "What scope should I run integration tests on? (module names, file paths, or 'all changes since last commit')"

### Embedded invocation (wizard-delegated)

When called from `/high-wizard` Step 17, `/quick-wizard` Step 8, or `/pixel-wizard` Step 19, this procedure runs in **embedded mode** with two caller-passed inputs:

- `scope`: list of files from the caller's Execution Log (HW/pixel-wizard) or QW plan execution
- `embedded_mode=true`: signals to write results into the caller's plan `## FINAL INTEGRATION TEST` section (where the wizard step is labeled "Final Integration Test" — "final" is the wizard's positional descriptor, not a property of this procedure itself)

Embedded mode flow: caller hands off control → this procedure runs the R/I/A/O loop → results embedded in caller's plan → caller resumes its next step.

---

## Procedure

### Step 1: Detect qa/ Instrument

Check for a `qa/runbooks/` directory (the per-module **runbook** tier marks a present instrument).

- **If missing**: STOP. Present to [USER-NAME]:
  ```
  No qa/ instrument detected for this project.
  A) Run /setup-qa-instrument now to build it (recommended)
  B) Skip integration test (log decision)
  ```
  - If A: invoke `/setup-qa-instrument`, then return here.
  - If B: log the skip:
    - **Standalone mode**: report `"Integration test skipped — no qa/ instrument"` to [USER-NAME] and end.
    - **Embedded mode**: write `"Final Integration Test skipped — no qa/ instrument"` into caller's plan `## FINAL INTEGRATION TEST` section, then return control to caller.

### Step 2: Identify Touched Modules

From the scope (caller-passed in embedded mode, or asked in standalone mode), map each file to its qa/ runbook by matching directory or module name. Surface any files that don't map to a runbook — flag as *"no runbook coverage"* in the report/log.

### Step 3: Run R/I/A/O Loop Per Module

**Resolve scripts by category header, not filename.** Scan `qa/scripts/*`, read each script's `# R/I/A/O category:` header, and map it to its phase (RESET/INJECT/ACT/OBSERVE). Do NOT assume filenames like `reset-*` — a project's scripts may be named `teardown` / `import-seed` / `start-stack` / `smoke-check`; the header is the contract.

For each touched module's runbook, run the full loop:

- **a.** Read `qa/runbooks/{module}.md`
- **b.** Execute the **RESET**-category script (RESET to clean state)
- **c.** Execute the **INJECT**-category script (INJECT test data)
- **d.** Execute the **ACT**-category script (ACT — bring stack up)
- **e.** Execute the runbook's Act-section scenarios (per runbook instructions)
- **f.** Execute the **OBSERVE**-category script (OBSERVE)
- **g.** Compare results against the runbook's Observe-section expectations

**Cross-module scope**: if the touched files span multiple modules (or the change is inherently cross-cutting), also run the **playbook** (`qa/playbook.md`) — its Full-System Boot Order, Full-System Smoke, and any End-to-End Scenarios covering the touched paths. Runbooks verify each module in isolation; the playbook verifies they still work *connected*.

### Step 4: Present Findings

Any failure becomes a **Critical** finding. Present by invoking the `/wait-options` command procedure — run the command; its format rules are not in context.
Preamble: *"Runtime verification findings:"*

**STOP**. Wait for [USER-NAME]'s response.

If no findings, report: *"Integration test passed — runtime clean."*

### Step 5: Fix Cycle

Apply approved fixes in one batch. Re-run R/I/A/O loop (Step 3) for affected modules. Repeat until clean or [USER-NAME] explicitly defers remaining items.

### Step 6: Log Results

- **Standalone mode**: Report results inline to [USER-NAME]:
  - Touched modules + runbooks run
  - Playbook run (if cross-module): result, or N/A
  - qa/ Status (detected / skipped)
  - R/I/A/O loop results per module (pass/fail)
  - Findings + Fixed

- **Embedded mode**: Write results into caller's plan `## FINAL INTEGRATION TEST` section:
  - **Scope**: touched modules
  - **qa/ Status**: detected / missing / skipped
  - **Runbooks Run**: list of `qa/runbooks/{module}.md` exercised
  - **Playbook Run**: `qa/playbook.md` if cross-module (boot order + full-system smoke + E2E scenarios), or N/A
  - **R/I/A/O Results**: per-module pass/fail summary
  - **Findings**: runtime failures + severity, or *"No findings — runtime clean"*
  - **Fixed**: what was fixed from approved findings, or *"N/A"*

**Embedded mode return**: After Step 6, control returns to the wizard caller (HW Step 17, QW Step 8, or pixel-wizard Step 19), which then proceeds to its next step (Move to Completed or Report Completion).
