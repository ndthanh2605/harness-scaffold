# US-002 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-002.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@0c3ea51`

## Plan

- [x] Step 1: Add the L0–L3 taxonomy section to `docs/HARNESS.md` (Decision 0008), re-tier the Plan Deviation Protocol and Harness Change Policy against it, name the closed editable-surfaces list in the Growth Rule.
  - [x] 1.1 Rewrote the existing "Enforcement." paragraph into named L0/L1/L2/L3 definitions (generalizing, not replacing, the prior two-layer text).
  - [x] 1.2 Cross-referenced existing Plan Deviation Protocol deviation types against L0/L1/L3 in the same paragraph.
  - [x] 1.3 Stated all five Harness Change Policy categories at L3 explicitly, cross-referencing `CLAUDE.md` rather than editing it (CLAUDE.md not in Declared Files — see Ruling above).
  - [x] 1.4 Added closed editable-surfaces list + diff-shaped-proposal + Evidence requirement to the Growth Rule paragraph.
- [x] Step 2: Added mandatory `Evidence` field to `docs/HARNESS_BACKLOG.md`'s `## Template`, between `### Current Pain` and `### Suggested Improvement`.
- [x] Step 3: Added the manifest drift-check to `scripts/harness-check.sh` (both directions).
  - [x] 3.1 Wrote the check logic (awk heredoc extraction + two-direction grep/exists check).
  - [x] 3.2 Verified it fails on a seeded missing-from-manifest fixture (`.claude/skills/__drift-test__/SKILL.md`), then cleaned up.
  - [x] 3.3 Verified it fails on a seeded manifest-points-nowhere fixture (bogus line in `scripts/install-harness.sh`'s heredoc via a backed-up temp edit), then restored the file byte-identical (confirmed via `diff`).
  - [x] 3.4 Verified it passes on the real, in-sync repo state (both before and after the fixture tests).
- [x] Step 4: Ran `scripts/validate.sh quick` — green.
- [x] Step 5: Updated `docs/TEST_MATRIX.md` with a US-002 row.
- [ ] Step 6: Commit via `harness-git-commit` skill.

## Acceptance Criteria

- [x] L0–L3 taxonomy named in `docs/HARNESS.md`, trimmed to v0 scope.
- [x] Plan Deviation Protocol deviations re-tiered explicitly.
- [x] All five Harness Change Policy categories stated at L3.
- [x] Growth Rule names closed editable-surfaces list, requires diff-shaped proposals.
- [x] `docs/HARNESS_BACKLOG.md` template gains mandatory `Evidence` field.
- [x] `scripts/harness-check.sh` fails on manifest drift in both directions.
- [x] `scripts/harness-check.sh` passes on current repo state.

## Validation

- [x] `bash -n scripts/harness-check.sh` — syntax check. Result: `SYNTAX_OK`.
- [x] Seeded missing-from-manifest fixture — confirms new check fires. Result: `FAIL: scripts/install-harness.sh: manifest is missing '.claude/skills/__drift-test__/SKILL.md' (shipped but not installed downstream)`, exit 1; clean rerun after removal: exit 0.
- [x] Seeded manifest-points-nowhere fixture — confirms new check fires. Result: `FAIL: scripts/install-harness.sh: manifest entry '.claude/skills/does-not-exist/SKILL.md' does not exist in this repo`, exit 1; file restored byte-identical (`diff -q` confirmed), rerun: exit 0.
- [x] `scripts/validate.sh quick` on real repo state — confirms green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

None.

<!-- Rulings (not deviations — no invariant crossed, no file outside Declared Files touched):
- Ruling: executing-plans' generic sdd-workspace/task-start/task-done tooling and worktree
  setup assume a `docs/superpowers/plans/*.md` Task-N plan file and an adopted worktree
  convention. Neither applies: the plan was deliberately adapted into this repo's own
  story.md + workpad.md shape (per harness-intake's house-convention precedence), and
  per-story worktrees are an unimplemented HARNESS_BACKLOG.md proposal, not current policy.
  Executing inline in the main workspace, using this workpad's own Plan/Notes/Deviations
  sections as the ledger, satisfies the skill's actual intent (step-by-step, verified,
  recorded, fresh review at the end) without inventing unadopted process. Cost if wrong:
  none — this is tooling-fit judgment, not a scope or behavior change.
- Ruling: satisfying the AC "all five Harness Change Policy categories stated at L3" by
  naming them in docs/HARNESS.md's new taxonomy section with a cross-reference to
  CLAUDE.md's Harness Change Policy, rather than editing CLAUDE.md itself (CLAUDE.md is
  not in Declared Files for this story; editing it belongs to US-005's managed-block work).
  Cost if wrong: a later story edits CLAUDE.md anyway and finds the cross-reference
  redundant — cheap to reconcile.
-->


## Notes

- 2026-11-01: Story created (todo), workpad created, transitioning to in_progress. Execution method: Native (per superpowers:writing-plans handoff, maintainer's choice).
- 2026-11-01: Synced with origin/main. Result: clean. HEAD: 0c3ea51

## Confusions

<!-- only include when something was genuinely unclear during execution -->
