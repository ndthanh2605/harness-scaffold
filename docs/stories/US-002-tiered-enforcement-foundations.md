# US-002 Tiered Enforcement Foundations

## Status

done

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-002.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

normal

## Product Contract

`docs/HARNESS.md` names an explicit enforcement-level taxonomy (L0–L3) and
re-tiers the Plan Deviation Protocol and Harness Change Policy gates against
it. `docs/HARNESS_BACKLOG.md` requires a mandatory `Evidence` field on every
item and names a closed list of editable harness surfaces. `scripts/
harness-check.sh` mechanically catches drift between the skills this repo
actually ships and the manifest `scripts/install-harness.sh` installs from.

This is Plan 1 of 4 implementing `docs/decisions/0007` and
`docs/decisions/0008`. It introduces no new skills — purely docs and the
existing self-check script — and is the dependency the other three plans
(`harness-supervise`, the `harness-intake` router + `principle-*` skills,
and the managed-`CLAUDE.md` block + `harness-install`) build on.

## Relevant Product Docs

- `docs/HARNESS.md`
- `docs/HARNESS_BACKLOG.md`
- `docs/decisions/0005-plan-deviation-protocol.md`
- `docs/decisions/0006-config-driven-validation.md`
- `docs/decisions/0007-overlay-authority-and-explicit-invocation.md`
- `docs/decisions/0008-tiered-enforcement.md`
- `scripts/install-harness.sh`
- `scripts/harness-check.sh`

## Acceptance Criteria

- `docs/HARNESS.md` names the L0–L3 enforcement taxonomy from Decision 0008,
  trimmed to this scaffold's v0 scope (no CI-checked-in / CI-observed /
  branch-protection tiers — there is no application code or CI yet).
- `docs/HARNESS.md` explicitly re-tiers the Plan Deviation Protocol: mechanically
  checkable deviations (undeclared file, workaround marker without a
  `DEVIATION:` note) stay named at L0/L1; deviations that change a public
  interface/signature, swap a dependency, or bend an architecture constraint
  stay named at L3.
- `docs/HARNESS.md`'s Harness Change Policy section (or the new taxonomy
  section, cross-referenced) explicitly states all five existing categories —
  architecture direction, validation removal, source-of-truth hierarchy, risk
  classification rules, replacing the feature workflow — sit at L3, including
  that this list cannot demote itself without going through the same L3 gate.
- `docs/HARNESS.md`'s Growth Rule names a closed list of editable harness
  surfaces (skills, docs, templates, validation hooks, decision records —
  explicitly not application source) and states that a backlog proposal must
  describe its change as a diff against one of these surfaces.
- `docs/HARNESS_BACKLOG.md`'s `## Template` section gains a mandatory
  `Evidence` field (what observation proves the pain point/fix is real).
- `scripts/harness-check.sh` fails with a clear message when a file under
  `.claude/skills/**/SKILL.md` is absent from `scripts/install-harness.sh`'s
  manifest, **and** when a manifest entry under `.claude/skills/` points to a
  file that does not exist — both directions checked.
- `scripts/harness-check.sh` passes on this repo's current, in-sync state
  after the change (no existing skill/manifest drift exists today).

## Design Notes

- Commands: `scripts/harness-check.sh`, `scripts/validate.sh quick`.
- Queries: none.
- API: none.
- Tables: none.
- Domain rules: the L0–L3 taxonomy per Decision 0008 — L0 structural/mechanical
  (`harness-check.sh`), L1 opt-in source-marker (`.harness/deviation-scan`), L2
  evidence+independent-rerun (mechanized by `harness-supervise` in US-003, only
  *named* here), L3 human confirmation (fixed to the five Harness Change
  Policy categories, cannot self-demote).
- UI surfaces: terminal output of `scripts/harness-check.sh` (new failure
  message for manifest drift, in both directions).

## Invariants & Flex

Mark load-bearing decisions so an implementer — especially a fast/weak model in
auto-accept — knows what must not change. See `docs/HARNESS.md` →
`### Plan Deviation Protocol`.

- `[INVARIANT]` Exactly four tiers, named L0–L3, with the definitions ratified
  in `docs/decisions/0008-tiered-enforcement.md`. Do not add CI-checked-in /
  CI-observed / branch-protection tiers in this story.
- `[INVARIANT]` All five Harness Change Policy categories (architecture
  direction, validation removal, source-of-truth hierarchy, risk
  classification rules, feature workflow) are stated at L3. None may be
  silently moved to a lower tier by this story.
- `[INVARIANT]` The backlog template's new field is named literally `Evidence`
  (matches Decision 0008 and the `harness2` precedent it cites).
- `[INVARIANT]` The drift-check asserts **both** directions: every
  `.claude/skills/**/SKILL.md` appears in the manifest, and every
  `.claude/skills/` manifest entry resolves to a file that exists.
- `[FLEX]` Exact prose/heading structure of the new `docs/HARNESS.md`
  taxonomy section. Exact bash implementation approach for the drift-check
  (e.g. `find` + `comm`, or a loop) is the implementer's choice.
- `[FLEX]` Exact wording of the closed editable-surfaces list, as long as it
  names skills, docs, templates, validation hooks, and decision records, and
  excludes application source.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
docs/HARNESS.md
docs/HARNESS_BACKLOG.md
scripts/harness-check.sh
docs/TEST_MATRIX.md
docs/stories/US-002-tiered-enforcement-foundations.md
docs/stories/US-002-tiered-enforcement-foundations.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/harness-check.sh` |
| Integration | Seed a temporary fixture with a skill file missing from the manifest (and separately, a manifest entry pointing to a missing file); confirm `scripts/harness-check.sh` fails with a clear message for each; remove the seed and confirm it passes again. |
| E2E | `scripts/validate.sh quick` passes on this repo's real current state after the change. |
| Platform | POSIX shell execution, consistent with US-001. |
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

Implements `docs/decisions/0008-tiered-enforcement.md` items 1–5. US-003
(`harness-supervise`) mechanizes L2. US-004 (`harness-intake` router +
`principle-*` skills) and US-005 (managed `CLAUDE.md` block + `harness-install`)
depend on this story's taxonomy language existing first.

## Workpad

Execution state lives in `docs/stories/US-002-tiered-enforcement-foundations.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

- Commits: `ba60f77` (accepts ADR 0007/0008), `1e6edc5` (implements this story).
  Pushed directly to `origin/main` (no PR) per workpad Deviation D1, ratified by
  the maintainer 2026-11-01.
- `bash -n scripts/harness-check.sh` → syntax OK.
- `bash scripts/harness-check.sh` on real repo state → `ok: harness-check passed
  — 2 story packet(s) validated, no violations.` (exit 0).
- Seeded a skill file absent from the manifest
  (`.claude/skills/__drift-test__/SKILL.md`) → `FAIL: ... manifest is missing
  '.claude/skills/__drift-test__/SKILL.md'` (exit 1); removed, reran clean.
- Seeded a manifest entry pointing to a nonexistent file (temp edit to
  `scripts/install-harness.sh`, restored byte-identical via `diff -q` after) →
  `FAIL: ... manifest entry '.claude/skills/does-not-exist/SKILL.md' does not
  exist in this repo` (exit 1); restored, reran clean.
- `bash scripts/validate.sh quick` → `=== validate:quick passed ===` (exit 0).
- Independent fresh-reviewer pass (no shared context) against the commit range,
  this story's AC/Invariants, and Decision 0008 items 1–5: 0 Critical, 3
  Important (story/workpad state-sync gaps and a stale `HARNESS_BACKLOG.md`
  status line — all fixed in this same pass), 5 Minor (deferred, not fixed per
  `superpowers:executing-plans` discipline):
  - `docs/HARNESS.md`'s Enforcement paragraph has an awkward phrase ("including
    plus human review") — cosmetic, meaning still clear.
  - The drift-check's `find -mindepth 2 -maxdepth 2` only reaches one directory
    level (`.claude/skills/<name>/SKILL.md`), not arbitrarily nested
    `**/SKILL.md` as the AC's shorthand implies — matches how Claude Code
    actually discovers skills today, so no real gap yet.
  - The reverse-direction check only flags manifest entries ending in
    `SKILL.md`; a missing non-`SKILL.md` file under `.claude/skills/` in the
    manifest would pass silently (none exist today).
  - `docs/HARNESS.md`'s L2 description reads as binding today even though
    `harness-supervise` (which mechanizes it) doesn't exist until a later
    story; this story's own evidence above is manual, not supervisor-verified.
  - The manifest-extraction awk pattern relies on line-ending handling that
    holds on this MSYS/Windows checkout and on LF-checked-out Linux, but was
    not tested against a literal CRLF checkout on a non-MSYS shell.
