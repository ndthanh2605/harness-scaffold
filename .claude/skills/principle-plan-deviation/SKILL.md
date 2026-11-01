---
name: principle-plan-deviation
description: "Apply when an approved plan stops matching reality mid-implementation — a solvable-but-plan-breaking surprise, not an external blocker."
disable-model-invocation: true
---

# Plan Deviation Protocol

A deviation is any departure from the approved plan that crosses an
`[INVARIANT]` (see `principle-invariant-markers`): a changed interface,
signature, dependency, or data model; a file not in `## Declared Files`; a
changed acceptance-criterion proof method; a bent architecture constraint; or
a workaround / `TODO`/`FIXME`/`HACK` / suppressed warning used to make
something pass.

When one is forced:

1. **Stop at the deviation point.** Do not implement the crossing change yet.
2. **Record it** in the workpad `## Deviations`: what was planned, what you
   did or propose instead, why, which `[INVARIANT]` it crosses, and the
   proposed resolution.
3. **Do not ship an unratified crossing.** Implement the parts that don't
   cross an invariant; leave the crossing change for human ratification; set
   status to `blocked` only if you cannot make further progress without it.
4. A `[FLEX]` adjustment needs only a one-line Deviations note, then continue.

`blocked` is for *external* obstacles only (missing auth/tool/decision). A
deviation is *internal* — the plan no longer matches reality but you could
proceed, just not silently across an invariant.

Full text, enforcement levels, and rationale: `docs/HARNESS.md` →
`### Plan Deviation Protocol`.
