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
- [x] CRLF fix, reworked after dogfood found the first version didn't actually
  fix the claimed bug (see Notes): moved `sub(/\r$/, "")` to an unconditional
  first awk rule (strips every line before pattern matching), instead of
  `gsub` only inside the capture block (which left the `/^done <<.EOF.$/`
  and `/^EOF$/` marker regexes themselves vulnerable to a trailing `\r`).
  Tested against a literal-CRLF file built byte-for-byte with `printf`
  (confirmed via `xxd`): new version correctly extracts exactly the 2
  expected lines, with `cat -A` confirming no leftover `^M`. **Honesty
  note:** this environment's `awk` (MSYS gawk) strips `\r` during its own
  line-splitting regardless of script content (`printf 'hello\r\n' | awk
  '{print length($0)}'` → `5`, not `6`) — so the *old*, buggy version also
  "passed" this same literal-CRLF fixture here, for a reason unrelated to
  the fix. The new version is correct by POSIX awk semantics (desk-checked:
  stripping before matching is strictly safer than stripping only inside an
  already-matched block), but the before/after difference could not be
  empirically demonstrated in this sandbox, only reasoned about. Recorded
  honestly rather than claimed as proven.

## Deviations

### D1 — Touched `.claude/skills/harness-intake/SKILL.md` without declaring it (status: ratified)
- Planned: `## Declared Files` did not list `harness-intake/SKILL.md`.
- Actual: the `harness-supervise` dogfood run on `07b2cf9` found a stale
  reference ("before presenting the PR") left over from before Decision
  0009 in `harness-intake/SKILL.md` line 145, outside this story's declared
  scope at the time. Fixed it to say "before presenting the work to the
  human (Decision 0009: no PR required...)".
- Crosses invariant: an undeclared touched file — a Stop Condition.
- Why: this story's Declared Files only covered the files I planned to
  touch for the PR-gate retirement itself; it missed that the change would
  leave a stale cross-reference in a file cited by, but not part of, this
  story's original scope. Caught by the dogfood run, not by me before
  committing.
- Resolution: `## Declared Files` corrected to add
  `.claude/skills/harness-intake/SKILL.md`. Ratified by the maintainer in
  chat, 2026-11-01.

### D2 — same pattern as US-002 through US-005 D1/D2 (status: ratified) — last occurrence
- Merge approval given in chat, not as a formal GitHub PR review. This is
  the last story to record this as a deviation: Decision 0009, which this
  story implements, makes chat approval the standing rule from here on, not
  an exception needing ratification each time.
- Resolution: the maintainer confirmed in chat, 2026-11-01, that this
  story's implementation of Decision 0009 (no PR, no feature branch, chat
  approval, direct push to main) matches what they approved.

## Notes

- 2026-11-01: Dogfooded `harness-supervise` on commit `07b2cf9` via a fresh,
  no-shared-context agent. Verified all L0-L2 items (Declared Files exact
  match, no open deviations at the time, unit/integration/E2E reruns
  matched, all ACs for the PR-gate retirement and the wording/naming minors
  confirmed by direct grep, the stricter-not-weaker INVARIANT confirmed by
  reading the actual diff). Found two real, substantive issues, both fixed:
  (1) the CRLF fix was reworked (see Validation above) after the dogfood
  correctly identified it didn't actually fix the claimed bug — the marker
  regexes themselves were vulnerable, not just the captured lines; (2) a
  stale "before presenting the PR" phrase was found in
  `harness-intake/SKILL.md`, outside this story's original Declared Files —
  fixed, recorded as D1, ratified. Also correctly noted (without blocking):
  a standalone tiny-lane commit (`81d761f`, fixing the install manifest's
  missing decision records, discovered via the separately-requested
  LeanGoes-Dict install test) appeared on `main` during the review and
  wasn't declared in any story — confirmed with the maintainer as an
  accepted, intentional tiny-lane patch per `docs/FEATURE_INTAKE.md`'s own
  rule that tiny-lane changes are patched directly, no story required.
  Escalated rather than resolved the L3 item (this story's own
  feature-workflow change) — maintainer confirmed the implementation
  matches what they approved.
- 2026-11-01: Synced with origin/main. Result: clean. HEAD: 2146b4d
- 2026-11-01: Story created (todo), workpad created. No feature branch —
  this is the first story to adopt Decision 0009's own new convention
  (direct-to-main) while implementing that same decision.

## Confusions

<!-- only include when something was genuinely unclear during execution -->
