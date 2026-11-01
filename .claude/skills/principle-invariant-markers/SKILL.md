---
name: principle-invariant-markers
description: "Apply when writing or reading a plan, story, or execplan — decide what's load-bearing versus free to change."
disable-model-invocation: true
---

# Invariant Markers

- `[INVARIANT]` — load-bearing. Interfaces and signatures, the data model,
  the declared file list, dependency choices, architecture constraints, and
  an acceptance criterion's proof method. Must not change without a ratified
  deviation (see `principle-plan-deviation`) or a decision record for
  cross-cutting choices.
- `[FLEX]` — implementer's discretion. Internal structure, naming, helper
  decomposition. Adjust freely; a one-line Deviations note is enough.

Anything a plan does not mark is treated as `[INVARIANT]` by default — when
in doubt, it is load-bearing.

Full text and rationale: `docs/HARNESS.md` → `### Plan Deviation Protocol`.
