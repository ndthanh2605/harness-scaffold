# US-008 Fix Override's Wholesale Move + Implement CLAUDE.md Marker-Merge Natively

## Status

human_review

<!-- State machine (Decision 0009 — no PR):
  todo → in_progress → human_review → merging → done, or any → blocked
-->

## Lane

normal

## Product Contract

Choosing `--override` (or the interactive `2. Override` choice) when
`CLAUDE.md`, `docs/`, or `scripts/` already exist in the target must never
move or delete content that is not part of the harness install manifest.
Only files the manifest actually ships may be backed up and replaced;
anything else already present under those paths — e.g. a target project's
own unrelated docs nested inside `docs/` — must be left exactly where it is.

Separately, and more fundamentally: `CLAUDE.md` must never be treated as an
ordinary whole-file manifest entry at all. Decision 0007 / US-005 specified
a managed-block merge (replace only the content between `<!-- HARNESS:BEGIN
-->`/`<!-- HARNESS:END -->`, leave everything else in the target's own
`CLAUDE.md` untouched) — but that logic was only ever written as prose
instructions in the separate `global-skills/harness-install/SKILL.md`, never
implemented in `scripts/install-harness.sh` itself, which is the thing
anyone actually running `curl ... | bash` (or testing directly, as this
session did) executes. The script's own manifest loop has no awareness of
the marker mechanism at all — `CLAUDE.md` was just another file subject to
skip/override/force, identical to every other manifest entry.

Discovered via real-world use: running `--override --force` against
`F:\Projects\LeanGoes-Dict` (a project with its own pre-existing `docs/`
content, e.g. `.superpowers`-related material, and its own `CLAUDE.md`)
moved that unrelated `docs/` content into `.harness-backup/` along with the
whole `docs/` directory (the first bug), and wholesale-replaced the target's
own `CLAUDE.md` instead of merging into it (the second, deeper bug) — because
`override_protected_target_paths()` operates on `CLAUDE.md`/`docs`/`scripts`
as whole units via `mv`, and the manifest loop's `copy_file()` has no
marker-merge logic for `CLAUDE.md` specifically. The maintainer has already
restored the affected files in that repo directly; no further changes are
needed there — this story fixes both issues in the installer's own logic so
neither failure mode can recur.

## Relevant Product Docs

- `scripts/install-harness.sh`
- `README.md` (documents `--override`'s behavior)
- `docs/stories/US-001-install-harness.md` (original override AC — historical,
  not edited by this story; this story's own AC supersedes its behavior
  going forward, noted via a decision-adjacent backlog cross-reference if
  needed)

## Acceptance Criteria

- `override_protected_target_paths()` (the wholesale `mv` of `CLAUDE.md`/
  `docs`/`scripts`) is removed entirely. Choosing override (flag or
  interactive) now sets `FORCE=1` instead, so the existing, already-correct
  per-file logic in `copy_file()` (which only ever touches files that are
  actually in the install manifest, backing up each individually before
  replacing it) handles every conflict.
  the install manifest remains completely untouched — not moved, not
  deleted, not backed up — regardless of whether it sits inside `docs/`,
  `scripts/`, or is `CLAUDE.md` itself.
- A fixture proves this directly: a scratch target with `docs/
  ARCHITECTURE.md` (a harness file, so a real conflict) *and*
  `docs/my-own-notes.md` (standing in for the target's own unrelated
  content, e.g. `.superpowers`-related docs) gets `--override --force`
  installed. `docs/ARCHITECTURE.md` is backed up and replaced.
  `docs/my-own-notes.md` is untouched — same file, same mtime, same
  content, never appears under `.harness-backup/`.
- `--merge` behavior (the safe default, already correct — it only ever
  skips existing files, never moves anything) is unchanged; this story adds
  no new risk there.
- The top-level conflict-detection prompt and its three choices
  (merge/override/stop) are unchanged in shape; only what "override"
  *does* changes.
- `README.md`'s description of `--override` ("Back up and replace
  CLAUDE.md, docs/, and scripts/") is corrected to describe the real,
  per-file behavior and explicitly state that non-harness content in those
  paths is never touched.
- `scripts/harness-check.sh` and `scripts/validate.sh quick` stay green.

**CLAUDE.md native marker-merge (closes the deeper gap):**
- `CLAUDE.md` is removed from the manifest heredoc loop and handled by a
  dedicated `merge_claude_md()` function, called unconditionally (regardless
  of `--merge`/`--override`), that:
  - Creates a fresh `CLAUDE.md` (byte-identical to this repo's own, which
    already carries the markers) if the target has none.
  - If the target already has a `CLAUDE.md` containing a
    `<!-- HARNESS:BEGIN -->`/`<!-- HARNESS:END -->` pair, backs it up, then
    replaces **only** the content inside that span with the fresh upstream
    block — every byte outside the span, verified unchanged.
  - If the target's existing `CLAUDE.md` has no markers at all, backs it
    up, then appends the fresh upstream block to the end — every byte of
    the original file, verified unchanged, stays above the appended block.
- `CLAUDE.md` is removed from `check_protected_target_paths()`'s conflict
  list entirely — merging is always safe, so it no longer forces the
  merge/override/stop prompt. That prompt now triggers only on `docs/` or
  `scripts/` existing.
- A fixture proves both merge sub-cases directly against a scratch target:
  (a) a target `CLAUDE.md` with its own content and no markers — confirm
  append-only, original content byte-identical above the appended block;
  (b) a target `CLAUDE.md` already containing a `HARNESS:BEGIN/END` pair
  with different inner content — confirm only the span changes, content
  outside the span byte-identical before/after, exactly one marker pair
  afterward.
- `--dry-run` reports what the merge would do without writing.
- `global-skills/harness-install/SKILL.md` (and the copy at
  `~/.claude/skills/harness-install/SKILL.md`) is simplified: Steps 2-3 (the
  manual sed/awk merge instructions) are removed, since the script now does
  this natively. The skill's remaining job is just invoking the script with
  the right flags.

## Design Notes

- Commands: none new.
- Domain rules: `FORCE=1` already has correct, tested per-file backup+replace
  semantics (used today for refreshing already-installed harness files);
  this story reuses it rather than inventing new logic.
- UI surfaces: the interactive prompt's "2. Override" line text is updated
  to describe the corrected behavior.

## Invariants & Flex

- `[INVARIANT]` No file outside the install manifest may ever be moved,
  backed up, or deleted by this installer, under any flag combination.
- `[INVARIANT]` `--merge`'s behavior for files other than `CLAUDE.md` is
  unchanged (already safe).
- `[INVARIANT]` `CLAUDE.md` is never skip/override/force-replaced as a
  whole file — it always goes through `merge_claude_md()`'s marker-aware
  logic, regardless of flags.
- `[INVARIANT]` Content outside the `HARNESS:BEGIN`/`HARNESS:END` span in an
  existing target `CLAUDE.md` is never altered, byte-for-byte, by a merge.
- `[FLEX]` Exact wording of the corrected prompt/README text; exact awk/sed
  implementation of the span-replace, as long as the byte-identity
  guarantee holds.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
scripts/install-harness.sh
README.md
global-skills/harness-install/SKILL.md
docs/TEST_MATRIX.md
docs/stories/US-008-fix-override-wholesale-directory-move.md
docs/stories/US-008-fix-override-wholesale-directory-move.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/install-harness.sh` |
| Integration | The two-file fixture above (harness file + non-harness file, both inside `docs/`), run through `--override --force`: harness file replaced (with backup), non-harness file untouched. Separately: `merge_claude_md()`'s append case (target `CLAUDE.md` with its own content, no markers) and replace-span case (target `CLAUDE.md` already has a `HARNESS:BEGIN/END` pair with different inner content) — both verified byte-identical outside the affected region. Confirm `--merge` for non-`CLAUDE.md` files still behaves as before. |
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

Fixes a confirmed real data-loss-risk defect in the installer's `--override`
path, discovered through actual external-repo use (`F:\Projects\LeanGoes-Dict`).
No changes made to that repo by this story — it was already restored by the
maintainer directly.

## Workpad

Execution state lives in `docs/stories/US-008-fix-override-wholesale-directory-move.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Fixture 1 (override wholesale-move bug): scratch target with
  `docs/ARCHITECTURE.md` (harness file) + `docs/my-own-notes.md`
  (non-harness, stand-in for LeanGoes-Dict's own content). `--override
  --force` → `my-own-notes.md` survived at its original path, content
  byte-identical, 0 occurrences under `.harness-backup/`.
  `ARCHITECTURE.md` content changed (old stale text gone) and was backed
  up.
- Fixture 2 (CLAUDE.md append case): target `CLAUDE.md` with 5 lines of
  its own content, no markers. `--merge` → original 5 lines
  byte-identical at the top, exactly one `HARNESS:BEGIN`/`END` pair
  appended after.
- Fixture 3 (CLAUDE.md replace-span case): target `CLAUDE.md` with its own
  content above and below an existing (stale) `HARNESS:BEGIN`/`END` pair.
  `--merge` → content before and after the block both present unchanged,
  stale inner content gone, fresh upstream content present, exactly one
  marker pair.
  self-skip still correctly triggers for every manifest file, `CLAUDE.md`
  included.
- `bash scripts/harness-check.sh` / `bash scripts/validate.sh quick` on
  harness-scaffold's own repo state → green throughout.
- **Not yet done:** the `harness-supervise` independent-rerun dogfood this
  story's own process calls for was deferred — the session's usage limit
  was reached before it could run. Status set to `human_review` rather
  than `done` to reflect this honestly; a fresh dogfood pass should run
  before merging.
