# Inherited Context — Read Side (plan component)

What a plan consumes when some of its decisions were made before it existed. **This is a component, not a standalone skill** — a leaf wizard follows it before investigating anything.

*Consumed by `/high-wizard`, `/quick-wizard` and `/pixel-wizard` — the three leaf wizards, each reading it in its own procedure before investigation begins. The parent's half of the handoff contract is [subplan-handoff-write.md](subplan-handoff-write.md).*

---

Decisions reach a plan from before it existed in two ways. They are recorded **separately** and never merged:

1. **From a parent plan.** A parent wizard hands them down when it launches a sub-plan or de-escalates to a lower wizard. The payload arrives alongside the plan-file path.
2. **From a pre-planning discussion.** [USER-NAME] and the agent settle them in conversation before any wizard runs — a design discussed and agreed, then handed to a wizard to execute. The discussion itself is the payload.

Both can be present at once: a sub-plan may be launched by a parent and then discussed further before it runs. Keep them apart — a parent's decision binds sibling plans too and can carry contracts, while a discussion's binds only this plan, and merging them loses which is which.

Without this, a plan handed only a file path — or nothing at all, after an hour of design — investigates from zero and re-asks what was already settled, and its answer can contradict the earlier one with nothing detecting it.

## What both sources are owed

Before investigating anything:

1. **Record what you inherited** in your plan's inherited-context section, verbatim, under the part matching its source. These decisions are not yours, and mixing them into your own Confirmed Decisions erases that distinction — that table is for decisions this plan made.
2. **Do not re-ask a settled decision.** It was already asked and answered — one altitude up, or in the discussion that produced this work.
3. **If a settled decision looks wrong, STOP and surface it** to [USER-NAME], with the reason it looks wrong. Never silently re-decide: reopening a parent's call produces two plans that disagree and nothing compares them, and reopening his teaches him that answering you does not stick.
4. **Investigate only the gap** — what is still genuinely undecided at your altitude, plus anything the parent or the discussion explicitly left to this plan.

## Reading a parent's handoff

Take the assigned scope, the constraining decisions with their reasons verbatim, the integration contracts and whether you produce or consume each, and the items the parent named as yours.

**If no payload arrived**, check the parent plan before assuming there is none: a sub-plan always lives inside its parent's folder, so `core-plan.md` beside you is the authoritative fallback. This matters most when the child runs in a separate session — parallel sub-plan execution is normal, and the launch context does not survive it.

## Reading a pre-planning discussion

Take the scope you agreed, every decision he settled with the reason he gave, and anything you both deliberately left open. Record alternatives that were considered and rejected alongside the decision that displaced them — an unrecorded rejected branch gets proposed again three steps later, by you.

## When neither is present

Write *"None"* under both parts and investigate normally.
