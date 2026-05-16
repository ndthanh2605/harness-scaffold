# US-XXX Story Title

## Status

todo

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-XXX.workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, PR linked, no uncommitted changes
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

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | |
| Integration | |
| E2E | |
| Platform | |
| Release | |

## Harness Delta

Document any harness updates made or proposed because of this story.

## Workpad

Execution state lives in `docs/stories/US-XXX.workpad.md`. The agent creates
the sibling file from `docs/templates/story.workpad.md` at the
`todo → in_progress` transition and updates it throughout execution. Do not
embed execution state in this packet — keep the packet a stable contract.

## Evidence

Add commands, reports, screenshots, or links after validation exists.
