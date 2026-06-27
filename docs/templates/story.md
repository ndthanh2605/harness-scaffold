# US-XXX Story Title

## Status

todo

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-XXX.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Lane

tiny | normal | high-risk

## Product Contract

Describe the behavior this story must make true.

## Relevant Product Docs

- `docs/product/...`

## Acceptance Criteria

- Criterion 1.
- Criterion 2.
- Criterion 3.

## Design Notes

- Commands:
- Queries:
- API:
- Tables:
- Domain rules:
- UI surfaces:

## Invariants & Flex

Mark load-bearing decisions so an implementer — especially a fast/weak model in
auto-accept — knows what must not change. See `docs/HARNESS.md` →
`### Plan Deviation Protocol`.

- `[INVARIANT]` <interface/signature, data model, dependency, architecture
  constraint, or AC proof method that must not change without a ratified
  deviation>
- `[FLEX]` <internal structure / naming / decomposition the implementer may
  decide freely>

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

The complete list of files this story may create or modify. Adding a file not
listed here is a deviation when it crosses an `[INVARIANT]` — log it in the
workpad `## Deviations`. In a harness-only repo this lists the docs, skills, and
templates the story touches; once a project adds implementation it also lists the
product source paths. One path per line inside the fence.

```files
docs/<...>
.claude/skills/<...>
```

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | |
| Integration | |
| E2E | |
| Platform | |
| Release | |

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

Document any harness updates made or proposed because of this story.

## Workpad

Execution state lives in `docs/stories/US-XXX.workpad.md`. The agent creates
the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

Add commands, reports, screenshots, or links after validation exists.
