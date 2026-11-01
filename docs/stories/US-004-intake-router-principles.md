# US-004 harness-intake Router + principle-* Skills

## Status

done

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-004.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix row updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

normal

## Product Contract

Four new, explicit-invoke-only `principle-*` skills extract this project's
house rules — Plan Deviation Protocol, Invariant Markers, Default Posture,
Enforcement Tiers — into short, independently citable skills, each pointing
back to `docs/HARNESS.md` as the authoritative full text (no duplicated
source of truth). `harness-intake`'s existing classification process is
unchanged, but its Intake Report now names which `principle-*` skills are
relevant to the chosen lane, and explicitly cites `harness-supervise` as the
skill to invoke at the `in_progress → human_review` gate.

This is Plan 3 of 4 implementing `docs/decisions/0007`. It depends on US-003
(`harness-supervise`, done) for the cross-reference and does not block
US-005 (managed `CLAUDE.md` block + `harness-install`), which can proceed
independently.

## Relevant Product Docs

- `docs/decisions/0007-overlay-authority-and-explicit-invocation.md` (item 2)
- `docs/HARNESS.md` (`### Plan Deviation Protocol`, `### Default Posture`,
  `**Enforcement.**`)
- `.claude/skills/harness-intake/SKILL.md`
- `pstack` plugin `skills/principle-*/SKILL.md` (structural precedent —
  `disable-model-invocation: true`, short single-rule body, cited by name)

## Acceptance Criteria

- Four new skills exist, each with `disable-model-invocation: true` in
  frontmatter (explicit-invoke / cite-only, never auto-triggered by the
  model matching its description to an unrelated task):
  `principle-plan-deviation`, `principle-invariant-markers`,
  `principle-default-posture`, `principle-enforcement-tiers`.
- Each is short (comparable to the pstack precedent, not a restatement of
  the full `docs/HARNESS.md` section) and ends with a pointer to the
  `docs/HARNESS.md` section it distills, so there is one authoritative
  source of truth, not two copies that can drift.
- `harness-intake`'s existing 7-step classification process is unchanged.
  Its Intake Report format gains a `**Relevant principles:**` line naming
  which `principle-*` skills apply to the classified lane, and the Step 7 /
  Done Definition reminder area notes that `harness-supervise` runs at the
  `in_progress → human_review` gate.
- `scripts/install-harness.sh`'s manifest includes all four new skill paths.
- `scripts/harness-check.sh`'s drift-check (US-002) passes with all four
  present and listed.

## Design Notes

- Commands: none new — each skill is invoked by name
  (`$principle-plan-deviation`, etc.) or cited by `harness-intake`.
- Domain rules: structurally modeled on pstack's `principle-*` library (see
  Decision 0007 context), not a port of pstack's own principle content —
  the content is this project's own rules, already written in
  `docs/HARNESS.md`.
- UI surfaces: none.

## Invariants & Flex

- `[INVARIANT]` All four skills carry `disable-model-invocation: true` — none
  may be eligible for implicit, description-matched auto-invocation.
- `[INVARIANT]` Each skill's content stays a short distillation with a
  pointer back to `docs/HARNESS.md`, not a full duplicate — avoids a second
  source of truth that can drift from the original.
- `[INVARIANT]` `harness-intake`'s existing 7-step process and Intake Report
  format fields are not removed or reordered — only the new
  `**Relevant principles:**` line is added.
- `[FLEX]` Exact wording of each principle skill's body; exact phrasing of
  the Relevant-principles mapping per lane.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
.claude/skills/principle-plan-deviation/SKILL.md
.claude/skills/principle-invariant-markers/SKILL.md
.claude/skills/principle-default-posture/SKILL.md
.claude/skills/principle-enforcement-tiers/SKILL.md
.claude/skills/harness-intake/SKILL.md
scripts/install-harness.sh
docs/TEST_MATRIX.md
docs/stories/US-004-intake-router-principles.md
docs/stories/US-004-intake-router-principles.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/install-harness.sh` |
| Integration | `scripts/harness-check.sh` passes with all four new skills present and listed in the manifest; fails if one is seeded as missing (reruns US-002's drift-check). |
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

Implements `docs/decisions/0007-overlay-authority-and-explicit-invocation.md`
item 2 (the `principle-*` extraction and router citation half; the Skill A /
managed-`CLAUDE.md` half is US-005).

## Workpad

Execution state lives in `docs/stories/US-004-intake-router-principles.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Merged: https://github.com/ndthanh2605/harness-scaffold/pull/3 at `a9f25fd` on 2026-11-01.
- PR: https://github.com/ndthanh2605/harness-scaffold/pull/3
- Commit: `b2e7eae`.
- `bash -n scripts/install-harness.sh` → syntax OK.
- `bash scripts/harness-check.sh` on real repo state → `ok: harness-check
  passed — 4 story packet(s) validated, no violations.` (exit 0).
- Negative check: removed `principle-enforcement-tiers`'s manifest line →
  `FAIL: ... manifest is missing '.claude/skills/principle-enforcement-tiers/SKILL.md'`
  (exit 1); restored, reran clean.
- `bash scripts/validate.sh quick` → `=== validate:quick passed ===` (exit 0).
- Dogfood: a fresh, no-shared-context agent ran `harness-supervise` against
  this story (full report in the workpad Notes), independently re-running
  every fixture (including all four negative-manifest removals, in a
  throwaway clone that left the real repo untouched) and confirming every
  AC. L3 scan found nothing. Two non-blocking minor notes recorded, not
  fixed in this story (see workpad): a small duplicate of the L3 category
  list in `principle-enforcement-tiers`, and an inherited "pull skill" vs.
  `harness-git-pull` naming mismatch already present in `HARNESS.md`.
