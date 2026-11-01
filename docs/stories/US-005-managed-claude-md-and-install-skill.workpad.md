# US-005 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-005.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@1371283` (branch `story/US-005-managed-claude-md-and-install-skill`)

## Plan

- [x] Step 1 (done pre-workpad, see Notes): wrapped `CLAUDE.md` in managed markers.
- [x] Step 2: Write `global-skills/harness-install/SKILL.md`.
- [x] Step 3: Write `.claude/skills/harness-intake/references/pstack-routing.md`.
- [x] Step 4: Add one-line reference to it from `harness-intake/SKILL.md`.
- [x] Step 5: Copied `harness-install/SKILL.md` to `~/.claude/skills/harness-install/SKILL.md`.
- [x] Step 6: Manual simulation of the managed-block merge in the scratchpad (not a real target repo): extracted this repo's own block via the documented `sed` command (100 lines, correct BEGIN/END bounds); simulated first-install-into-existing-file via append (pre-existing 6 lines verified byte-identical after); simulated a re-merge/update via an awk-based span replace (pre-existing content still byte-identical, block content updated to a deliberately tweaked value, exactly one BEGIN/END pair afterward — no duplication). The replace step used `awk`, not the `sed`-pair the SKILL.md prose sketches — both achieve the same described behavior and exact tool choice is `[FLEX]` per the story's Invariants.
- [x] Step 7: Ran `scripts/harness-check.sh` and `scripts/validate.sh quick` — green with `global-skills/` and the new `references/` file present (confirms neither trips the drift-check, as designed).
- [x] Step 8: Updated `docs/TEST_MATRIX.md`.
- [ ] Step 9: Commit, push, open PR, dogfood `harness-supervise`.

## Acceptance Criteria

- [x] `CLAUDE.md` wrapped, content unchanged in substance.
- [x] `global-skills/harness-install/SKILL.md` exists, documents wrap-the-script + managed-block-merge behavior.
- [x] Also written to `~/.claude/skills/harness-install/SKILL.md`.
- [x] `references/pstack-routing.md` exists with the five named touchpoints, each with a pstack-absent fallback, and an explicit note rejecting "never block" autonomy.
- [x] `harness-intake` references the routing map by path, not inlined.
- [x] `harness-check.sh` / `validate.sh quick` stay green with the new paths present.

## Validation

- [x] `bash -n scripts/install-harness.sh` — Result: `SYNTAX_OK` (confirms unchanged beyond the two added manifest lines).
- [x] `scripts/harness-check.sh` green with `global-skills/` and the new `references/` file present. Result: `ok: harness-check passed — 5 story packet(s) validated, no violations.`
- [x] Manual merge simulation (scratchpad, not a real repo): first-install append preserves pre-existing content byte-identical (`diff` confirmed), re-merge replaces only the marker span (pre-existing content still byte-identical, block content updated, exactly one BEGIN/END pair).
- [x] `scripts/validate.sh quick` green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

None.

## Notes

- 2026-11-01: Story created (todo), workpad created, branch
  `story/US-005-managed-claude-md-and-install-skill` created from
  `main`@`1371283`, transitioning to in_progress.
- 2026-11-01: Synced with origin/main. Result: clean. HEAD: 1371283
- 2026-11-01: `CLAUDE.md` was wrapped in managed markers (Step 1) before this
  workpad existed, while still scoping the story — pure addition of marker
  lines and one explanatory comment, verified by eye against the original
  (no instruction text altered, removed, or reordered). No deviation: this
  is exactly what the story's own Declared Files and first Invariant call for.

## Confusions

<!-- only include when something was genuinely unclear during execution -->
