# Push Exclude Policy

Shared rule for every push flow (`/push-all`, `/push-project`, `/push-agent-work`, `/wrap-up`): some repos must never be auto-committed or pushed.

**Before pushing, consult the project's push-exclude list** at `shared-memory/[project]/context/push-policy.md` (if present). Repos / submodules listed there are **vendored / third-party / read-only** — never commit or push them, and do NOT count their state against completion. Report each as `skipped (excluded)`. Absent file → no exclusions (push everything in scope as normal).
