# US-008 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-008.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@8b8fd54` (branch `main`)

## Plan

- [x] Step 1: Removed `override_protected_target_paths()` and its 2 call sites; `FORCE=1` set instead when override is chosen (flag or interactive).
- [x] Step 2: Implemented `merge_claude_md()` (create / append / replace-span); removed `CLAUDE.md` from the manifest heredoc and from `check_protected_target_paths()`'s conflict list; called unconditionally in the main flow.
- [x] Step 3: Updated the interactive prompt text and `README.md`'s `--override` description.
- [x] Step 4: Simplified `global-skills/harness-install/SKILL.md` (and copied to `~/.claude/skills/harness-install/SKILL.md`) — dropped the now-redundant manual merge steps (script does it natively now).
- [x] Step 5: `bash -n` + `harness-check.sh` + `validate.sh quick` on harness-scaffold itself — all green.
- [x] Step 6: Fixture: harness file (`docs/ARCHITECTURE.md`) + non-harness file (`docs/my-own-notes.md`) under `docs/`, `--override --force` — non-harness file byte-identical and absent from backup; harness file backed up + replaced.
- [x] Step 7: Fixture: `merge_claude_md()` append case (target `CLAUDE.md`, no markers) and replace-span case (target already has a `HARNESS:BEGIN/END` pair with stale inner content) — both byte-identical outside the affected region, exactly one marker pair afterward.
- [x] Step 8: Confirmed self-skip (installing into harness-scaffold itself) still works; `--merge` for non-`CLAUDE.md` files unchanged.
- [x] Step 9: Updated `docs/TEST_MATRIX.md`.
- [ ] Step 10: Commit, push. **Dogfood `harness-supervise` deferred** — session usage limit reached; this run stops after commit/push without the independent review this story's own process otherwise requires. Flagging this explicitly rather than skipping it silently.

## Acceptance Criteria

- [x] `override_protected_target_paths()` removed; override → `FORCE=1`.
- [x] Fixture proves non-manifest file survives, manifest file gets backed up + replaced.
- [x] `merge_claude_md()` implemented; CLAUDE.md out of the manifest loop and out of the conflict-prompt trigger.
- [x] Append + replace-span fixtures both prove byte-identity outside the affected region.
- [x] `--merge` for other files unchanged.
- [x] Prompt + README text corrected; `harness-install` skill simplified.
- [x] harness-check.sh / validate.sh quick green.

## Validation

- [x] `bash -n scripts/install-harness.sh` → `SYNTAX_OK`.
- [x] Two-file fixture via `--override --force` → non-harness file `SURVIVED at original path`, `CONTENT IDENTICAL`, 0 hits in `.harness-backup/`; harness file content changed (old content gone) and backed up.
- [x] CLAUDE.md append-case fixture → original 5 lines `IDENTICAL`, exactly 1 marker pair appended.
- [x] CLAUDE.md replace-span-case fixture → content before/after the block both present (count 1 each), old stale inner content gone (0), new upstream content present (1), exactly 1 marker pair.
- [x] Self-skip regression check (install into harness-scaffold itself) → all files reported `skip ... (source file)`, including `CLAUDE.md`.
- [x] `scripts/validate.sh quick` green throughout.

## Deviations

None.

## Notes

- 2026-11-03: Synced with origin/main. Result: clean. HEAD: 8b8fd54
- 2026-11-03: Story created (todo), workpad created. Direct on `main`, no feature branch, per Decision 0009. Confirmed root cause by reading `override_protected_target_paths()` directly: it `mv`s the whole `CLAUDE.md`/`docs`/`scripts` paths to `.harness-backup/`, which moved LeanGoes-Dict's own unrelated `docs/` content (e.g. `.superpowers`-related material) along with the harness files when `--override --force` was run there in US-007's validation. Maintainer already restored the affected files directly in LeanGoes-Dict; this story only fixes harness-scaffold's own logic, no further changes to that repo.

## Confusions

<!-- only include when something was genuinely unclear during execution -->
