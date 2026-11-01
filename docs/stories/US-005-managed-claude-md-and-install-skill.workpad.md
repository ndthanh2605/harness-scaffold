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

- [x] `bash -n scripts/install-harness.sh` — Result: `SYNTAX_OK` (confirms unchanged beyond the one added manifest line for `pstack-routing.md` — see D1, this file was touched but not originally declared).
- [x] `scripts/harness-check.sh` green with `global-skills/` and the new `references/` file present. Result: `ok: harness-check passed — 5 story packet(s) validated, no violations.`
- [x] Manual merge simulation (scratchpad, not a real repo): first-install append preserves pre-existing content byte-identical (`diff` confirmed), re-merge replaces only the marker span (pre-existing content still byte-identical, block content updated, exactly one BEGIN/END pair).
  - First run's scratch artifacts were deleted immediately after, which the
    `harness-supervise` dogfood run correctly flagged as unverifiable by
    rerun — it does not count as proof by the skill's own standard.
  - Re-ran the identical simulation fresh (commands above, unchanged) and
    **kept the artifacts this time** at a scratchpad path recorded below, so
    a reviewer can independently reverify without re-deriving the commands:
    `block_lines=100 total_lines=100` (the whole file is the block, since
    this repo's `CLAUDE.md` has no project-specific content outside it
    yet), `APPEND_OK_IDENTICAL`, `REMERGE_OK_IDENTICAL`, exactly one
    `HARNESS:BEGIN`/`HARNESS:END` pair after the re-merge, and the updated
    block content (`Harness v0.1`) present exactly once.
- [x] `scripts/validate.sh quick` green. Result: `=== validate:quick passed ===`, exit 0.

## Deviations

### D1 — Touched `scripts/install-harness.sh` without declaring it (status: ratified)
- Planned: `## Declared Files` listed `CLAUDE.md`, `global-skills/harness-install/
  SKILL.md`, `.claude/skills/harness-intake/SKILL.md`,
  `.claude/skills/harness-intake/references/pstack-routing.md`,
  `docs/TEST_MATRIX.md`, and the story/workpad — `scripts/install-harness.sh`
  was not listed.
- Actual: added one manifest line to `scripts/install-harness.sh` so
  `pstack-routing.md` (a declared file) is actually shipped downstream. This
  is the same, already-established pattern as US-003 and US-004 (every new
  skill/reference file needs a manifest line) but was missed when writing
  this story's Declared Files.
- Crosses invariant: an undeclared touched file — a Stop Condition per
  `docs/HARNESS.md`'s Plan Deviation Protocol.
- Why: an authoring oversight when scoping the story — caught by the
  `harness-supervise` dogfood run on this commit, not by the implementing
  agent before committing.
- Resolution: `## Declared Files` corrected to add `scripts/install-harness.sh`.
  Ratified by the maintainer in chat, 2026-11-01.

### D2 — same pattern as US-002/US-003/US-004 D1 (status: ratified)
- Merge approval given in chat, not as a formal GitHub PR review. See
  `docs/HARNESS_BACKLOG.md` → "Formal Merge-Approval Mechanism Doesn't Match
  Solo-Maintainer Reality". Will be recorded here once given.

## Notes

- 2026-11-01: Dogfooded `harness-supervise` on the implementation commit via a
  fresh, no-shared-context agent. Verified: CLAUDE.md diff is +8/-0, no deletions
  or reordering (self-checked independently, not taken on faith), extracted block
  line count matches file total, harness-install SKILL.md copied identically to
  `~/.claude/skills/harness-install/`, pstack-routing.md has all 5 touchpoints with
  fallbacks and the explicit never-block rejection, harness-intake only references
  it by path. Found two real gaps: (1) `scripts/install-harness.sh` was touched
  (one manifest line for pstack-routing.md) without being declared — recorded as
  D1, ratified; (2) the first manual merge-simulation's scratch artifacts were
  deleted before the dogfood run, making that evidence unrerunnable by the skill's
  own standard — re-ran the simulation fresh and kept the artifacts this time (see
  Validation above). Correctly escalated two items rather than resolving them:
  the CLAUDE.md ownership-comment (traces to Decision 0007, already Accepted) and
  the Declared Files gap (D1) — maintainer confirmed both ok in chat, 2026-11-01.
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
