# US-003 harness-supervise Skill

## Status

done

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-003.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

normal

## Product Contract

A new skill, `harness-supervise`, mechanizes Decision 0008's L2 enforcement
tier (evidence + independent rerun). Invoked at the `in_progress →
human_review` transition, it independently re-verifies a story against its
own contract — `## Declared Files` matches what was actually touched, every
`## Deviations` entry is `ratified` (not `open`), the story's `## Validation`
commands actually pass when rerun (not taken on the implementing agent's
word), and any `Evidence` field genuinely substantiates its claim. Its
output is a verification report, never an approval, and it must escalate —
never resolve — anything that touches an L3 category (Harness Change Policy's
five categories, or a deviation crossing a public interface/dependency/
architecture-constraint invariant).

This is Plan 2 of 4 implementing `docs/decisions/0007` and
`docs/decisions/0008` (see US-002, done). It depends on US-002's L0–L3
taxonomy language existing in `docs/HARNESS.md` and is a prerequisite for
US-004 (the `harness-intake` router cites this skill by name).

## Relevant Product Docs

- `docs/HARNESS.md` (`### Plan Deviation Protocol` → `**Enforcement.**`, and
  the state machine table)
- `docs/decisions/0008-tiered-enforcement.md` (item 6)
- `.claude/skills/harness-git-commit/SKILL.md`,
  `.claude/skills/harness-git-pull/SKILL.md` (sibling skill shape to match)
- `scripts/install-harness.sh` (manifest)
- `scripts/harness-check.sh` (the drift-check this story must stay in sync with)

## Acceptance Criteria

- `.claude/skills/harness-supervise/SKILL.md` exists, following the
  Goal/Inputs/Steps/Output/Related-Skills shape used by the other
  `harness-git-*` skills.
- The skill's Steps independently check, without trusting the implementing
  agent's prior claims: `## Declared Files` in the story matches the files
  actually touched (`git diff --name-only` against the story's merge-base);
  every `## Deviations` entry in the workpad is `ratified`, none `open`;
  every command in the story's `## Validation` table is rerun and its actual
  output compared, not assumed; any `Evidence` field in a
  `HARNESS_BACKLOG.md` item or story is checked against what the diff/output
  actually shows, not merely present.
- The skill's output is explicitly framed as a report ("L0–L2 verified; items
  X, Y still need your decision"), never as an approval of the story as a
  whole.
- The skill explicitly refuses to clear anything that touches an L3 category
  (the five Harness Change Policy categories, or a deviation crossing a
  public interface/signature, dependency, or architecture-constraint
  invariant) — it must name the item and say a human must decide, not mark it
  verified.
- `docs/HARNESS.md`'s L2 bullet (added in US-002, currently says "tracked
  separately") is updated to point at this real skill.
- `docs/HARNESS.md`'s state-machine section notes that `harness-supervise`
  runs at the `in_progress → human_review` transition (additive — the gate
  itself is unchanged, it now receives a pre-triaged report).
- `scripts/install-harness.sh`'s manifest includes
  `.claude/skills/harness-supervise/SKILL.md`, so `scripts/harness-check.sh`'s
  drift-check (US-002) stays green with the new skill present.

## Design Notes

- Commands: none new — `harness-supervise` is invoked by name
  (`$harness-supervise`), like the existing `harness-git-*` skills.
- Domain rules: structurally inspired by (not a port of) `pstack:interrogate`
  (adversarial review) and `pstack:reflect` (transcript mining) — see
  Decision 0008. No dependency on the `pstack` plugin being installed.
- UI surfaces: the skill's own report text, read by the human at
  `in_progress → human_review`.

## Invariants & Flex

- `[INVARIANT]` The skill never marks an L3-category item "verified" — it
  must escalate (name it, say a human must decide) instead. This is the hard
  boundary from Decision 0008 and must not be softened.
- `[INVARIANT]` The skill reruns validation commands itself rather than
  reading the workpad's claimed results — "independent rerun" is the whole
  point of L2.
- `[INVARIANT]` `scripts/install-harness.sh`'s manifest must include the new
  skill's path, or US-002's drift-check fails.
- `[FLEX]` Exact wording/structure of the skill's report format, exact
  phrasing of its Steps, whether it is organized as one pass or several
  named checks.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
.claude/skills/harness-supervise/SKILL.md
docs/HARNESS.md
scripts/install-harness.sh
docs/TEST_MATRIX.md
docs/stories/US-003-harness-supervise.md
docs/stories/US-003-harness-supervise.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/install-harness.sh` |
| Integration | `scripts/harness-check.sh` passes with the new skill file present and listed in the manifest (exercises US-002's drift-check against this exact change). |
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

Implements `docs/decisions/0008-tiered-enforcement.md` item 6. US-004 (the
`harness-intake` router) cites this skill by name at the `in_progress →
human_review` step.

## Workpad

Execution state lives in `docs/stories/US-003-harness-supervise.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Merged: https://github.com/ndthanh2605/harness-scaffold/pull/2 at `0ccd8b0` on 2026-11-01.
- PR: https://github.com/ndthanh2605/harness-scaffold/pull/2
- Commits: `069c776` (skill + wiring), `0841941` (test-matrix fix + dogfood record).
- `bash -n scripts/install-harness.sh` → syntax OK.
- `bash scripts/harness-check.sh` on real repo state → `ok: harness-check
  passed — 3 story packet(s) validated, no violations.` (exit 0).
- Negative check: removed the new skill's manifest line → `FAIL: ...
  manifest is missing '.claude/skills/harness-supervise/SKILL.md' (shipped
  but not installed downstream)` (exit 1); restored, reran clean.
- `bash scripts/validate.sh quick` → `=== validate:quick passed ===` (exit 0).
- Dogfood: a fresh, no-shared-context agent ran `harness-supervise` against
  this story itself (full report in the workpad Notes). Verified all L0-L2
  items independently (including rerunning the negative drift-check fixture
  in its own scratch copy of the repo). Flagged two `docs/HARNESS.md` edits
  for human decision (correct behavior — they touch state-machine/enforcement
  text); maintainer confirmed both are direct implementations of the
  already-accepted Decision 0008 item 6. Also caught a real desync
  (`docs/TEST_MATRIX.md` said `implemented` while status was still
  `in_progress`) — fixed in `0841941`.
