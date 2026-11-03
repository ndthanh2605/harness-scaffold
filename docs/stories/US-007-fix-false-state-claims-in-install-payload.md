# US-007 Fix False "No Implementation Yet" Claims in the Install Payload

## Status

in_progress

<!-- State machine (Decision 0009 — no PR):
  todo → in_progress → human_review → merging → done, or any → blocked
-->

## Lane

normal

## Product Contract

Installing harness-scaffold into a real, existing project (discovered via
the `F:\Projects\LeanGoes-Dict` test) must not assert or imply that the
target repository has no application implementation yet, nor ship
harness-scaffold's own development history (filled-in `TEST_MATRIX.md` rows,
`docs/decisions/0001-0009`) as if it were the target's. The installed
payload's rules (don't speculatively scaffold new structure) stay intact;
only the false state claims and the scaffold-specific history are removed.

## Relevant Product Docs

- `CLAUDE.md`, `docs/HARNESS.md`, `README.md`, `docs/README.md`
- `.claude/skills/harness-intake/SKILL.md`
- `scripts/install-harness.sh`, `scripts/harness-check.sh`
- `docs/TEST_MATRIX.md`, `docs/decisions/*`

## Acceptance Criteria

- `CLAUDE.md`'s managed block no longer asserts "There is no product
  implementation yet" or instructs agents not to scaffold application code
  "unless a later story explicitly moves the project into implementation."
  It instead states the real, state-independent rule: do not add new
  application scaffolding, tooling, or infrastructure speculatively — only
  when a story explicitly calls for it — regardless of how much
  implementation already exists.
- `docs/README.md`'s "Current State" section is similarly state-neutral.
- `.claude/skills/harness-intake/SKILL.md`'s Step 5 is reframed the same way
  (a rule about not adding unrequested structure, not a claim the repo is
  empty).
- `README.md` is removed from `scripts/install-harness.sh`'s manifest
  entirely — a generic installer must never create or imply ownership of a
  target project's own README. `harness-scaffold`'s own `README.md` is
  unchanged (it genuinely describes itself).
- `docs/decisions/0001-0009` are removed from the manifest entirely.
  `docs/decisions/README.md` (generic index, no scaffold-specific content)
  stays.
- `docs/HARNESS.md` no longer cites any specific `docs/decisions/NNNN-*.md`
  path inline (so `harness-check.sh`'s "decision records referenced in
  HARNESS.md must exist" check requires nothing from a target that has no
  decisions at all) — the rule content itself is unchanged, only the literal
  path citations are generalized to "this project's own `docs/decisions/`,
  where tracked locally."
- A new `docs/templates/seed/TEST_MATRIX.md` holds the clean, empty-matrix
  version (header, Status Values, one `TBD` placeholder row, Evidence
  Rules — no harness-scaffold-specific rows). `scripts/install-harness.sh`
  installs this file AS the target's `docs/TEST_MATRIX.md`, instead of
  copying harness-scaffold's own live, filled-in copy.
- `scripts/install-harness.sh` supports a manifest line of the form
  `source/path:target/path` (falling back to same-path when no `:` is
  present) so the seed-file remapping above works; this is the only line
  that uses the new syntax.
- Harness-scaffold's own `docs/TEST_MATRIX.md` (the live copy, tracking
  this repo's own stories) is unchanged — only the *installed* copy differs.
- A fresh `--merge` install into a target with pre-existing application code
  (re-tested against `F:\Projects\LeanGoes-Dict`) produces a `CLAUDE.md`,
  `docs/README.md`, and `docs/TEST_MATRIX.md` that make no false claims
  about the target's implementation state, and the target's own
  `harness-check.sh` still passes.

## Design Notes

- Commands: none new.
- Domain rules: the manifest's `source:target` syntax is `[FLEX]` in exact
  separator choice as long as it's unambiguous on POSIX paths (no `:` in
  any real path here); `:` is chosen since paths never contain it.
- UI surfaces: installer log output continues to print the target-relative
  path (what the user sees created), not the source path, for the
  remapped entry.

## Invariants & Flex

- `[INVARIANT]` The functional rule ("don't speculatively add scaffolding —
  only when a story calls for it") is preserved in meaning everywhere it is
  reframed; only the false "repository is empty" framing is removed.
- `[INVARIANT]` `README.md` and `docs/decisions/0001-0009` are removed from
  the manifest, not merely reworded — they must not reach any target.
- `[INVARIANT]` `docs/decisions/README.md` stays in the manifest (generic,
  no scaffold-specific content).
- `[INVARIANT]` Harness-scaffold's own live `docs/TEST_MATRIX.md` is not
  emptied or altered — only a separate seed file is added for installs.
- `[FLEX]` Exact manifest syntax for source/target remapping, exact wording
  of the reframed rules.

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

```files
CLAUDE.md
docs/README.md
docs/HARNESS.md
.claude/skills/harness-intake/SKILL.md
scripts/install-harness.sh
docs/templates/seed/TEST_MATRIX.md
docs/TEST_MATRIX.md
docs/stories/US-007-fix-false-state-claims-in-install-payload.md
docs/stories/US-007-fix-false-state-claims-in-install-payload.workpad.md
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | `bash -n scripts/install-harness.sh`; `bash scripts/harness-check.sh` on harness-scaffold's own repo state. |
| Integration | Dry-run and real `--merge` install into a scratch target proves: no `README.md` created, no `docs/decisions/*.md` beyond `README.md` created, `docs/TEST_MATRIX.md` in the target is the clean seed (not harness-scaffold's own rows), and the target's own `harness-check.sh` passes with zero decision-file requirements. |
| E2E | Re-run against the real `F:\Projects\LeanGoes-Dict` (`--merge`, picking up only the newly-changed/added files): confirm no false "no implementation" claims in the installed `CLAUDE.md`/`docs/README.md`, confirm `docs/TEST_MATRIX.md` there is the clean seed, confirm `harness-check.sh` still passes there. |
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

Fixes a real defect discovered through actual external-repo testing (not
hypothetical): the installed payload asserted false facts about the target
repository's implementation state, and shipped harness-scaffold's own
unrelated development history. Introduces the seed-file concept
(`docs/templates/seed/`) and a manifest source:target remap syntax as new,
reusable mechanisms for any future file needing the same live/seed split.

## Workpad

Execution state lives in `docs/stories/US-007-fix-false-state-claims-in-install-payload.workpad.md`.
The agent creates the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

Add commands, reports, screenshots, or links after validation exists.
