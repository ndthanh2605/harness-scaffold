# US-006 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-006.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@2146b4d` (branch `main` — no feature branch, per Decision 0009 this story itself implements)

## Plan

- [x] Step 1: Updated `docs/HARNESS.md` state machine table (dropped PR language) + fixed the two deferred-minor wording issues (garbled sentence, one-level drift-check wording) + "pull skill" naming.
- [x] Step 2: Updated `CLAUDE.md` Task Loop checklist (dropped "land") + Source of Truth skill list note.
- [x] Step 3: Simplified `harness-git-push/SKILL.md` (dropped PR creation, pushes directly, records pushed SHA in Evidence instead of PR URL).
- [x] Step 4: Deprecated `harness-git-land/SKILL.md` (frontmatter + body notice, file kept).
- [x] Step 5: Fixed `principle-default-posture/SKILL.md` naming.
- [x] Step 6: Broadened `scripts/harness-check.sh`'s reverse-direction check to cover all `.claude/skills/` manifest entries, not just `SKILL.md`; added CRLF-stripping (`gsub(/\r$/, "")`) to the heredoc extraction.
- [x] Step 7: Closed the `HARNESS_BACKLOG.md` item, referencing ADR-0009 and this story.
- [x] Step 8: Ran `harness-check.sh` + `validate.sh quick` (green); proved the broadened reverse-check with a new fixture (non-`SKILL.md` manifest entry pointing nowhere → FAIL; restored, confirmed via `git status`/`git diff --stat` that the restore was byte-clean, not just visually similar — the first restore check surfaced CRLF/LF diff noise from comparing against `git show`, resolved by trusting git's own diff instead of raw `diff`).
- [x] Step 9: Updated `docs/TEST_MATRIX.md`.
- [ ] Step 10: Commit, push directly to `main`, dogfood `harness-supervise`.

## Acceptance Criteria

- [x] State machine gates PR-free.
- [x] `harness-git-push` simplified, `harness-git-land` deprecated not deleted.
- [x] `CLAUDE.md` checklist updated.
- [x] Backlog item closed.
- [x] Garbled sentence fixed.
- [x] Drift-check wording matches actual one-level behavior.
- [x] Reverse-check covers all `.claude/skills/` manifest entries.
- [x] CRLF-stripping added to extraction.
- [x] "pull skill" → `harness-git-pull` fixed in both places.

## Validation

- [x] `bash -n scripts/harness-check.sh` — Result: `SYNTAX_OK`.
- [x] New fixture: non-SKILL.md manifest entry pointing nowhere → `FAIL: scripts/install-harness.sh: manifest entry '.claude/skills/harness-intake/references/does-not-exist.md' does not exist in this repo`, exit 1; restored, confirmed clean via `git status`/`git diff --stat` (empty output).
- [x] Existing `scripts/harness-check.sh` run on real repo state → `ok: harness-check passed — 6 story packet(s) validated, no violations.`
- [x] `scripts/validate.sh quick` green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

None.

## Notes

- 2026-11-01: Synced with origin/main. Result: clean. HEAD: 2146b4d
- 2026-11-01: Story created (todo), workpad created. No feature branch —
  this is the first story to adopt Decision 0009's own new convention
  (direct-to-main) while implementing that same decision.

## Confusions

<!-- only include when something was genuinely unclear during execution -->
