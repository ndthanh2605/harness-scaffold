# Exec Plan

## Status

todo

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-XXX/workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, PR linked, no uncommitted changes
  human_review → merging      : human approves PR
  human_review → rework       : human posts actionable feedback
  rework       → in_progress  : agent resets workpad, re-implements
  merging      → done         : PR merged, test matrix updated, Evidence complete
  any          → blocked      : external blocker documented, human action needed
-->

## Workpad

Execution state lives in `docs/stories/US-XXX/workpad.md`. The agent creates
the sibling file from `docs/templates/high-risk-story/workpad.md` at the
`todo → in_progress` transition.

## Goal

What outcome are we trying to produce?

## Scope

In scope:

- Item.

Out of scope:

- Item.

## Risk Classification

Risk flags:

- Flag.

Hard gates:

- Gate.

## Work Phases

1. Discovery.
2. Design.
3. Validation planning.
4. Implementation.
5. Verification.
6. Harness update.

## Stop Conditions

Pause for human confirmation if:

- Product behavior is ambiguous.
- Data migration or deletion risk appears.
- Validation requirements need to be weakened.
- Architecture direction changes.

