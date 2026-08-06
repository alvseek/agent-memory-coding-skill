# Pixel Wizard Protocol

Execute visual design-to-implementation planning with screenshot-based validation — equal to `/high-wizard` in structure, with three visual additions: (1) auto-screenshot the design source, (2) ensure visual testing framework is set up, (3) iterate implementation against the design visually until match.

Use this instead of `/high-wizard` when working from a visual design reference (`.html` file or image).

## Arguments

`$ARGUMENTS`

- `/pixel-wizard [context]` → Create Pixel Wizard plan for the given context
- `/pixel-wizard` → Will ask for context

If no arguments provided, ask: "What feature or task should I create a Pixel Wizard plan for? Please provide the design reference (.html file or image path)."

---

## Procedure

*IMPORTANT: This procedure structurally enforces UUID f3a8b2c1 (VERIFY FIRST) - the agent MUST collect and confirm decisions BEFORE writing any plan sections. Writing ahead on assumptions is prohibited.*

*This procedure is split into 3 phases. Each phase ends with a STOP gate. Do NOT read ahead into later phases — complete and confirm the current phase before proceeding.*

---

## Phase 1: Discovery & Planning Frame

*Goal: Establish visual target, investigate the task, collect decisions, frame objectives/scope, and get early confirmation before any solution writing.*

### Step 1: Read Template

Read the [High Wizard Plan Template](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md) file

### Step 2: Visual Design Gate

⛔ **GATE**: Pixel Wizard requires a visual design reference. Check if a `.html` file path or image file path (`.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`) is present in the request context.

**If NO visual reference found:**
> "Pixel Wizard requires a visual design reference (`.html` file or image). Please provide one, or use `/high-wizard` or `/quick-wizard` instead."

STOP. Do NOT proceed without a visual reference.

**If `.html` file provided:**
1. Create `.agent-screenshots/` directory at project root if it does not exist
2. Use Playwright MCP to open and screenshot the file:
   - `mcp__playwright__browser_navigate` → `file://{absolute-path-to-html-file}`
   - `mcp__playwright__browser_take_screenshot` → save to `.agent-screenshots/design.png`
3. Read `.agent-screenshots/design.png` into context — this is the **visual target**
4. Confirm: "Visual target established from `{filename}` → `.agent-screenshots/design.png`"

**If image file provided (`.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`):**
1. Read the image file directly via the Read tool — this is the **visual target**
2. Create `.agent-screenshots/` directory at project root if it does not exist
3. Confirm: "Visual target established from `{filename}` (loaded directly)"

### Step 3: Check Date

Get current date for file naming:
`date '+%Y-%m-%d %H:%M'`

### Step 4: Copy Template

Copy the template file to the `/plans` folder with the final name:
`cp {source} ./plans/[YYYY-MM-DD]-[project]-[theme].md`

### Step 5: Fill Project Info

Fill the [Project Info](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#project-info) section only (Project, Date, Agent, Theme). Note the visual reference in the Theme field: e.g., `Theme: ... (visual ref: design.html)`

### Step 6: Investigate and Collect Decisions

This is where the thinking happens - NOT in the plan document. Follow the investigation checklist below IN ORDER. Each step from 3-6 produces decision items for the WAIT Options form.

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting decisions.

**Investigation checklist (in order):**

1. **Requirements clarity** - Is the intent already clear? Is there ambiguity within the context? If ambiguous, create decisions to clarify before proceeding
2. **Codebase scan** - Scan relevant files, modules, and architecture related to the task to understand current state
3. **Alternative approaches** - Based on the requirement, discover what ways this can be done (there's usually more than one) → offer as decisions
4. **Reusable components** - Identify existing functions, utilities, patterns that could be leveraged → offer to reuse the related/reusable ones as decisions
5. **Conflicts and constraints** - Note what could go wrong, what limits exist → if any, offer options based on pros and cons as decisions
6. **Integration points** - Check what existing code/systems will be affected → if concerning, offer options as decisions
7. **Quality standard discovery** - Search for `quality-standard.md` in the project via glob (`**/quality-standard.md`). If found, load it as additional implementation criteria to reference when writing plan steps. If not found, note it and proceed
8. **Visual framework check**: Check if visual testing framework is already configured by reading `.env.local`:
   - **Web projects**: look for `SCREENSHOT_URL`
   - **Mobile projects**: look for `SCREENSHOT_CMD`
   If not found, run `/setup-qa-visual-instrument` now before Step 7. The framework must be set up before implementation begins.

### Step 7: Present WAIT Options

Present the WAIT Options form to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "I've investigated the codebase. Here are the decisions I need before planning"

STOP. Present to [USER-NAME] for review. Do NOT write any plan sections until decisions are confirmed.

### Step 8: Fill Objectives + Success Criteria

Fill the [Objectives](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#objectives) and [Success Criteria](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#success-criteria) sections.

Add to Success Criteria:
- `[ ] Visual output matches design reference (confirmed via screenshot comparison)`

### Step 9: Fill Scope

Fill the [Scope](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#scope) section (In Scope / Out of Scope)

### Step 10: Fill Confirmed Decisions

Record all confirmed decisions (with any changes [USER-NAME] made) in the [Confirmed Decisions](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#confirmed-decisions) section. Include the meaningful reasons - this IS the analysis record.

### Step 11: Early Review

Present objectives, scope, and confirmed decisions to [USER-NAME]. Then propose which optional plan sections to include based on investigation findings.

**Optional sections (lettered)** — propose based on task context:
- **A) Integration Architecture** — Propose when: multi-system changes, multiple components interacting
- **B) System Flow Diagrams** — Propose when: changing data/process flow, API changes, sequence changes
- **C) Technical Considerations** — Propose when: significant technical constraints, limitations, or dependencies exist
- **D) Detailed Analysis** — Propose when: investigation/analysis-focused tasks, unclear objectives needing deep examination
- **E) Bug Investigation** — Propose when: bug fix, debugging, error investigation, unexpected behavior analysis
- **F) Solution Options & Evaluation** — Propose when: brainstorming/decision tasks, multiple viable approaches need evaluation, architecture decisions
- **G) ADR Output** — Propose when: F is included AND the decision has architectural significance worth documenting separately

**Response format:**
```
[Present objectives, scope, and confirmed decisions as before]

Based on the task, I'll include these optional plan sections:
[x] A) Integration Architecture (reason: ...)
[ ] B) System Flow Diagrams (reason: not needed because ...)
[x] C) Technical Considerations (reason: ...)
[ ] D) Detailed Analysis (reason: not needed because ...)
[ ] E) Bug Investigation (reason: not needed because ...)
[ ] F) Solution Options & Evaluation (reason: not needed because ...)
[ ] G) ADR Output (reason: not needed because ...)

Add or remove any? Or proceed.
```

### ⛔ END OF PHASE 1

STOP. Present Step 11 to [USER-NAME] for review. Do NOT write the solution until confirmed to avoid cascading changes when this section needs adjustment.

**Phase 2 requires [USER-NAME]'s explicit confirmation of the Early Review (objectives, scope, confirmed decisions, and optional sections). Do NOT proceed until confirmed.**

---

## Phase 2: Solution Design

*Goal: Write the solution and implementation phases based on confirmed decisions, then self-review and present for final approval.*

*⛔ Prerequisite: Phase 1 (Early Review) MUST be confirmed by [USER-NAME] before starting this phase.*

### Step 12: Fill Solution

Fill the [Solution](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#solution) section. Build directly from confirmed decisions.

**Optional sections**: Only fill the optional sections (A-G) that were confirmed in Step 11. Remove unconfirmed optional section markers and their placeholder content from the plan file — do not leave empty optional sections.

**ADR file creation**: If section G is confirmed, after filling all plan sections:
1. Copy the [ADR Template](//@agent-memory/control-files/templates/adr-template.md) to the project's ADR location
2. Fill it using content from section F (Solution Options & Evaluation) and the Confirmed Decisions table
3. Link the ADR back to this plan file
4. Update the plan's section G with the ADR file path

**CRITICAL**: If any NEW decision is discovered during writing that was not covered in Step 7, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

### Step 13: Fill Implementation Phases

Fill the [Implementation Phases](//@agent-memory/control-files/plan-templates/high-wizard-plan-template.md#implementation-phases) section.

**CRITICAL**: Same rule - if any NEW decision is discovered during writing, STOP immediately and present it before continuing.

### Step 14: Self-Review + Auto-Fix

Do a self-review by thinking critically:
- a. Is there anything missing that should be in scope?
- b. Is there anything that should be out of scope?
- c. Is there any conflict between confirmed decisions and the solution/implementation?
- d. Is there anything redundant?
- e. Are implementation phases in the right order?

**If issues are found**: Auto-fix consistency issues (conflicts, redundancies, ordering) directly in the plan file. For issues that require a NEW decision (scope changes, missing requirements), STOP and present to [USER-NAME] using the WAIT Options format before continuing.

**Report**: Briefly list any auto-fixes made. If no issues found, proceed silently to Step 15.

### Step 15: Final Review

Before presenting the plan, double check: are there any unresolved decisions, assumptions, or new concerns that surfaced during writing (Steps 12-13) or self-review (Step 14) that need [USER-NAME]'s input? If yes, present them now with the same decision format (options + confidence + reason).

Present the complete plan file link to [USER-NAME] for final review.

### ⛔ END OF PHASE 2

STOP. Wait for [USER-NAME]'s instruction to proceed to implementation.

**Phase 3 requires [USER-NAME]'s explicit instruction to start implementing. Do NOT proceed until instructed.**

---

## Phase 3: Implementation & Closure

*Goal: Execute the plan, validate visually, review quality, archive, and wrap up.*

*⛔ Prerequisite: Phase 2 (Final Review) MUST be confirmed by [USER-NAME] before starting this phase.*

### Step 16: Start Implementation

After [USER-NAME] instructs to start implementing, start implementing following the **Execution Protocol for AI** from the plan file.

### Step 17: Visual Iteration Loop

After all implementation phases are complete:

1. **Check device/emulator connection** (mobile projects only):
   - Flutter: `flutter devices` — if no device listed, warn [USER-NAME]: "No Flutter device connected. Please start your emulator or connect a device before I can take a screenshot."
   - Android: `adb devices` — if no device listed, warn [USER-NAME] similarly
   - iOS: `xcrun simctl list booted` — if no booted simulator, warn [USER-NAME] similarly
   - Web: `curl -s -o /dev/null -w "%{http_code}" {SCREENSHOT_URL}` — if no response or non-2xx, warn [USER-NAME]: "Dev server not responding at {URL}. Please start your dev server before I can take a screenshot."

2. **Read configuration from `.env.local`**:
   - **Web**: read `SCREENSHOT_URL`
   - **Mobile**: read `SCREENSHOT_CMD` (and `SCREENSHOT_URL` if applicable)

3. **Run screenshot**:
   - **Web**: use Playwright MCP:
     - `mcp__playwright__browser_navigate` → `{SCREENSHOT_URL}`
     - (if auth required per `/setup-qa-visual-instrument` Step 4 C2: perform login flow first)
     - `mcp__playwright__browser_take_screenshot` → `.agent-screenshots/result.png`
   - **Mobile**: execute `SCREENSHOT_CMD` → `.agent-screenshots/result.png`

4. **Visual comparison**: Read both `.agent-screenshots/design.png` and `.agent-screenshots/result.png` side by side.

   **Precondition**: both screenshots must share the same viewport/canvas size. If they differ, re-take with matching dimensions before comparing — size mismatch invalidates all layout judgment.

   Compare **zone by zone** (top → bottom, left → right), not holistically. For each zone, walk this checklist:

   - **a. Element inventory** — every design element exists in result; no extra elements; correct order, grouping, and nesting (cards, panels, dividers)
   - **b. Text content** — labels, placeholders, button text, links verbatim; casing matches
   - **c. Typography** — font family category (serif/sans/mono/display), weight, relative size hierarchy, text color role
   - **d. Layout & spacing** — alignment (left/center/right; edges that should line up), relative proportions (element width/height vs container), spacing rhythm (which gaps are larger/smaller than which)
   - **e. Color & style** — background layer colors, accent colors and their roles, borders, shadows, gradients, opacity
   - **f. Shape language** — corner radius category (sharp/rounded/pill/circle), border thickness, icon style (outline vs filled)
   - **g. States & affordances** — empty vs filled inputs, masked fields, visibility toggles, disabled/active styling, focus states if captured

   **Confidence rules** — tag every gap found with confidence:
   - Element-level diffs (a, b, g): HIGH confidence — trust visual reading.
   - Categorical style diffs (c, f): HIGH at category level (serif vs sans, pill vs rounded), LOW at metric level (exact pt size, exact radius px).
   - Shade-level color and px-level spacing (d, e): LOW confidence — do NOT judge from pixels alone. Verify in code instead: read the implemented values and compare against the design source (`.html` reference, design tokens, or spec). If no exact spec exists, mark "unverifiable visually" rather than declaring a match.

   List the gaps found, grouped by zone, tagged with checklist letter and confidence — this list is the fix queue for step 5. Gaps marked "unverifiable visually" are excluded from iteration; carry them to the Step 21 completion report instead of looping on them.

5. **Iterate**:
   - If gaps exist → fix the relevant code → go back to step 3
   - If no gaps (or gaps are negligible) → confirm: "Visual match confirmed. Proceeding to quality review."
   - **Max 3 iterations**: If gaps persist after 3 rounds, report to [USER-NAME]: "After 3 iterations I'm unable to fully close the gap. Current differences: [describe]. Would you like me to continue, adjust the target, or proceed to quality review as-is?"

### Step 18: Quality Review (Delegated to `/analyze-code-quality`)

After all implementation phases are done and logged (and visual match confirmed at Step 17), run **static** code quality review by delegating to `/analyze-code-quality` in embedded mode. Findings are embedded directly into this plan's `## QUALITY REVIEW` section — the plan IS the audit trail.

1. **Collect scope**: Identify all files created or modified during implementation from this plan's Execution Log. This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/analyze-code-quality`** following the [Analyze Code Quality procedure](//@agent-memory/control-files/procedures/analyze-code-quality.md) with these inputs:
   - `scope`: the file list collected above (from Execution Log)
   - `embedded_mode=true`: signals the procedure to skip standalone working-doc creation; findings get embedded into this plan's Quality Review section

The delegated procedure will:
- Run **Scope Reconciliation** (its Step 3) — surface any git-diff vs Execution Log discrepancies for [USER-NAME] to reconcile
- **Discover quality standard** (its Step 4) — looks for `**/quality-standard.md`; if found, applies Dimension 8; if not, freeform
- Walk quality dimensions against the reconciled scope (its Steps 5-6)
- Present findings via [WAIT Options Quality Review variant](//@agent-memory/control-files/procedures/wait-options.md#quality-review-variant) (its Step 7) — preamble: *"Code quality review for implementation:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and update this plan's Quality Review section (its Step 8)

3. **Resume control** here after `/analyze-code-quality` completes. Proceed to Step 19 (Final Integration Test).

### Step 19: Final Integration Test (Delegated to `/integration-test`)

After Quality Review is resolved (Step 18), run **runtime** verification by delegating to `/integration-test` in embedded mode. Results are embedded directly into this plan's `## FINAL INTEGRATION TEST` section — static quality review (Step 18) answered "is the code clean?"; this step answers "does it actually work?".

1. **Collect scope**: Identify all files created or modified during implementation from this plan's Execution Log. This file list is the **caller-passed scope** for the delegated procedure.

2. **Invoke `/integration-test`** following the [Integration Test procedure](//@agent-memory/control-files/procedures/integration-test.md) with these inputs:
   - `scope`: the file list collected above (from Execution Log)
   - `embedded_mode=true`: signals the procedure to write results into this plan's Final Integration Test section

The delegated procedure will:
- **Detect qa/ instrument** (its Step 1) — stop + offer `/setup-qa-instrument` if missing
- **Identify touched modules** and map to playbooks (its Step 2)
- **Run R/I/A/O loop per module** (its Step 3): reset → seed → start → act scenarios → smoke → compare
- Present findings via [WAIT Options Quality Review variant](//@agent-memory/control-files/procedures/wait-options.md#quality-review-variant) (its Step 4) — preamble: *"Runtime verification findings:"*
- **STOP** at the WAIT Options prompt — wait for [USER-NAME]'s response
- Apply approved fixes and re-run affected modules (its Step 5)
- Log results into this plan's `## FINAL INTEGRATION TEST` section (its Step 6)

3. **Resume control** here after `/integration-test` completes. Proceed to Step 20 (Move Plan to Completed).

### Step 20: Move Plan to Completed

After all implementation phases are done, logged, and both Quality Review (Step 18) + Final Integration Test (Step 19) are resolved, move the plan file to `/plans/completed/`:
`mkdir -p ./plans/completed && mv ./plans/[plan-file].md ./plans/completed/[plan-file].md`

**Note**: Episodic memory links to the plan will break after moving. This is accepted — completed plans are archival.

### Step 21: Completion Report

Present a brief completion report to [USER-NAME]:
- Plan file location (in `/plans/completed/`)
- Summary of what was implemented
- Visual match status
- Quality Review status (clean / N findings fixed)
- Final Integration Test status (clean / N runtime failures fixed / skipped — no qa/)
- Any notes or follow-ups worth mentioning

Then offer: "Would you like me to run `/wrap-up` to close the session?"

### ⛔ END OF PHASE 3

Protocol complete.

---
