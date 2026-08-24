# Generate QA Checklist

Build the per-feature verification checklist for a change that just shipped — the artifact that answers *"is it actually right?"*, later, by a human, with the stack up.

This is the wizards' **QA Handoff** step (HW 17 / QW 8 / pixel 19), the last thing a sweep does before archiving its plan, and it runs standalone against any change set just as well. Its scope is one artifact: `qa/checklists/{feature}.md`. The rest of the test layer — runbooks, the playbook, fixtures, and the Act/Observe scenarios inside them — belongs to `/build-qa-test`; the rig they all run on belongs to `/build-qa-bench`; walking the checklist and recording what happened belongs to `/run-qa-test`.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the 7 artifact categories, the ownership split, and the `documented / tribal / missing` grading. This skill references *up* to it; it does not restate them.

> **The wizard does not verify; it hands off.** A sweep is a coding session with the QA stack almost certainly down, so it produces the verification *plan* and leaves the verification itself to `/run-qa-test` in a session where the stack is up. That makes this checklist the sweep's only QA output — if it's thin or restates the plan, the feature effectively ships unverified.

> **Built per-feature, never up front.** A checklist only has meaning relative to a shipped change, so there is no mode that scaffolds them in advance — an empty `qa/checklists/` reads as coverage to everyone who sees it.

## Arguments

`$ARGUMENTS`

- `/generate-qa-checklist [plan]` → build the checklist for the change that plan describes. This is the form a wizard passes, with its own plan file as the argument.
- `/generate-qa-checklist` → no plan: work from the current change set (`git diff`), and ask which shipped feature it represents if that isn't obvious from the diff.

---

## Gate: Is the QA Instrument Set Up?

*Goal: confirm this project has opted into the QA ontology — and never block if it hasn't.*

Because a wizard invokes this mid-sweep, a blocking prompt here would stall an automated flow. So the gate checks exactly one thing and always resolves without asking: **is the QA instrument set up at all?** That means both a `qa/qa-map.md` from `/map-qa-instrument` **and** a built bench from `/build-qa-bench`.

- **Both present** → read the map, note which checklists already exist (active and in `completed/`) so this run extends the picture rather than duplicating it, then proceed to Step 1.
- **Either absent** → **notify loudly and auto-skip.** Do not prompt, do not build:

  ```
  ⚠️ QA instrument not set up — checklist SKIPPED.
     Missing: [no qa/qa-map.md | bench not built | both]
     To enable: /map-qa-instrument create  →  /build-qa-bench
  ```

  Return the skip and its reason to the caller, which a wizard records in its plan's `## QA HANDOFF` section. Never invent a `qa/` folder for a project that hasn't opted into the ontology — a checklist appearing in a repo with no QA instrument is an artifact nobody agreed to own.

> **The bench requirement is about opt-in, not capability.** A checklist is human-runnable and would work fine without a scripted loop; the gate exists so that *"this project uses this QA system"* is one unambiguous condition rather than a judgment call made differently each run.

---

## Procedure

### Step 1: Read the plan for SCOPE

Read the plan (or the change set, if no plan). Extract only **what changed**:

- the modules and apps touched, and which are *not* touched
- the acceptance criteria and any contracts the plan pinned
- what the plan claims is already covered by automated tests

This is the **input**, not the authority. The plan tells you where to look; it does not tell you what to check.

### Step 2: Derive RISK independently

Now work out what the change could **break**. This is the half a plan cannot give you, and it is the reason the checklist exists.

Draw on:
- **Invariants** — state rules that must hold before and after. Write each as *a thing to disprove*, not a thing to confirm.
- **Regression surface** — what else reads or writes the same state, and what the change could have silently altered for it.
- **Boundaries and error paths** — empty, zero, already-in-that-state, concurrent, and the failure branch nobody exercised.
- **Cross-module effects** — what downstream consumers assume about the data this change now produces differently.
- **History** — prior checklists in `qa/checklists/completed/` and past defects in this area. Bugs cluster.

> **Why this step is non-negotiable.** The author of a change cannot see the case they didn't think of — if they had, they'd have coded it. A checklist derived only from the plan tests that the developer did what they said, not that the system still works, so every item passes by construction. Two shapes, to make the difference concrete:
>
> | | |
> |---|---|
> | Plan-restating | *"Confirm auto-checklab creates a pending lab request."* — restates the feature |
> | Risk-derived | *"Verify `FishInDate` is not nulled by release or unhold."* — probes what the feature could have broken |

### Step 3: Write the checklist

Use the [Checklist template](#checklist-template) at `qa/checklists/{feature}.md`.

- Lead with a **terminology / state-model block** if the change turns on states a tester must hold in their head.
- Give a **single happy-path scenario first** that walks the whole change end to end, then per-area sections to isolate a failure.
- Mark each item **automated** (naming the test) or **manual**, so nobody re-runs by hand what CI already proves, and nobody assumes the automated half covers the manual half.
- Note which items are UI-bound — those are the ones an all-green automated run does **not** cover.
- Leave `## Result` as the template's *"not yet run"* placeholder. `/run-qa-test` owns it.

> **A coverage row must be scoped to what the test can actually *fail on*, not to what it asserts.** The two differ whenever a test reconstructs a production sequence by hand instead of calling it: the assertions pass, but a change to the real caller — a branch rewired, a step dropped — leaves the test green. Before writing a row, ask *"what edit to production code would break this feature and NOT break this test?"* Anything on that list belongs in the **Still manual** column. An em-dash there is a strong claim: it says an all-green run leaves nothing unchecked for this item.

### Step 4: Report

Feature, source plan, item count split automated vs manual, and the pointer to `/run-qa-test --checklist qa/checklists/{feature}.md`.

## Templates

### Checklist template

File: `qa/checklists/{feature}.md` → archived to `completed/` on sign-off.

```markdown
# {Feature} — QA Checklist

**Source**: <plan or change set this verifies>
**Purpose**: <what a tester confirms by running this>
**Apps under test**: <modules touched — and note what is deliberately NOT touched>

## Terminology & state model (read first)
<only if the change turns on states the tester must hold in their head>

**Key invariants** (each is a thing to *disprove*):
- <invariant>

## Happy path — single end-to-end scenario (run this first)
<numbered walk of the whole change; each step points at its detailed section below>

## Automated coverage
| Checklist item | Automated test | Still manual |
|---|---|---|

## Checks
- [ ] <observable behavior + expected result>
- [ ] <edge case / error path + expected result>

## Result

*Not yet run. `/run-qa-test --checklist` writes this section — see its Run record.*
```

> **`## Result` is created empty here and written only by `/run-qa-test`.** This skill builds the checklist; the runner records what happened to it. Keep the placeholder line in — an absent section reads as "this checklist has no result yet defined", while an explicit *"not yet run"* is a fact a reader can act on. One writer per section is what stops the record from drifting.

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Canonical home for the loop, the artifact ontology, the ownership split and the grading; its map's **Checklists** row names this skill as the owner.
- **/build-qa-test** — sibling. Owns the rest of the test layer: runbooks, the playbook, fixtures, and the scenarios inside them. The two never overlap — a checklist is per-feature and ephemeral, everything there is per-flow and evergreen.
- **/build-qa-bench** — upstream. Builds the rig whose existence this skill's gate reads as the project's opt-in signal.
- **/run-qa-test** — downstream. Walks the finished checklist (`--checklist`), writes its `## Result`, and offers the archive on sign-off. This skill never writes that section.
- **/high-wizard · /quick-wizard · /pixel-wizard** — callers. Each delegates here as its **QA Handoff** step (HW 17 / QW 8 / pixel 19), automatically and without prompting, then records the checklist path or the auto-skip reason in the plan's `## QA HANDOFF` section.

---

## Anti-Patterns

1. **Restating the plan.** A checklist whose every item mirrors an acceptance criterion tests only that the developer did what they said, so it passes by construction. The items that earn their place probe what the change could have broken.
2. **Claiming automated coverage a test cannot fail on.** The Automated column is a falsifiable claim, not a citation. If an edit to production code could break the feature and leave that test green, the row is still manual.
3. **Scaffolding an empty `qa/checklists/`.** An empty folder reads as "we have checklists" to everyone who sees it. Build per-feature or build nothing.
4. **Vague expectations.** *"Works correctly"* cannot fail, so it can never catch a regression. Write the exact observable delta.
5. **Writing `## Result`.** That section belongs to `/run-qa-test` alone. Leave the template's *"not yet run"* placeholder exactly as it stands — two writers on one section is how a record starts lying.
6. **Building anything else.** Fixtures, runbooks, scenarios and the playbook are `/build-qa-test`'s. If the feature needs one, name it and point there rather than quietly building half a test layer.
