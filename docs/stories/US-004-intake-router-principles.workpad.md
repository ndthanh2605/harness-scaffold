# US-004 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-004.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@c53224e` (branch `story/US-004-intake-router-principles`)

## Plan

- [x] Step 1: Write the four `principle-*/SKILL.md` files.
- [x] Step 2: Add the four paths to `scripts/install-harness.sh`'s manifest.
- [x] Step 3: Add `**Relevant principles:**` line to `harness-intake`'s Intake Report format + a `harness-supervise` note near Step 7.
  - Found and fixed a self-introduced markdown bug: the edit left a stray,
    unmatched closing ` ``` ` fence after the new lane-mapping table (the
    original fence closed correctly right after the report template; my
    insertion appended more content, including a second, orphaned fence,
    after it). Fixed by removing the stray fence — not a plan deviation
    (no invariant crossed, same file, caught and fixed before any commit).
- [x] Step 4: Ran `scripts/harness-check.sh` and `scripts/validate.sh quick` — green. Also ran a negative check (removed `principle-enforcement-tiers` from the manifest, confirmed FAIL, restored, confirmed clean).
- [x] Step 5: Updated `docs/TEST_MATRIX.md`.
- [ ] Step 6: Commit, push, open PR, dogfood `harness-supervise` on this story.

## Acceptance Criteria

- [x] Four skills exist with `disable-model-invocation: true`.
- [x] Each short, pointing back to `docs/HARNESS.md`.
- [x] `harness-intake`'s 7 steps unchanged; Intake Report gains Relevant-principles line.
- [x] Manifest includes all four new paths.
- [x] Drift-check passes with all four present and listed.

## Validation

- [x] `bash -n scripts/install-harness.sh` — Result: `SYNTAX_OK`.
- [x] `scripts/harness-check.sh` green with all four present and listed. Result: `ok: harness-check passed — 4 story packet(s) validated, no violations.`
- [x] Negative check: removed `principle-enforcement-tiers` manifest line, confirmed `FAIL: ... manifest is missing '.claude/skills/principle-enforcement-tiers/SKILL.md' (shipped but not installed downstream)`, exit 1; restored, clean.
- [x] `scripts/validate.sh quick` green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

None.

## Notes

- 2026-11-01: Story created (todo), workpad created, branch `story/US-004-intake-router-principles` created from `main`@`c53224e`, transitioning to in_progress.
- 2026-11-01: Synced with origin/main. Result: clean. HEAD: c53224e

## Confusions

<!-- only include when something was genuinely unclear during execution -->
