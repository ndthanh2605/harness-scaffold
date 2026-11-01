---
name: principle-enforcement-tiers
description: "Apply when deciding whether a check can be mechanized or genuinely needs a human to confirm it."
disable-model-invocation: true
---

# Enforcement Tiers

Never let a weaker level imply a stronger one. Four levels, cheaper first:

- **L0 — structural/mechanical.** `scripts/harness-check.sh`, always on, no
  product code required.
- **L1 — source markers, opt-in.** `.harness/deviation-scan`, once a project
  enables it.
- **L2 — evidence + independent rerun.** A fresh, no-shared-context agent
  re-verifies a claim (recorded `Evidence` field) before it's trusted.
  Mechanized by `harness-supervise`, invoked at `in_progress →
  human_review`. May confirm or flag L0–L2 items only.
- **L3 — human confirmation.** Reserved for: a deviation that changes a
  public interface/signature, swaps a dependency, or bends an architecture
  constraint; and all five `CLAUDE.md` Harness Change Policy categories —
  architecture direction, validation removal, source-of-truth hierarchy,
  risk classification rules, replacing the feature workflow. This list
  cannot demote itself, or any L3 category, to a lower level without going
  through this same gate.

The goal is cheaper gates wherever one catches the same failure, not fewer
gates — every level still catches what it always caught.

Full text and rationale: `docs/HARNESS.md` → `**Enforcement.**`,
`docs/decisions/0008-tiered-enforcement.md`.
