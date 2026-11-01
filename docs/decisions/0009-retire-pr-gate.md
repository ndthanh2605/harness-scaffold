# 0009 Retire the PR-Based Merge Gate for Solo-Maintainer Workflow

Date: 2026-11-01

## Status

Accepted — 2026-11-01

## Context

The state machine (`docs/HARNESS.md`) and the `harness-git-push`/
`harness-git-land` skills assume a feature-branch-and-PR workflow: push a
branch, open a PR, get a GitHub `APPROVED` review, merge, delete the branch.
In practice, every story run so far in this repo (US-002 through US-005) hit
the same gap and recorded the same deviation: the maintainer is a solo
developer who reviews and approves work live in chat with the agent, not via
GitHub's review UI. `docs/HARNESS_BACKLOG.md`'s "Formal Merge-Approval
Mechanism Doesn't Match Solo-Maintainer Reality" item (filed after the second
occurrence) proposed two resolutions and left the choice to the maintainer,
since it changes the documented feature workflow (a Harness Change Policy L3
category).

The maintainer has now made that choice directly: retire the PR gate. This
project is primarily personal/solo work, and a formal PR review step adds
process cost without adding a second reviewer — the review already happens,
just in chat.

## Decision

1. **State machine gates drop all PR language**, in `docs/HARNESS.md`:
   - `in_progress → human_review`: workpad Plan + AC checked off, validation
     green, any plan deviations recorded and ratified, no uncommitted
     changes. The agent presents the work (commits, diff, summary) to the
     human in chat — no PR is required to exist.
   - `human_review → merging`: human approves in chat (the agent records the
     approval in the workpad Notes).
   - `human_review → rework`: human posts actionable feedback (unchanged).
   - `merging → done`: changes pushed to `origin/main`, test matrix row
     updated, Evidence complete.
2. **No feature branches by default.** Stories implement directly on `main`,
   matching the pattern already used (as a deviation) in US-002 through
   US-005. A story may still use a branch at the implementer's discretion
   (e.g. a long-running high-risk story it wants to keep isolated), but it is
   no longer the default, and nothing in the state machine depends on one
   existing.
3. **`harness-git-push` simplified** to pushing the current branch (almost
   always `main`) to `origin`, with its existing sensitive-file scan kept.
   All PR-creation/update steps (`gh pr create`, `gh pr edit`) are removed.
4. **`harness-git-land` retired.** Its entire job — checking a GitHub review,
   merging a PR, deleting a branch — no longer applies when there is no PR.
   The file is kept (not deleted) with a deprecation notice at the top,
   pointing here, for the rare case a future story used a branch and needs
   the merge-and-cleanup steps as optional reference. It is removed from
   `CLAUDE.md`'s Source of Truth skill list and from the state machine's
   gate descriptions.
5. **`CLAUDE.md`'s Task Loop checklist** ("Was the correct skill used for
   each git operation (commit, push, pull, land)?") drops "land" from the
   list, matching the retirement.

This does not touch `scripts/install-harness.sh`'s own `--merge`/
`--override` conflict handling for target *projects* (Decision 0007) — that
is a different concern (overlay safety into someone else's repo), not this
repo's own internal review process.

## Alternatives Considered

1. **Add a "chat approval" substitute field to `harness-git-land`'s check**
   instead of removing PRs (the backlog item's option (a)). Rejected per the
   maintainer's explicit choice — the PR step itself is the overhead to
   remove, not just its approval-detection mechanism.
2. **Keep feature branches, drop only the PR/review requirement** (merge the
   branch locally without a PR). Rejected as unnecessary complexity: without
   a PR, a branch buys only "the ability to abandon a line of work before
   touching main," which this maintainer's workflow hasn't needed in four
   stories — direct-to-main, as already practiced, is simpler and already
   proven.
3. **Delete `harness-git-land` outright** instead of deprecating it in place.
   Rejected: a future high-risk story might still choose to branch, and the
   merge/cleanup steps are cheap to keep as optional reference rather than
   requiring them to be reconstructed from git history later.

## Consequences

Positive:

- Matches how this repo has actually been operated for four stories running
  — removes a recurring, already-backlogged friction point instead of
  recording the same deviation a fifth time.
- Fewer steps per story: no branch, no PR, no `gh pr merge`.

Tradeoffs:

- Loses GitHub's PR UI as a durable, timestamped record of what was approved
  and when — that record now lives only in the workpad Notes and this
  session's chat transcript, which is weaker provenance.
- If this maintainer later takes on collaborators, the PR-based flow would
  need to be reinstated for those contributors — this decision is scoped to
  the current solo-maintainer reality, not a permanent architectural stance.
- `harness-git-land` as a maintained skill effectively goes unused; keeping
  it as dead-but-documented code is a small ongoing readability cost.

## Follow-Up

- Close `docs/HARNESS_BACKLOG.md`'s "Formal Merge-Approval Mechanism Doesn't
  Match Solo-Maintainer Reality" item, referencing this decision.
- If collaborators are ever added, revisit this decision before their first
  contribution.

## References

- `docs/HARNESS_BACKLOG.md` — the item this decision resolves.
- `docs/decisions/0004-execution-state-machine.md` — the state machine this
  amends.
- US-002 through US-005 workpads — four recorded instances of the deviation
  this decision retires the need for.
