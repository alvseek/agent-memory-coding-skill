# Forge of Covenant Protocol

Facilitate project vision definition and milestone roadmap planning through guided exploration and structured decision-making. The protocol flows as a PM facilitation discussion — using 7Q exploration to shape the vision, then WAIT Options at three phase gates for concrete decisions. The output is a living `grand-plan.md` that tracks milestones, deferrals, debt, and scope shifts across the project lifecycle.

## Arguments

`$ARGUMENTS`

- `/forge-of-covenant [project vision]` → Start Forge of Covenant for the given project
- `/forge-of-covenant` → Will ask for project vision

If no arguments provided, ask: "What project do you want to plan across multiple milestones?"

---

## Procedure

*This is a Level 4 wizard protocol — the highest level. It orchestrates milestones where each milestone can invoke `/rite-of-creation` (Level 3), `/council-of-wizards` (Level 2), `/high-wizard` (Level 1), or `/quick-wizard` (Level 0). The key flow is: Explore (7Q) → Decide (WAIT Options Round 1) → Plan (Roadmap + WAIT Options Round 2) → Detail (Milestones + WAIT Options Round 3) → Review → Execute.*

---

### Phase 1: EXPLORE

*Open-ended 7Q discussion to build shared understanding of the project before any decisions are collected.*

### Step 1: Read Template

Read the [Forge of Covenant Plan Template](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md) file

### Step 2: Check Date

Get current date for file naming:
`date '+%Y-%m-%d %H:%M'`

### Step 3: Create Covenant Folder + Copy Template

Create the covenant plan folder and copy the template as `grand-plan.md` inside it:
```
mkdir -p ./plans/[YYYY-MM-DD]-[project]-forge-of-covenant
cp {source} ./plans/[YYYY-MM-DD]-[project]-forge-of-covenant/grand-plan.md
```

### Step 4: Fill Project Header

Fill the [Project Header](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#project-header) section (Project, Date, Agent Role, Vision, Target Users, Success Feeling)

### Step 5: 7Q Exploration

This is the **exploration phase** — genuinely open-ended discussion, NOT structured options. The agent asks questions, listens, discusses, and builds shared understanding with [USER-NAME] before any decisions are collected.

**Ask these 7 questions one at a time or in natural groups, allowing discussion to flow:**

**Q1 — What Are We Building?**
"Tell me about the project. What's the core idea? What problem does it solve? Why does it need to exist?"
*(Let [USER-NAME] describe freely. Ask follow-up questions. Dig deeper into what excites them and why now.)*

**Q2 — Who's Involved?**
"Who will use this? Are there different types of users? Who makes the final call on scope? Who will build this? Anyone who could block or redirect?"
*(Map the audience and the people landscape. Primary users, secondary users, stakeholders, builders.)*

**Q3 — What Does Success Look Like?**
"Imagine the project is done and people are using it. What does that look like? What makes you proud? How will you measure success — what numbers or metrics would prove this is working?"
*(Connect to [USER-NAME]'s Success Feeling philosophy first, then move to quantitative KPIs.)*

**Q4 — What's The Technical Shape?**
"Will this have a backend? Frontend? Mobile app? APIs? Database? What's the technical landscape? What technologies are you thinking?"
*(Map the services, components, and tech stack. Each may appear across multiple milestones.)*

**Q5 — What Are The Boundaries?**
"Any timeline pressure? Budget limits? Technical constraints? Team size? Existing code to work with? What are the non-negotiable principles — things that must be true across every milestone?"
*(Understand constraints, timeline pressure, and covenant-level promises.)*

**Q6 — What Could Go Wrong?**
"What keeps you up at night? What are the biggest risks? Any dependencies on external things you don't control? What don't we know yet that could matter?"
*(Surface cross-milestone risks, external dependencies, and known unknowns early.)*

**Q7 — How Do We Ship This?**
"Do you want to ship incrementally? What would the first usable version look like? How many releases do you envision? What's the rough progression?"
*(Start thinking about milestones naturally. Let [USER-NAME] describe their ideal release progression.)*

**Guidelines for exploration:**
- These are DISCUSSION questions, not a form to fill. Follow the conversation naturally.
- Ask follow-up questions when answers are interesting or unclear.
- Capture key insights mentally — they will inform the WAIT Options in Step 6.
- Do NOT present structured options yet. This is pure exploration.
- Each Q maps directly to a template section — the answers will fill those sections in Step 7.

**After exploration**, the agent should have a rich understanding of:
- The project vision, motivation, and core idea (Q1)
- Target users, stakeholders, and team structure (Q2)
- Success feeling and measurable KPIs (Q3)
- Technical landscape and architecture shape (Q4)
- Constraints, principles, and timeline pressure (Q5)
- Risks, dependencies, and unknowns (Q6)
- Release strategy and milestone vision (Q7)

This understanding informs the WAIT Options in Step 6.

---

### Phase 2: DECIDE

*Convert exploration insights into concrete project-level decisions using WAIT Options Round 1.*

### Step 6: Prepare + Present Project WAIT Options (Round 1)

Based on the exploration discussion (Step 5), prepare concrete decisions that need to be confirmed before planning milestones. These are PROJECT-LEVEL decisions.

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting project-level decisions.

**Typical project-level decisions:**
- Tech stack choices (languages, frameworks, cloud provider)
- Architecture approach (monolith vs microservices, monorepo vs multi-repo)
- Number and rough scope of milestones
- MVP definition (what's in M1 vs deferred)
- Non-negotiable principles (CI/CD from M1, no launch without auth, etc.)
- Success metrics approach (which KPIs matter most, how to measure)
- Risk mitigation strategy (for any high-likelihood/high-impact risks identified)
- Timeline targets (rough dates per milestone)

Present the project decisions to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Based on our exploration, here are the project decisions I need to confirm (WAIT Options Round 1):"

STOP. Present to [USER-NAME] for review. Do NOT fill any tables or proceed until [USER-NAME] confirms the project decisions.

### Step 7: Fill Project Decisions + 7Q Sections

After [USER-NAME] confirms the WAIT Options Round 1, fill the plan sections that were informed by the exploration:

1. **Fill [Project Decisions](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#project-decisions)** — Record all confirmed decisions (with any changes [USER-NAME] made). Include the meaningful reasons — this IS the analysis record.

2. **Fill [What Are We Building?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-are-we-building)** — Vision Statement, Purpose & Motivation, Core Idea from the Q1 exploration.

3. **Fill [Who's Involved?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#whos-involved)** — Target Users, Stakeholders table, Team Structure from the Q2 exploration.

4. **Fill [What Does Success Look Like?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-does-success-look-like)** — Success Feeling and Success Metrics table from the Q3 exploration. Include 3-7 measurable KPIs with both business and technical metrics.

5. **Fill [What's The Technical Shape?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#whats-the-technical-shape)** — Services & Components, Tech Stack, Architecture Overview from the Q4 exploration.

6. **Fill [What Are The Boundaries?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-are-the-boundaries)** — Constraints, Non-Negotiables / Principles table, Timeline Pressure from the Q5 exploration. Remember: if a principle only applies to one milestone, it belongs in that milestone's plan.

7. **Fill [What Could Go Wrong?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-could-go-wrong)** — Risk Register table, External Dependencies, Known Unknowns from the Q6 exploration.

8. **Fill [How Do We Ship This?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#how-do-we-ship-this)** — Release Strategy, First Usable Version, Milestone Vision from the Q7 exploration.

---

### Phase 3: PLAN

*Build the milestone roadmap from confirmed decisions and present the full project foundation for alignment.*

### Step 8: Fill Milestone Roadmap

Based on the confirmed project decisions and the Q7 (How Do We Ship This?) insights:

Fill the [Milestone Roadmap](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#milestone-roadmap). Each row: M#, Name, Goal, Key Deliverables, Target Scope, Target Date, Status.

*Remember: Each milestone = a versioned release that can contain multiple services (BE+FE+Mobile+Deploy+QA+Launch). Target Date can be rough (month/quarter) — precision improves during Covenant Reviews.*

### Step 9: Present Foundation + Roadmap (WAIT Options Round 2)

Present ALL filled sections so far (7Q sections + Project Decisions + Milestone Roadmap) to [USER-NAME] for alignment.

**Response format:**
```
Here's the project foundation:

**What Are We Building?** — [Brief summary]
**Who's Involved?** — [count] stakeholder roles mapped
**What Does Success Look Like?** — [count] KPIs defined
**What's The Technical Shape?** — [key components]
**What Are The Boundaries?** — [count] principles, [constraints summary]
**What Could Go Wrong?** — [count] risks identified
**How Do We Ship This?** — [release strategy summary]

**Project Decisions:** [count] confirmed
[Show decisions table]

**Milestone Roadmap:** [count] milestones planned
[Show milestone table]

Review and confirm, or suggest changes.
```

STOP. Present to [USER-NAME] for review. Do NOT proceed until [USER-NAME] confirms. If [USER-NAME] changes anything, update all affected sections.

### Step 10: Scope Gate + De-escalation

Fill the [Scope Gate](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#scope-gate) section.

**Forge of Covenant is needed when ALL of these are true:**
- Project spans **multiple milestones/releases** (not just one)
- Project involves **multiple services or components** across its lifecycle
- Project needs **cross-milestone tracking** (deferrals, debt, scope shifts)

Fill the assessment and decision.

**If scope gate passes** (all criteria met): Proceed to Phase 4.

**If scope gate fails** (single milestone suffices):
1. Tell [USER-NAME]: "This project fits a single `/rite-of-creation`. De-escalating."
2. Delete the covenant plan folder
3. Launch `/rite-of-creation` with the project context — the vision, decisions, and principles gathered above carry forward
4. STOP this procedure

---

### Phase 4: DETAIL

*Explore each milestone in depth and collect milestone-level decisions using WAIT Options Round 3.*

### Step 11: Milestone Detail Exploration

For each milestone in the confirmed roadmap, discuss the detailed scope with [USER-NAME]. This is another **exploration round** — not just WAIT Options.

**For each milestone, discuss:**
- Which services/components are included in this release?
- What specific deliverables will be produced?
- What gets deferred to a later milestone? Why?
- What protocol level fits? (RoC for complex milestones with multiple SDLC phases, CoW for multi-feature milestones, HW for simple milestones)
- Any known technical debt that will be created?

Read and follow the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md) for collecting milestone-level decisions. These are decisions about HOW each milestone will be executed. Group decisions by milestone (M1, M2, etc.).

### Step 12: Present Milestone WAIT Options (Round 3)

Present the milestone planning decisions to [USER-NAME] using the [WAIT Options format](//@agent-memory/control-files/procedures/wait-options.md).
Preamble: "Here are the milestone-level decisions (WAIT Options Round 3):"
Group decisions by milestone (M1, M2, etc.).

STOP. Present to [USER-NAME] for review. Do NOT proceed until [USER-NAME] confirms the milestone decisions.

### Step 13: Fill Tracking Sections

After [USER-NAME] confirms WAIT Options Round 3:

1. **Fill [Milestone Decisions](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#milestone-decisions)** — Record all confirmed milestone-level decisions (with any changes [USER-NAME] made).

2. **Fill [Deferral & Debt Tracker](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#deferral--debt-tracker)** — From the milestone discussions, record all items that were deferred or identified as debt.

3. **Update [What Could Go Wrong?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-could-go-wrong)** — If milestone exploration revealed new risks, external dependencies, or known unknowns, update the Risk Register and sub-sections.

4. **Fill [Milestone Dependency Graph](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#milestone-dependency-graph)** — Create the mermaid diagram showing milestone relationships. Identify parallel opportunities and critical path.

5. **Fill [Execution Log](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#execution-log)** — Create placeholder rows for each milestone.

6. **Present** the filled tracking sections (milestone decisions, deferral tracker, updated risks, dependency graph, execution log) to [USER-NAME].

STOP. Present to [USER-NAME] for review. Do NOT proceed until confirmed.

**CRITICAL**: If any NEW decision is discovered during this step that was not covered in Step 12, STOP immediately. Present the new decision to [USER-NAME] with the same format (options + confidence + reason) before continuing. Do NOT write ahead on assumptions.

---

### Phase 5: REVIEW

*Self-review the complete plan for consistency, then present for final approval.*

### Step 14: Self-Review + Auto-Fix

Do a self-review by thinking critically:
- a. Are all milestones properly scoped? Any too large or too small?
- b. Are principles/non-negotiables realistic and upheld across the roadmap?
- c. Are success metrics measurable and realistic? Any missing for key milestones?
- d. Are high-impact risks mitigated? Any obvious risks missing from the register?
- e. Is the deferral tracker complete? Any obvious items missing?
- f. Are milestone dependencies correct? Any missing parallel opportunities?
- g. Is there any conflict between project decisions and the milestone plan?
- h. Does each milestone have a clear protocol assignment?
- i. Are target dates realistic given scope and constraints?

**If issues are found**: Auto-fix consistency issues (wrong protocol assignments, dependency errors, incomplete tracker entries) directly in the plan file. For issues that require a NEW decision (scope changes, milestone restructuring), STOP and present to [USER-NAME] using the WAIT Options format before continuing.

**Report**: Briefly list any auto-fixes made. If no issues found, proceed silently to Step 15.

### Step 15: Final Review

Before presenting the plan, double check: are there any unresolved decisions, assumptions, or new concerns that surfaced during writing (Steps 7-13) or self-review (Step 14) that need [USER-NAME]'s input? If yes, present them now with the same decision format (options + confidence + reason).

Present the complete grand-plan file link to [USER-NAME] for final review. STOP. Wait for instruction.

---

### Phase 6: EXECUTE

*Execute milestones following the dependency graph, with Covenant Reviews between each.*

### Step 16: Execute Milestones

After [USER-NAME] instructs to start, execute milestones following the dependency graph order.

**For each milestone:**
1. Check dependency graph — are all prerequisite milestones DONE?
2. If prerequisites met, launch the milestone using its designated protocol (`/rite-of-creation`, `/council-of-wizards`, `/high-wizard`, or `/quick-wizard`). **Important**: The milestone's plan file must be created inside the milestone sub-folder within the covenant folder (e.g., `M1-name/core-plan.md`), overriding the sub-protocol's default `plans/` location.
3. Update the Execution Log: status → IN PROGRESS, record start date, record protocol used
4. After milestone completes, update: status → DONE, record completion date
5. If milestone is blocked, update: status → BLOCKED, record reason in Notes

**Creating milestone sub-folders:**
```
mkdir -p ./plans/[covenant-folder]/M[N]-[milestone-name]
```

**Parallel execution:**
- If the dependency graph shows milestones that can overlap, inform [USER-NAME]: "M[X] and M[Y] can run in parallel. You can launch separate agent sessions to work on them concurrently."
- The protocol identifies parallel opportunities but does NOT enforce parallel execution — [USER-NAME] decides whether to run them concurrently

### Step 17: Covenant Review

After each milestone completes, conduct a **Covenant Review** before starting the next milestone.

**Review process:**
1. Add a new entry in the [Covenant Review Log](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#covenant-review-log) section
2. Discuss with [USER-NAME]:
   - What changed during this milestone? Any scope shifts?
   - Are any items now deferred? Update the [Deferral & Debt Tracker](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#deferral--debt-tracker)
   - Was any debt resolved? Mark it in the tracker
   - Are all principles/non-negotiables still upheld? Flag any at risk
   - Did any risks materialize? Update [What Could Go Wrong?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-could-go-wrong) (OPEN → OCCURRED / MITIGATED / CLOSED)
   - Are there new risks for upcoming milestones? Add to the Risk Register
   - Are success metrics on track? Check against [What Does Success Look Like?](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#what-does-success-look-like)
   - Do target dates for upcoming milestones need adjustment?
   - Do upcoming milestones need adjustment based on learnings?
3. Update the [Milestone Roadmap](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#milestone-roadmap) if any changes were agreed
4. Update the Deferral & Debt Tracker with any new entries or resolutions
5. Update the Risk Register with status changes and new risks

**This is the "covenant check"** — the grand plan stays honest and living. Skipping this step risks drift.

### Step 18: Project Completion + Archive

After all milestones are DONE and all Covenant Reviews completed:

1. Run through the [Project Completion Checklist](//@agent-memory/control-files/plan-templates/forge-of-covenant-plan-template.md#project-completion-checklist)
2. Verify all principles/non-negotiables were upheld
3. Verify the Deferral & Debt Tracker has no unresolved items
4. Present completion summary to [USER-NAME]

After [USER-NAME] confirms project is complete, move the entire covenant folder:
`mkdir -p ./plans/completed && mv ./plans/[covenant-folder] ./plans/completed/[covenant-folder]`

**Note**: Episodic memory links to the plan will break after moving. This is accepted — completed plans are archival.

---
