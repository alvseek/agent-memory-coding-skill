# Subplan Handoff — Read Side (plan component)

What a child consumes when a parent hands work down to it. **This is a component, not a standalone skill** — a leaf wizard follows it before investigating anything; the parent's half of the same contract is [subplan-handoff-write.md](subplan-handoff-write.md).

*Consumed by `/high-wizard`, `/quick-wizard` and `/pixel-wizard` — the three leaf wizards, each reading it in its own procedure before investigation begins.*

Without this, a child that was passed only a file path investigates from zero and re-asks what the parent already settled, and its answer can contradict the parent's with nothing detecting it.

---

## Read Side — the child consumes

Before investigating anything:

1. **Read the handoff.** Record it verbatim under `## INHERITED CONTEXT` in your plan — inherited decisions are not yours, and mixing them into your own Confirmed Decisions erases that distinction.
2. **Do not re-ask a settled decision.** It was already asked and answered one altitude up.
3. **If a settled decision looks wrong, STOP and surface it** to [USER-NAME] — with the reason it looks wrong. Never silently re-decide: a child that quietly overrides its parent produces two plans that disagree, and nothing in the system compares them.
4. **Investigate only the gap** — what is still genuinely undecided at your altitude, plus the pushed-down items the parent named as yours.

**If no handoff was passed**, check the parent plan before assuming there is none: a sub-plan always lives inside its parent's folder, so `core-plan.md` beside you is the authoritative fallback. This matters most when the child runs in a separate session — parallel sub-plan execution is a normal mode, and the launch context does not survive it.

**If you are running standalone** (no parent folder, no handoff), write *"None — standalone plan"* under `## INHERITED CONTEXT` and investigate normally.
