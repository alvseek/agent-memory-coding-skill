# Subplan Handoff (plan component)

The contract for what crosses the edge when one wizard hands work to another. **This is a component, not a standalone skill** — a wizard reads and follows the half that applies to it.

*Write side consumed by `/council-of-wizards`, `/rite-of-creation`, `/forge-of-covenant` (launching a sub-plan, and de-escalating to a lower wizard). Read side consumed by `/high-wizard` and `/quick-wizard` via the Investigate & Collect Decisions component, and by `/pixel-wizard` directly.*

Without this, a launch passes only a file path: the child investigates from zero and re-asks what the parent already settled, and its answer can contradict the parent's with nothing detecting it.

---

## Write Side — the parent emits

When launching a child (or de-escalating to a lower wizard), pass a handoff block alongside the plan-file path. Include only what bears on **this** child — a payload that restates the whole parent plan is noise, and noise gets skimmed.

1. **Assigned scope** — the requirement IDs, phase, or milestone this child owns, and the one-line statement of what it must deliver.
2. **Constraining decisions** — the confirmed decisions that bind this child, quoted **verbatim with their reasons**. The reason is what stops the child re-litigating; a bare verdict invites one.
3. **Integration contracts** — paths to the contract files this child must honor (`contracts/*.yaml`), and for each, whether this child **produces** or **consumes** it.
4. **Pushed-down open items** — decisions you deliberately did not make because they belong at this child's altitude. Name them; do not leave them to be rediscovered.
5. **The boundary** — state plainly which items are **settled (may not reopen)** and which are **this child's call**. An unlabelled payload reads as entirely fixed, and the child stops thinking.

## Read Side — the child consumes

Before investigating anything:

1. **Read the handoff.** Record it verbatim under `## INHERITED CONTEXT` in your plan — inherited decisions are not yours, and mixing them into your own Confirmed Decisions erases that distinction.
2. **Do not re-ask a settled decision.** It was already asked and answered one altitude up.
3. **If a settled decision looks wrong, STOP and surface it** to [USER-NAME] — with the reason it looks wrong. Never silently re-decide: a child that quietly overrides its parent produces two plans that disagree, and nothing in the system compares them.
4. **Investigate only the gap** — what is still genuinely undecided at your altitude, plus the pushed-down items the parent named as yours.

**If no handoff was passed**, check the parent plan before assuming there is none: a sub-plan always lives inside its parent's folder, so `core-plan.md` beside you is the authoritative fallback. This matters most when the child runs in a separate session — parallel sub-plan execution is a normal mode, and the launch context does not survive it.

**If you are running standalone** (no parent folder, no handoff), write *"None — standalone plan"* under `## INHERITED CONTEXT` and investigate normally.
