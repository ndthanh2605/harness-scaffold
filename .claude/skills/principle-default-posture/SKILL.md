---
name: principle-default-posture
description: "Apply at the start of any implementation task, to calibrate how autonomously to proceed."
disable-model-invocation: true
---

# Default Posture

1. **Reproduce before changing** — confirm the current broken or missing
   behavior (bugs) or confirm the feature is absent (new work) before
   editing. Record the reproduction signal in workpad Notes.
2. **Workpad-first** — update the workpad's plan before writing
   implementation. Planning lives in the file, not in memory.
3. **Sync before editing** — run the `harness-git-pull` skill before any
   code changes. Record the sync result in workpad Notes.
4. **Status gates** — only transition story status when the gate for that
   state is fully met. Never advance optimistically.
5. **Scope discipline** — out-of-scope improvements discovered during
   execution go to `HARNESS_BACKLOG.md`, not into the current story.
6. **Operate autonomously until truly blocked** — `blocked` is an escape
   hatch for *external* blockers (missing auth, missing tool, a required
   human decision after exhausting fallbacks). It is not a shortcut for
   difficult problems. Difficult is not the same as plan-breaking: when
   reality diverges from the approved plan across an `[INVARIANT]`, follow
   `principle-plan-deviation` instead of improvising.

Full text and rationale: `docs/HARNESS.md` → `### Default Posture`.
