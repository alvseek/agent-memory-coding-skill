# Planning Rounds (plan component)

The rounds every implementation wizard presents, in order — the frame, scope, product flow, technical core, then integration points. **This is a component, not a standalone skill** — a wizard's decision step reads and follows it after the Planning Decision discipline.

*Referenced once each by `/quick-wizard`, `/high-wizard` and `/pixel-wizard`. Rounds are named, not numbered, so a wizard that adds its own round — pixel's visual target, which runs after the product-flow round — states it separately without forcing a renumber. Not nested inside another component; the overlay compiler inlines in a single pass.*

---

The frame comes before any of these — what you take the task to be and the shape of the change you intend — because no plan section exists yet for [USER-NAME] to read. It is presented whether or not a single round below runs.

**Scope round.** *Runs when the boundary of this work is not already settled.* What it covers and what it deliberately leaves out. Present by invoking the `/wait-options-coding` command procedure. **STOP.** Continue only on an answer, a "pass", or a "proceed".

**Product-flow round.** *Runs when the change adds to or alters the flow the user actually experiences.* What happens differently and in what order, described in what the user does rather than what the code does. Build it from the confirmed scope, then present by invoking `/wait-options-coding`. **STOP.**

**Technical-core round.** *Runs when the mechanism is not already settled in conversation.* The algorithm, data shape or logic pattern this is built on, named concretely. Build it from what the earlier rounds confirmed, then present. **STOP.** Where the mechanism this round names admits a real trade of speed against quality, present it as an effort spectrum instead of a single approach — a proper build, a pragmatic middle, and a quick or throwaway version — each naming the debt it takes on, with temporary code marked temporary; recommend the tier the task's stakes call for, and collapse any tier that coincides with another out loud, down to a single approach when only one is honest. Each tier may carry its own alternatives where they genuinely differ.

**Integration-points round.** *Runs when existing code will call into this, or this will call into existing code.* Where the new work is reached from, the contracts it consumes, the existing code it leans on, and the constraints that could break it. Build it from the confirmed core, then present. **STOP.**
