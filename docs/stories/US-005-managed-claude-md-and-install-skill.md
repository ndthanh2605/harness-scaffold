# US-005 Managed CLAUDE.md Block + harness-install Skill

## Status

done

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-005.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix row updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

normal

## Product Contract

This repo's own `CLAUDE.md` is wrapped in a managed `<!-- HARNESS:BEGIN -->`
/ `<!-- HARNESS:END -->` block covering its entire harness-authored content,
dogfooding the overlay mechanism Decision 0007 specifies. A new global skill,
`harness-install`, wraps `scripts/install-harness.sh` for bulk file copy and
adds the one thing the script cannot do: merge that managed block into a
target project's own, pre-existing `CLAUDE.md` without touching content
outside the markers. `harness-intake` gains an optional, narrow
`references/pstack-routing.md` mapping specific harness-workflow moments to
specific `pstack` skills, explicitly soft/optional.

This is Plan 4 of 4 implementing `docs/decisions/0007` and closes the
template/overlay roadmap this story series opened with. It builds on US-002
(taxonomy language), US-003 (`harness-supervise`, cited by the routing map),
and US-004 (`principle-*` skills, cited by `harness-intake`).

## Relevant Product Docs

- `docs/decisions/0007-overlay-authority-and-explicit-invocation.md` (items 1, 3, 4)
- `CLAUDE.md` (the file being wrapped)
- `scripts/install-harness.sh` (wrapped by the new skill for bulk copy)
- `.claude/skills/harness-intake/SKILL.md` (gains the routing-map reference)

## Acceptance Criteria

- `CLAUDE.md`'s entire existing content is wrapped, unchanged in substance,
  in `<!-- HARNESS:BEGIN -->` / `<!-- HARNESS:END -->` markers with a short
  explanatory comment inside the opening marker. No line of existing
  instruction text is altered, removed, or reordered — this is a pure
  wrapping edit.
- A new file, tracked in this repo at `global-skills/harness-install/
  SKILL.md` (deliberately **not** under `.claude/skills/`, so US-002's
  drift-check — which scans everything shipped to consumers — does not treat
  it as part of the downstream payload; this skill is a tool that *uses*
  this repo as a source, not part of what gets installed into a consumer),
  documents the `harness-install` skill: explicit-invoke only, run from a
  target project's working directory, wraps `scripts/install-harness.sh
  --merge` (or `--override`/`--dry-run` per the human's instruction) for
  bulk payload copy, then performs the managed-block merge for `CLAUDE.md`
  specifically (create the file with the block if absent; if present,
  replace only the content between the markers, byte-for-byte reproducible,
  leaving everything outside untouched; idempotent on repeated runs).
- The same file is also written to `~/.claude/skills/harness-install/
  SKILL.md` (the maintainer's actual global skill directory) so it is
  immediately usable, with a note in the story Evidence recording that this
  step is a one-time local action outside the repo's own git history.
- `.claude/skills/harness-intake/references/pstack-routing.md` exists,
  mapping exactly the touchpoints agreed in Decision 0007's context (high-risk
  execplan design → `pstack:architect`; Growth Rule transcript-mining →
  `pstack:reflect`; human_review-gate critique → `pstack:interrogate`;
  parallel research/exploration → `pstack:swarm`/`pstack:arena`; validation-hook
  generation → `pstack:create-verification-skill`), each with an explicit
  fallback for when `pstack` is not installed, and a note that
  `principle-never-block-on-the-human`-style autonomy is **not** adopted —
  Harness Change Policy gates remain authoritative.
- `harness-intake`'s `SKILL.md` references the new file by path (one line),
  without inlining its content.
- `scripts/harness-check.sh` and `scripts/validate.sh quick` stay green —
  the new `global-skills/` path and the new `references/` file must not
  trip the existing drift-check (verify both explicitly).

## Design Notes

- Commands: `harness-install` (new, global, explicit-invoke only;
  `harness-install --directory <path>` mirroring `scripts/install-harness.sh`'s
  own flag shape for familiarity).
- Domain rules: managed-marker overlay precedent from `repository-harness`
  (Decision 0007 context); `pstack-routing.md` stays optional/soft per
  Decision 0007 item 4.
- UI surfaces: terminal output of `harness-install`, mirroring
  `scripts/install-harness.sh`'s existing log style.

## Invariants & Flex

- `[INVARIANT]` `CLAUDE.md`'s existing instruction text is not altered in
  substance — only marker lines and one explanatory comment are added.
- `[INVARIANT]` `harness-install` lives at `global-skills/harness-install/
  SKILL.md` in this repo, not under `.claude/skills/` — keeps it out of
  US-002's drift-check and the downstream install manifest.
- `[INVARIANT]` The managed-block merge touches only content between the
  markers; content outside is never modified, matching Decision 0007.
- `[INVARIANT]` `references/pstack-routing.md` states explicitly, for every
  mapped touchpoint, what happens when `pstack` is absent (never a hard
  dependency), and explicitly notes that `pstack`'s "never block" autonomy
  posture is not adopted.
- `[FLEX]` Exact wording of `harness-install`'s SKILL.md steps; exact
  touchpoint wording in the routing map, beyond the five named in the AC.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
CLAUDE.md
global-skills/harness-install/SKILL.md
.claude/skills/harness-intake/SKILL.md
.claude/skills/harness-intake/references/pstack-routing.md
scripts/install-harness.sh
docs/TEST_MATRIX.md
docs/stories/US-005-managed-claude-md-and-install-skill.md
docs/stories/US-005-managed-claude-md-and-install-skill.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/install-harness.sh` (unchanged, confirms no accidental edit) |
| Integration | `scripts/harness-check.sh` passes with `global-skills/` and the new `references/` file present (confirms neither trips the drift-check); a manual dry-run of the `harness-install` steps against a scratch target directory demonstrates the managed-block merge is idempotent and leaves pre-existing content untouched. |
| E2E | `scripts/validate.sh quick` passes on the real repo state after the change. |
| Platform | POSIX shell commands exercised by the manual dry-run, consistent with prior stories. |
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

Implements `docs/decisions/0007-overlay-authority-and-explicit-invocation.md`
items 1, 3, and 4 — the last piece of the 4-plan roadmap opened by Decisions
0007/0008.

## Workpad

Execution state lives in `docs/stories/US-005-managed-claude-md-and-install-skill.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Merged: https://github.com/ndthanh2605/harness-scaffold/pull/4 at `5076bd6` on 2026-11-01.
- PR: https://github.com/ndthanh2605/harness-scaffold/pull/4
- Commits: `ee1fc02` (implementation), `cfeeedd` (dogfood fix pass).
- `bash -n scripts/install-harness.sh` → syntax OK.
- `bash scripts/harness-check.sh` on real repo state → `ok: harness-check
  passed — 5 story packet(s) validated, no violations.` (exit 0).
- `bash scripts/validate.sh quick` → `=== validate:quick passed ===` (exit 0).
- `cmp global-skills/harness-install/SKILL.md
  ~/.claude/skills/harness-install/SKILL.md` → identical (copied to the
  maintainer's actual global skill directory, outside this repo's git
  history, as the AC requires).
- Manual merge-mechanism simulation (scratchpad, kept this time for
  independent reverification): extracted this repo's own
  `HARNESS:BEGIN`/`HARNESS:END` block (100 of 100 lines — the whole file is
  the block today, since no project-specific content exists outside it
  yet); simulated first-install-into-existing-file via append
  (`APPEND_OK_IDENTICAL` — pre-existing 6 lines of fixture content
  byte-identical after); simulated a re-merge/update via span replace
  (`REMERGE_OK_IDENTICAL`, updated content present exactly once, exactly one
  `BEGIN`/`END` pair afterward — no duplication).
- Dogfood: a fresh, no-shared-context agent ran `harness-supervise` against
  the implementation commit (full report in the workpad Notes). Verified
  the "pure wrapping edit" claim on `CLAUDE.md` independently (numstat
  `+8/-0`, zero deleted lines, two additive hunks only) rather than trusting
  the story's own assertion. Found two real gaps, both fixed in `cfeeedd`:
  `scripts/install-harness.sh` touched but undeclared (D1, ratified), and
  the first merge-simulation's evidence being unrerunnable (re-ran it,
  kept artifacts this time). Correctly escalated rather than resolved two
  items — the new `CLAUDE.md` ownership comment and the Declared-Files gap
  — both confirmed ok by the maintainer in chat.
