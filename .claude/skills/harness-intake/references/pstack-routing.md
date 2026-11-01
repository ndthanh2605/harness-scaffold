# pstack Routing Map (Optional)

This file maps specific harness-workflow moments to specific skills from the
`pstack` Claude Code plugin, for agents who happen to have it installed. See
`docs/decisions/0007-overlay-authority-and-explicit-invocation.md` for why
this exists and why it is scoped narrow (five touchpoints, not every pstack
skill).

**This is a soft, optional cross-reference, never a dependency.** Every row
below names a fallback for when `pstack` is not installed, and every
touchpoint still works correctly without it. Nothing in this harness ever
fails, blocks, or degrades because `pstack` is absent.

**Explicitly rejected:** `pstack`'s own `principle-never-block-on-the-human`
autonomy posture is **not** adopted anywhere in this harness. The Harness
Change Policy's L3 hard gates and the Plan Deviation Protocol's ratification
requirement remain authoritative everywhere; nothing here loosens them. See
`docs/decisions/0007`'s rejection of `poteto-mode`'s autonomy default.

| Harness-workflow moment | Optional pstack skill | When to use it | Fallback if `pstack` is absent |
| --- | --- | --- | --- |
| Designing a high-risk `execplan.md` | `pstack:architect` | Before writing the design, when the shape of the implementation is genuinely open | Write the execplan directly from `docs/templates/high-risk-story/execplan.md` |
| Mining a finished story's transcript for Growth Rule lessons | `pstack:reflect` | At story close, looking for a `HARNESS_BACKLOG.md`-worthy pattern | Write the backlog entry by hand, with its mandatory `Evidence` field (Decision 0008) |
| Critiquing work before the `in_progress → human_review` gate | `pstack:interrogate` | As an extra adversarial pass alongside, never instead of, `harness-supervise` | `harness-supervise` alone (it is the harness's own, non-optional L2 mechanism — see `principle-enforcement-tiers`) |
| Parallel research or multi-option exploration | `pstack:swarm` / `pstack:arena` | Comparing several independent approaches before committing to one | Dispatch ordinary fresh subagents/forks, one per option |
| Generating a project's `.harness/<rung>` validation hooks | `pstack:create-verification-skill` | Onboarding a new consumer project's stack-specific validation | Copy `.harness/*.example` to the real name by hand and fill in commands |
