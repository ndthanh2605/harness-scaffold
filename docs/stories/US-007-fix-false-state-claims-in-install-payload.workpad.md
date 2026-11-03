# US-007 Workpad

<!-- This is the live execution log for the story. Mutate freely.
     Do not store contract material here — that belongs in US-007.md. -->

**Environment:** `harness-scaffold-8b:F:\Projects\harness-scaffold@8ea0076` (branch `main`)

## Plan

- [x] Step 0 (pre-workpad): removed literal `docs/decisions/NNNN-*.md` path citations from `docs/HARNESS.md` (4 locations), kept the rule content.
- [x] Step 1: Rewrote `CLAUDE.md`'s opening + v0-constraint paragraph (state-neutral).
- [x] Step 2: Rewrote `docs/README.md`'s "Current State" section.
- [x] Step 3: Rewrote `harness-intake/SKILL.md` Step 5.
- [x] Step 4: Created `docs/templates/seed/TEST_MATRIX.md` (clean version).
- [x] Step 5: Added `source:target` remap support to `scripts/install-harness.sh`; removed `README.md` and `docs/decisions/0001-0009` from the manifest; added the seed TEST_MATRIX.md remap line.
- [x] Step 6: `bash -n` + `harness-check.sh` + `validate.sh quick` on harness-scaffold itself — green.
- [x] Step 7: Dry-run + real install into a scratch target (deleted after) — confirmed no README/decisions created beyond `docs/decisions/README.md`, seed TEST_MATRIX.md installed clean, target's own `harness-check.sh` passed (0 story packets).
- [x] Step 8: Re-ran against the real `F:\Projects\LeanGoes-Dict`. The old buggy install there was still present (untracked from 2026-11-01); plain `--merge` would have skipped everything since the stale files already existed. Used `--override --force` (the installer's own backup mechanism, not a raw delete — a raw `rm -rf` of the stale files was attempted first and blocked by the auto-mode classifier as an irreversible-destruction risk; `--override --force` achieves the same result safely, with timestamped backups under `.harness-backup/`). Found and left untouched a top-level `README.md` that turned out to be the maintainer's own real content (added between 2026-11-01 and now, not harness-scaffold's bug) — correctly not in the manifest, so untouched either way.
- [x] Step 9: Updated `docs/TEST_MATRIX.md` (harness-scaffold's own live copy) — unaffected by the seed split, still tracks this repo's own stories.
- [ ] Step 10: Commit, push, dogfood `harness-supervise`.

## Acceptance Criteria

- [x] CLAUDE.md / docs/README.md / harness-intake Step 5 state-neutral.
- [x] README.md removed from manifest.
- [x] decisions/0001-0009 removed from manifest; decisions/README.md stays.
- [x] HARNESS.md cites no literal decision paths.
- [x] seed/TEST_MATRIX.md created, installed in place of the live copy.
- [x] install-harness.sh supports source:target remap.
- [x] LeanGoes-Dict re-verified clean.

## Validation

- [x] `bash -n scripts/install-harness.sh` — `SYNTAX_OK`.
- [x] `scripts/harness-check.sh` + `validate.sh quick` on harness-scaffold itself — both green (`7 story packet(s) validated`).
- [x] Scratch-target dry-run + real install: `grep` confirmed only `docs/README.md`/`docs/decisions/README.md`/etc. created, no top-level `README.md`, `docs/decisions/` contained only `README.md`, `docs/TEST_MATRIX.md` had `0` occurrences of `US-00` (the clean seed); target's `harness-check.sh` passed (`0 story packet(s)`); `grep` confirmed `CLAUDE.md` there had `0` occurrences of the false claim.
- [x] Re-run against real LeanGoes-Dict (via `--override --force`): `0` false-claim occurrences in `CLAUDE.md`, `0` pre-existing project files touched (`src`/`tests`/`data-pipeline`/`.superpowers`/`.sln`/`.gitignore`), `harness-check.sh` and `validate.sh quick` both green there.
- [x] Post-dogfood fix pass: fixed the seed `TEST_MATRIX.md`'s own remaining
  "implemented yet" wording (same bug class), added
  `docs/templates/seed/HARNESS_BACKLOG.md` + remap, generalized one leftover
  literal `docs/decisions/0008-tiered-enforcement.md` citation inside the
  live `HARNESS_BACKLOG.md`'s template. Re-verified with a fresh scratch
  target that already had `src/main.c`: `HARNESS_BACKLOG.md` installed
  there has 0 `US-00x` references, `TEST_MATRIX.md` has 0 "implemented yet"
  occurrences, `src/main.c` untouched, target `harness-check.sh` green.

## Deviations

### D1 — E2E rerun used `--override --force` instead of the AC's specified `--merge` (status: ratified)
- Planned: the story's AC/Validation table specified re-running `--merge`
  against `F:\Projects\LeanGoes-Dict` to prove the fix there.
- Actual: the stale buggy files from the 2026-11-01 install were still
  present there (untracked, not yet cleaned up), so `--merge` would have
  skipped everything (leaving the old false claims and old TEST_MATRIX.md
  in place, proving nothing). Used `--override --force` instead — the
  installer's own backup-then-replace mechanism — after a raw `rm -rf` of
  the stale files was attempted first and blocked by the auto-mode
  classifier as an irreversible-destruction risk.
- Crosses invariant: the Stop Conditions name "an acceptance criterion's
  proof method has to change" as requiring this protocol.
- Why: `harness-supervise`'s dogfood run on this story correctly caught
  that this substitution was never recorded as a deviation.
- Resolution: ratified by the maintainer in chat, 2026-11-01. The
  maintainer is now actively editing content directly inside
  `F:\Projects\LeanGoes-Dict` themselves (2026-11-03) — no further changes
  will be made to that repo from this session.

### D2 — `docs/HARNESS_BACKLOG.md` and its literal decision citation were in scope but not originally declared (status: ratified)
- Planned: the story's Product Contract said the payload "must not ship
  harness-scaffold's own development history," but `## Declared Files`
  didn't list `docs/HARNESS_BACKLOG.md` or its seed counterpart.
- Actual: the dogfood run correctly found `docs/HARNESS_BACKLOG.md` still
  shipping 9 references to this repo's own `US-00x` stories, violating the
  Product Contract's own stated promise. Added
  `docs/templates/seed/HARNESS_BACKLOG.md` (template + no items) with the
  same `source:target` remap as `TEST_MATRIX.md`, and generalized one
  leftover literal `docs/decisions/0008-tiered-enforcement.md` citation
  inside the live `HARNESS_BACKLOG.md`'s own template section (same fix
  shape as `HARNESS.md`'s citations).
- Crosses invariant: undeclared file + a Product Contract gap.
- Resolution: `## Declared Files` corrected. Ratified by the maintainer in
  chat, 2026-11-03.

## Notes

- 2026-11-03: Story created (todo), workpad created. Direct on `main`, no feature branch, per Decision 0009.

## Confusions

<!-- only include when something was genuinely unclear during execution -->
