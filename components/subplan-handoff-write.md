# Subplan Handoff — Write Side (plan component)

What a parent emits when it hands work down to a child wizard. **This is a component, not a standalone skill** — only a wizard that orchestrates sub-plans follows it; the child's half of the same contract is [subplan-handoff-read.md](subplan-handoff-read.md).

*Consumed by `/council-of-wizards`, `/rite-of-creation` and `/forge-of-covenant` — the three orchestrating wizards, at every downward edge: launching a sub-plan, and de-escalating to a lower wizard.*

Without this, a launch passes only a file path: the child investigates from zero and re-asks what the parent already settled, and its answer can contradict the parent's with nothing detecting it.

---

## Write Side — the parent emits

When launching a child (or de-escalating to a lower level wizard), pass a handoff block alongside the plan-file path. Include only what bears on **this** child — a payload that restates the whole parent plan is noise, and noise gets skimmed.

1. **Assigned scope** — the requirement IDs, phase, or milestone this child owns, and the one-line statement of what it must deliver.
2. **Constraining decisions** — the confirmed decisions that bind this child, quoted **verbatim with their reasons**. The reason is what stops the child re-litigating; a bare verdict invites one.
3. **Integration contracts** — paths to the contract files this child must honor (`contracts/*.yaml`), and for each, whether this child **produces** or **consumes** it.
4. **Pushed-down open items** — decisions you deliberately did not make because they belong at this child's altitude. Name them; do not leave them to be rediscovered.
5. **The boundary** — state plainly which items are **settled (may not reopen)** and which are **this child's call**. An unlabelled payload reads as entirely fixed, and the child stops thinking.
