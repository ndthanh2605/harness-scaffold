# Exec Plan

## Status

todo

<!-- State machine — transition only when the gate is fully met:
  todo         → in_progress  : agent creates US-XXX/workpad.md from template, runs pull skill, begins implementation
  in_progress  → human_review : workpad checked, validation green, deviations recorded + ratified, PR linked, no uncommitted changes
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

## Invariants & Flex

Mark load-bearing decisions so an implementer knows what must not change without
a ratified deviation. See `docs/HARNESS.md` → `### Plan Deviation Protocol`.

- `[INVARIANT]` <interface/signature, data model, dependency, architecture
  constraint, or AC proof method>
- `[FLEX]` <internal structure / naming / decomposition>

Anything not marked is treated as `[INVARIANT]` by default.

## Declared Files

The complete list of files this story may create or modify. Adding a file not
listed here is a deviation when it crosses an `[INVARIANT]`. One path per line
inside the fence.

```files
docs/<...>
.claude/skills/<...>
```

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

Additionally, stop and follow the Plan Deviation Protocol (`docs/HARNESS.md`) —
record in the workpad `## Deviations`, do not silently work around — when a
planned interface/dependency/data model must change, the work needs a file not in
`## Declared Files`, an AC's proof method must change, or the only way to pass is
a workaround / suppressed warning.

