# QA Status

Report where QA stands on this project right now — what is built, what is running, and what has been written but not yet proven. It answers questions; it never decides anything and it never blocks.

Four facts make up the answer: is the bench built, is the stack up, how many fixtures are written but unproven, and how many checklists are still unwalked. The first two together are what tells a caller whether integration tests can run here at all; the last two are the QA debt this project is carrying.

> **Canonical definitions live in `/map-qa-instrument`** — the R/I/A/O loop, the artifact ontology, the ownership split, and the `documented / tribal / missing` grading. This skill references *up* to it; it does not restate them.

> **Read-only, always.** It builds nothing, fixes nothing, and asks nothing. A status report that repairs what it finds stops being a status report, and a caller that must brace for side effects will stop calling it.

## Arguments

`$ARGUMENTS`

- `/qa-status` → report all four checks
- `/qa-status [project-path]` → target the named project root instead of cwd

---

## Procedure

### Step 1: Is the bench built?

Read `qa/qa-map.md` and the R/I/A/O Loop table in `qa/README.md`.

| Found | Report |
|---|---|
| No `qa/` folder, or no `qa-map.md` | **not set up** — this project hasn't opted into the QA ontology |
| Map exists, all four phases linked and `documented` | **built** |
| Any phase `tribal` | **built, undocumented** — it works but isn't discoverable |
| Any phase `missing` or unlinked | **incomplete** — name which phases |
| Any row `DEAD` or `DIVERGED` | **broken** — the index points at a mechanism that isn't there |

### Step 2: Is the stack up?

Run the cheapest thing the bench offers that proves the system answers — the OBSERVE mechanism the R/I/A/O table links, or a module runbook's Daily Loop / Quick Start smoke.

Two rules keep this honest. **Only run a probe that is safe standalone**: if OBSERVE only makes sense as the tail of a full loop, or writes anything, don't run it — say the stack state is *unknown* and name what would settle it. And **report what you ran**, so a reader can tell a real probe from an assumption.

If the bench isn't built, this check has nothing to run. Report *unknown* and move on rather than improvising a probe.

### Step 3: What is written but not proven?

Read the header of every file in `qa/fixtures/`. Count those at `fidelity-checked: PENDING` on rung 2 or 3 — a fixture that has never been checked against the real stage it imitates. Name them; a count alone doesn't tell anyone where to look.

A rung-1 fixture is captured real state and needs no check, so it is never pending.

### Step 4: What is written but not walked?

Count the checklists in `qa/checklists/` that have not moved to `completed/`, and for each, read its `## Result` section: never run, run but not signed off, or run with findings still open. An unwalked checklist is a feature whose verification was planned and never performed.

### Step 5: Report

Write one `## Result` block. Lead with the two lines a caller needs, then the two a human needs.

```
## Result

**Bench**: {built | built, undocumented | incomplete — [phases] | broken — [rows] | not set up}
**Stack**: {up | down | unknown — [why]}   (probe: [what you ran, or "none available"])

**Fixtures unproven**: {n} at PENDING — [names]
**Checklists unwalked**: {n} — [names, with never-run / not-signed-off / findings-open]
```

Then one plain sentence naming the single most useful next action, and nothing more. If everything is clean, say so in that sentence rather than printing empty lines — a status report that lists four kinds of nothing is harder to read than one that says the project is clean.

**Never turn the report into a prompt.** The caller decides what to do with it. A wizard reads the first two lines and continues either way; a human reads all four and picks.

---

## Integration With Other Procedures

- **/map-qa-instrument** — upstream. Its map is what Step 1 reads. If the map is stale, this report inherits that staleness; `--rescan` there is the fix, not anything here.
- **/build-qa-bench** — upstream. Its output is the bench Step 1 grades and the probe Step 2 runs.
- **/integration-test** — caller. Gates on Steps 1 and 2: no bench or no stack means it cannot run a test that needs a real boundary.
- **/high-wizard** — caller, at Step 14. Reads the same two lines to decide whether this plan's phases carry integration tests, and records the answer in the plan either way.
- **/run-qa-test** — sibling. Steps 3 and 4 describe the work it has left to do; this skill never does that work.

---

## Anti-Patterns

1. **Repairing what you find.** A missing bench, a stale map, a pending fixture — all of them are somebody else's job. Report and name the owner.
2. **Blocking a caller.** There is no state of QA that justifies stopping a wizard mid-sweep. "Not set up" is an answer, not an error.
3. **Guessing the stack is up.** An unreachable fact reported as *unknown* is honest; one reported as *down* because you didn't check is not, and it will silently cost a plan its integration coverage.
4. **Running an unsafe probe.** An OBSERVE mechanism that writes, or that only means something at the end of a full loop, is not a liveness check. Say so instead.
5. **Printing empty sections.** Four lines of zeroes read as a broken report. One sentence saying the project is clean reads as a clean project.
6. **Counting without naming.** "3 fixtures pending" sends the reader hunting. Name them.
