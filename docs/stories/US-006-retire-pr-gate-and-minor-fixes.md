# US-006 Retire PR Gate + Deferred Minor Fixes

## Status

done

<!-- State machine — transition only when the gate is fully met. This story
     is the first to use the gates as redefined by Decision 0009 itself:
  todo         → in_progress  : agent creates workpad sibling, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations ratified, no uncommitted changes. Agent presents the work in chat — no PR required.
  human_review → merging      : human approves in chat (recorded in workpad)
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : pushed to origin/main, test matrix row updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

normal

## Product Contract

The state machine, `CLAUDE.md`, and the `harness-git-push`/`harness-git-land`
skills no longer require a GitHub PR to advance a story, per
`docs/decisions/0009-retire-pr-gate.md`. Separately, five previously-deferred
Minor findings from the US-002/US-004 `harness-supervise` reviews are fixed:
a garbled sentence in `docs/HARNESS.md`, the drift-check's one-directory-level
wording mismatch, the drift-check's blind spot for non-`SKILL.md` manifest
entries, the awk extraction's CRLF-on-non-MSYS robustness, and the
"pull skill" vs. `harness-git-pull` naming mismatch.

## Relevant Product Docs

- `docs/decisions/0009-retire-pr-gate.md`
- `docs/HARNESS.md`, `CLAUDE.md`
- `.claude/skills/harness-git-push/SKILL.md`, `.claude/skills/harness-git-land/SKILL.md`
- `scripts/harness-check.sh`
- `docs/HARNESS_BACKLOG.md` (closes the "Formal Merge-Approval..." item)

## Acceptance Criteria

**PR-gate retirement (Decision 0009):**
- `docs/HARNESS.md`'s state machine table has no "PR linked" / "PR merged" /
  "human approves PR" language; gates read as in the table above.
- `.claude/skills/harness-git-push/SKILL.md` no longer creates or edits a PR;
  it pushes the current branch (in practice, `main`) and keeps its
  sensitive-file scan.
- `.claude/skills/harness-git-land/SKILL.md` carries a deprecation notice at
  the top pointing to Decision 0009; it is not deleted.
- `CLAUDE.md`'s Task Loop checklist line drops "land" from the git-operation
  list.
- `docs/HARNESS_BACKLOG.md`'s "Formal Merge-Approval Mechanism..." item status
  is updated to reference this story and Decision 0009 as its resolution.

**Minor fixes (deferred from US-002/US-004 `harness-supervise` reviews):**
- `docs/HARNESS.md`'s Enforcement paragraph no longer reads "including plus
  human review" — reworded to make sense.
- `docs/HARNESS.md`'s L0 bullet states the drift-check reaches exactly one
  directory level under `.claude/skills/` (matching the actual `find
  -mindepth 2 -maxdepth 2` behavior and how Claude Code actually discovers
  skills), rather than implying arbitrary `**/SKILL.md` nesting.
- `scripts/harness-check.sh`'s reverse-direction manifest check covers every
  manifest entry under `.claude/skills/`, not only ones ending in
  `SKILL.md` — closes the real gap now that `references/pstack-routing.md`
  is an actual non-`SKILL.md` manifest entry.
- The manifest heredoc extraction strips a trailing `\r` explicitly, so it
  behaves the same on a literal CRLF checkout on a non-MSYS shell as it does
  today (relying on MSYS/LF-checkout stripping).
- `docs/HARNESS.md`'s Default Posture #3 and `principle-default-posture`'s
  SKILL.md both say `harness-git-pull` (the real skill name), not the
  generic "pull skill".

All of the above keep `scripts/harness-check.sh` and `scripts/validate.sh
quick` green, including the existing and new drift-check fixtures.

## Design Notes

- Commands: none new.
- Domain rules: none changed beyond Decision 0009's workflow shape.
- UI surfaces: `harness-git-push`'s simplified output; `harness-check.sh`'s
  reverse-check now reports on any `.claude/skills/` manifest entry, not just
  `SKILL.md` ones.

## Invariants & Flex

- `[INVARIANT]` `harness-git-land` is deprecated, not deleted.
- `[INVARIANT]` The reverse-direction drift-check must cover every manifest
  entry under `.claude/skills/`, not only `SKILL.md`-suffixed ones — this is
  the actual bug being fixed, so narrowing it back would defeat the point.
- `[INVARIANT]` No validation requirement is weakened — `harness-check.sh`
  must stay at least as strict after this story as before (it becomes
  stricter in one respect, not looser in any).
- `[FLEX]` Exact wording of the reworded sentences; exact bash approach for
  the CRLF-stripping and the broadened reverse check.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
docs/HARNESS.md
CLAUDE.md
.claude/skills/harness-git-push/SKILL.md
.claude/skills/harness-git-land/SKILL.md
.claude/skills/harness-intake/SKILL.md
.claude/skills/principle-default-posture/SKILL.md
scripts/harness-check.sh
docs/HARNESS_BACKLOG.md
docs/TEST_MATRIX.md
docs/stories/US-006-retire-pr-gate-and-minor-fixes.md
docs/stories/US-006-retire-pr-gate-and-minor-fixes.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/harness-check.sh` |
| Integration | `scripts/harness-check.sh` green on real repo state; a seeded fixture with a non-`SKILL.md` manifest entry pointing nowhere (e.g. a bogus `references/` line) now fails, proving the broadened reverse-check; existing positive/negative `SKILL.md` fixtures from US-002/US-003/US-004 still behave the same. |
| E2E | `scripts/validate.sh quick` passes on the real repo state after the change. |
| Platform | POSIX shell execution, consistent with prior stories. |
| Release | Not applicable at v0. |

## Stop Conditions

Stop and follow the Plan Deviation Protocol (`docs/HARNESS.md`) — record in the
workpad `## Deviations`, do not silently work around — when any of these occur:

- A planned interface, signature, dependency, or data model does not work as
  specified and must change.
- The implementation needs a file not in `## Declared Files`.
- An acceptance criterion's proof method has to change.
- The only way to make something pass is a workaround, `TODO`/`FIXME`/`HACK`,
  or a suppressed warning / type error.
- An architecture constraint must be bent.

## Harness Delta

Implements `docs/decisions/0009-retire-pr-gate.md` in full, and closes five
Minor findings deferred from the US-002 and US-004 `harness-supervise`
reviews.

## Workpad

Execution state lives in `docs/stories/US-006-retire-pr-gate-and-minor-fixes.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Commits: `07b2cf9` (PR-gate retirement + 5 minor fixes), `81d761f`
  (standalone tiny-lane manifest fix, discovered via the LeanGoes-Dict test,
  confirmed with the maintainer as accepted outside this story's scope),
  `063fa4b` (backlog evidence update), plus a follow-up fix commit for the
  dogfood findings below. First story to close under Decision 0009's own
  rules — no PR, approved in chat, pushed directly to `origin/main`.
- `bash -n scripts/harness-check.sh` → syntax OK.
- `bash scripts/harness-check.sh` on real repo state → `ok: harness-check
  passed — 6 story packet(s) validated, no violations.` (exit 0).
- New fixture: non-`SKILL.md` manifest entry pointing nowhere → `FAIL:
  scripts/install-harness.sh: manifest entry '.claude/skills/harness-intake/
  references/does-not-exist.md' does not exist in this repo` (exit 1);
  restored, confirmed clean via `git status`/`git diff --stat` (not raw
  `diff`, which showed CRLF/LF noise against `git show`'s LF blob).
- `bash scripts/validate.sh quick` → `=== validate:quick passed ===` (exit 0).
- CRLF fix: reworked from `gsub` inside the capture block (didn't actually
  fix the claimed bug — the marker regexes themselves were vulnerable) to
  an unconditional `sub(/\r$/, "")` first rule. Tested against a literal
  CRLF file built byte-for-byte with `printf` and verified with `xxd`/
  `cat -A`: extracts exactly the 2 expected lines, no leftover `^M`.
  **Honestly recorded limitation:** this environment's `awk` (MSYS gawk)
  strips `\r` during its own line-splitting regardless of script content,
  so the before/after difference could not be empirically demonstrated
  here — the fix is correct by POSIX awk semantics (desk-checked), not
  empirically proven in this sandbox.
- Real-world install test (separately requested): ran `scripts/
  install-harness.sh --merge` against `F:\Projects\LeanGoes-Dict` (a real,
  pre-existing git repo with its own `docs/`, `src/`, `tests/`,
  `data-pipeline/`, no prior `CLAUDE.md`). Confirmed via `git status` in
  that repo: 0 pre-existing files modified or deleted, 51 then 3 new files
  created (the second pass picked up the decisions this story's manifest
  fix added). `harness-check.sh` installed there now passes
  (`0 story packet(s)` — correct, a fresh install with no stories yet).
  Files left untracked in LeanGoes-Dict for the maintainer's own review —
  not committed there.
- Dogfood: a fresh, no-shared-context agent ran `harness-supervise` against
  `07b2cf9` (full report in the workpad Notes). Verified every AC
  independently via direct grep/diff reads, not the story's own claims.
  Found two real issues, both fixed: the CRLF fix above, and a stale
  "before presenting the PR" phrase in `harness-intake/SKILL.md` (D1,
  ratified). Correctly escalated rather than resolved the L3 item (this
  story's own feature-workflow change) and flagged the standalone tiny-lane
  commit for confirmation — maintainer confirmed both in chat.
