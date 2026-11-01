# US-003 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-003.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@10a8122` (branch `story/US-003-harness-supervise`)

## Plan

- [x] Step 1: Write `.claude/skills/harness-supervise/SKILL.md`.
- [x] Step 2: Add the skill's path to `scripts/install-harness.sh`'s manifest.
- [x] Step 3: Update `docs/HARNESS.md`'s L2 bullet and state-machine section to point at the real skill.
- [x] Step 4: Run `scripts/harness-check.sh` and `scripts/validate.sh quick`, confirm green (exercised US-002's drift-check against the new file, both positive and negative).
- [x] Step 5: Update `docs/TEST_MATRIX.md`.
- [ ] Step 6: Commit via `harness-git-commit`, push branch via `harness-git-push`, open PR.

## Acceptance Criteria

- [x] `harness-supervise/SKILL.md` exists, matches house skill shape (frontmatter + Goal/Inputs/Steps/Output/Related Skills).
- [x] Steps independently check Declared Files, Deviations ratified, rerun Validation, check Evidence substantiation.
- [x] Output framed as a report ("Verified" / "Needs your decision"), never an approval.
- [x] Explicit refusal to clear L3-category items — must escalate (Hard Boundary section + Step 5 of the skill).
- [x] `docs/HARNESS.md` L2 bullet + state-machine section updated.
- [x] `scripts/install-harness.sh` manifest includes the new skill.

## Validation

- [x] `bash -n scripts/install-harness.sh` — Result: `SYNTAX_OK`.
- [x] `scripts/harness-check.sh` green with new skill present and listed. Result: `ok: harness-check passed — 3 story packet(s) validated, no violations.`
- [x] Negative check: removed the manifest line for `harness-supervise/SKILL.md`, confirmed `scripts/harness-check.sh` fails (`FAIL: scripts/install-harness.sh: manifest is missing '.claude/skills/harness-supervise/SKILL.md' (shipped but not installed downstream)`, exit 1), restored, confirmed clean again.
- [x] `scripts/validate.sh quick` green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

None.

## Notes

- 2026-11-01: Story created (todo), workpad created, branch `story/US-003-harness-supervise` created from `main`@`10a8122`, transitioning to in_progress.
- 2026-11-01: Synced with origin/main. Result: clean. HEAD: 10a8122

## Confusions

<!-- only include when something was genuinely unclear during execution -->
