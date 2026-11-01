---
name: harness-supervise
description: >
  Independently re-verify a story at the in_progress → human_review gate:
  confirm Declared Files match what was actually touched, every workpad
  Deviation is ratified (not open), every Validation command actually passes
  when rerun, and any Evidence field genuinely substantiates its claim.
  Mechanizes Decision 0008's L2 enforcement tier (evidence + independent
  rerun). Produces a verification report, never an approval — must escalate,
  never resolve, anything touching an L3 category. Invoke before a story
  moves to human_review, or when closing a HARNESS_BACKLOG.md item.
---

# Harness Supervise

## Goal

Give the human a pre-triaged review instead of a cold read: independently
confirm everything that is mechanically checkable about a finished story or
backlog claim, and name — without resolving — anything that genuinely needs
human judgment.

This skill exists so L2 enforcement (`docs/decisions/0008-tiered-enforcement.md`)
is a real, invocable procedure, not informal "trust the implementing agent"
guidance. Run it with **no shared context** from the work being checked — a
fresh invocation, not a continuation of the session that did the work.

## Hard Boundary

This skill may confirm or flag **L0–L2 items only**. It must never resolve or
silently clear anything that touches an **L3** category:

- The five `CLAUDE.md` Harness Change Policy categories: architecture
  direction, removing or weakening a validation requirement, changing the
  source-of-truth hierarchy, changing risk classification rules, replacing
  the feature workflow.
- A deviation that changes a public interface/signature, swaps a dependency,
  or bends an architecture constraint.

If any step below surfaces one of these, stop checking that item and list it
under "Needs your decision" in the report. Do not mark it verified. A cheap
mechanism quietly substituting for the expensive one on exactly the decisions
the taxonomy protects would defeat the taxonomy itself.

## Inputs

- A story packet path (`docs/stories/US-XXX.md`, or the high-risk
  `execplan.md`) at `in_progress` or claiming readiness for `human_review`.
- Its workpad sibling.
- Optionally, a `docs/HARNESS_BACKLOG.md` item claiming `implemented`.

## Steps

1. **Declared Files check.** Read the story's `## Declared Files`. Run
   `git diff --name-only <merge-base>..HEAD` (or the relevant commit range)
   and compare. Every touched file must be declared. A declared file that
   was never touched is not a problem; an undeclared touched file is — name
   it exactly.

2. **Deviations check.** Read the workpad's `## Deviations`. Every entry must
   read `(status: ratified)`. Any entry still `(status: open)` is an
   unratified invariant crossing — this is an L0 violation `harness-check.sh`
   should also catch on a `done` story, but confirm it here too and name the
   entry.

3. **Independent rerun.** For every row in the story's `## Validation` table
   and every command listed in its `## Evidence` section, **rerun it
   yourself** and read the actual output. Do not accept the workpad's or
   story's claimed result as given — that claim is exactly what this skill
   exists to check. Compare against the stated expectation. A command that
   cannot be rerun (e.g. it required a now-deleted temporary fixture) is not
   a pass — note it as unverifiable and list it under "Needs your decision."

4. **Evidence substantiation.** For any `Evidence` field (story or backlog
   item), check that the cited observation actually shows what it claims —
   read the referenced diff, output, or fixture result yourself. "Evidence"
   that only restates the claim in different words does not substantiate it;
   flag it.

5. **L3 scan.** Before concluding, check whether anything touched in this
   change falls under the Hard Boundary above. If so, stop treating it as a
   normal finding — list it explicitly under "Needs your decision," not under
   any verified section, regardless of how confident the rerun was.

6. **Report.** Produce a short report with exactly two sections:
   - **Verified (L0–L2):** each check from Steps 1–4 that passed, one line
     each, with the command/output that proves it — not just "looks fine."
   - **Needs your decision:** anything from Step 2 (open deviation), Step 3
     (failed or unverifiable rerun), Step 4 (unsubstantiated evidence), or
     Step 5 (L3 touch) — one line each, naming the item and why it needs a
     human, not a restatement of the whole diff.

   If "Needs your decision" is empty, say so explicitly — do not omit the
   section.

## Output

A two-section verification report (above), left for the human to read at the
`in_progress → human_review` gate (or alongside a `HARNESS_BACKLOG.md`
closure claim). This skill never changes a story's `## Status` field and
never marks a backlog item `implemented` — that remains the human's call,
informed by this report.

## Related Skills

- `harness-git-commit`, `harness-git-push`: run before this skill, to produce
  the commit range this skill reruns validation against.
- `harness-intake`: the router this skill is cited from at the
  `in_progress → human_review` step (see US-004).
