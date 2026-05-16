# 0004 Execution State Machine and Sibling Workpad

## Status

Accepted — 2026-05-16

## Context

The harness defined preparation (intake, story templates, validation
expectations) but nothing about how agents behave during execution.
Symphony's execution patterns supply a useful default: a defined state
machine for stories, plus a workpad that carries live execution state.

Two integration questions had to be settled:

1. Where does execution state live — inside the story packet or in a
   sibling file?
2. Does the story-execution status share vocabulary with the existing
   TEST_MATRIX status?

## Decision

- Adopt a seven-state machine for story execution:
  `todo → in_progress → human_review → {merging | rework} → done`,
  with `any → blocked` as an escape hatch.
- Apply the same state machine to both lanes: Normal stories carry the
  `## Status` field in `story.md`; High-Risk stories carry it in
  `execplan.md`.
- Put the workpad in a **sibling file** (`US-XXX.workpad.md` for Normal,
  `US-XXX/workpad.md` for High-Risk), not inside the story packet. The
  packet stays a stable contract; the workpad mutates freely during
  execution.
- Keep story-execution status distinct from TEST_MATRIX behavior-proof
  status. Both coexist: `todo … done` describes a story's execution
  progress; `planned … implemented … retired` describes whether a product
  behavior has proof. A story may be `done` and its matrix row
  `implemented`, but a behavior can also be `retired` long after the story
  that introduced it was `done`.

## Consequences

- Story packets stay stable across execution iterations — diffs reflect
  contract changes, not progress noise.
- Workpads can be archived, cleared, or kept indefinitely after merge
  without rewriting the contract.
- Two status vocabularies in the harness; the distinction is explicit in
  `HARNESS.md` and CLAUDE.md.
- The state machine adds gate checks the agent must satisfy before
  advancing status — minor overhead per transition, paid for by clearer
  handoffs.

## Alternatives Considered

- Workpad embedded inside `story.md` (rejected: contract/log conflation,
  noisy diffs).
- Unified status vocabulary across story execution and test matrix
  (rejected: they describe different things and would conflict — a
  behavior `retired` is unrelated to whether its origin story `done`d).
- Apply state machine only to Normal lane (rejected: creates two
  execution models, hurts agent consistency).

## References

- `docs/HARNESS.md` — `## Execution Phase`
- `.claude/skills/{commit,push,pull,land}.md` — workflow skills referenced
  by the state machine gates
- `docs/templates/story.workpad.md`,
  `docs/templates/high-risk-story/workpad.md` — sibling workpad shape
