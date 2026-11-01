# 0008 Tiered Enforcement: Calibrating Gate Cost to Decision Risk

Date: 2026-11-01

## Status

Accepted — 2026-11-01

## Context

The Plan Deviation Protocol (Decision 0005, refined by 0006) currently treats
every `[INVARIANT]` crossing the same way: stop, record, require human
ratification before shipping. The Harness Change Policy (`CLAUDE.md`) likewise
gates a fixed list of change types (architecture direction, validation removal,
source-of-truth hierarchy, risk classification rules, feature workflow) behind a
flat "ask for human confirmation" requirement, regardless of how mechanically
verifiable any given instance actually is.

The goal of reducing human-in-the-loop load while *increasing* monitoring and
quality of agent work is not in tension with these gates. The real lever is
replacing an **expensive** mechanism (stop and ask a person) with a **cheaper**
mechanism that still catches the same class of error, reserving the expensive
mechanism only for the subset of decisions that are genuinely costly to get
wrong and not mechanically checkable.

Three research threads converged on this shape:

- `repository-harness`'s `$encode-invariant` skill (decision 0028) uses a
  4-level enforcement taxonomy (local / hook / CI-checked-in / CI-observed /
  branch-protection) that never lets a weaker level imply a stronger one.
- `harness2` requires a mandatory `evidence` field plus a closed, named list of
  editable "surfaces" before a proposed change is accepted into its persistent
  improvement harness — sharper than this scaffold's current free-text
  `HARNESS_BACKLOG.md` template.
- `docs/HARNESS.md` already has a two-layer enforcement precedent (structural,
  always-on via `harness-check.sh`; source-marker, opt-in via
  `.harness/deviation-scan.example`). This decision generalizes that existing
  pattern into an explicit, named taxonomy rather than introducing a new
  mechanism from scratch.

## Decision

**1. Adopt a named enforcement-level taxonomy** in `docs/HARNESS.md`, modeled on
repository-harness's but trimmed to this scaffold's v0 scope (no CI or
branch-protection yet — there is no application code):

- **L0 — structural/mechanical.** Caught automatically by
  `scripts/harness-check.sh`, no product code required (e.g. `## Declared
  Files` fence parse, unratified-deviation-on-`done` check, extended here to
  include install-manifest drift).
- **L1 — source-marker, opt-in.** `.harness/deviation-scan` catches workaround
  markers and undeclared files once a consumer enables it.
- **L2 — evidence + independent rerun, executed by a `harness-supervise`
  skill.** A claimed improvement, backlog closure, or story at the
  `in_progress → human_review` gate requires a recorded `Evidence` field (what
  observation proves the pain point/fix is real) plus a fresh, independent
  agent re-verifying the claim before status advances. No external consumer is
  required — a fresh fork with no shared context, reproducing the original
  friction or re-running validation inside this repo, satisfies it. This is
  not left as informal prose: it is implemented as a new skill,
  `harness-supervise` (lives in this repo's `.claude/skills/`, installed by
  Skill A like the other `harness-*` skills). Invoked at the
  `in_progress → human_review` transition, it independently checks: `##
  Declared Files` matches what was actually touched, every deviation is
  recorded and ratified (not merely claimed), validation actually ran green
  (re-run, not taken on the implementing agent's word), and the `Evidence`
  field genuinely substantiates the claim rather than asserting it. Its output
  is a verification report ("L0-L2 verified; items X, Y still need your
  decision"), not an approval — it hands the human a pre-triaged review
  instead of a from-scratch one. Structurally inspired by (not a port of)
  `pstack:interrogate` (adversarial review) and `pstack:reflect` (transcript
  mining); may be listed in `references/pstack-routing.md` (Decision 0007) as
  an optional cross-check, never a dependency.

  **Hard boundary:** `harness-supervise` may confirm or flag L0-L2 items only.
  It must never resolve or silently clear anything that touches an L3
  category (below) — if its check surfaces a change that crosses architecture
  direction, validation removal, the source-of-truth hierarchy, risk
  classification rules, or the feature workflow, it must escalate to the human
  with that item explicitly called out as unresolved, not mark it "verified."
  A cheap mechanism quietly substituting for the expensive one on exactly the
  decisions this taxonomy exists to protect would defeat the taxonomy itself.
- **L3 — human confirmation.** Reserved for the Harness Change Policy's five
  named categories, all of which remain genuinely judgment-laden and not
  mechanically verifiable: architecture direction, removing or weakening a
  validation requirement, changing the source-of-truth hierarchy, changing
  risk classification rules, and replacing the feature workflow — including
  changing which categories sit at L3 itself (this list cannot demote itself
  without going through this same gate).

**2. Re-tier the existing gates against this taxonomy, explicitly, in
`docs/HARNESS.md`:**

- Deviations already mechanically checkable (new file not in `## Declared
  Files`, workaround marker without a `DEVIATION:` note) stay at L0/L1 — no
  change.
- Deviations that change a public interface/signature, swap a dependency, or
  bend an architecture constraint — genuinely hard to verify by
  pattern-matching — stay at L3, unchanged.
- All five Harness Change Policy categories — architecture direction,
  validation removal, source-of-truth hierarchy, risk classification rules,
  and replacing the feature workflow — stay at L3, unchanged (this is why
  Decision 0007's Skill A/B split went through this ADR process instead of
  being applied directly).
- `HARNESS_BACKLOG.md` item closure moves from "self-reported, any status" to
  L2 (Evidence field + independent rerun) before an item advances from
  `proposed`/`accepted` to `implemented`.

**3. Add a mandatory `Evidence` field** to the backlog-item shape in
`docs/HARNESS_BACKLOG.md`'s `## Template` section: what observation proves this
pain point/fix is real, not a hunch. Enforced by review convention now;
candidate for a mechanical check once a backlog-item schema exists.

**4. Add a closed, named list of "editable harness surfaces"** to the Growth
Rule in `docs/HARNESS.md` — skills, docs, templates, validation hooks, decision
records (explicitly **not** application source, per the v0 scope rule already
in place). A backlog proposal must state its change as a diff against one of
these named surfaces, not free prose.

**5. Add an install-manifest drift-check** to `scripts/harness-check.sh`:
assert every file under `.claude/skills/**/SKILL.md` appears in Skill A's
tracked manifest (Decision 0007) and vice versa. This closes the open
`HARNESS_BACKLOG.md` item "Installer Manifest Is Stale Relative to Skills" and
is itself an L0 addition.

**6. Add the `harness-supervise` skill** (see L2 above) to this repo's
`.claude/skills/`, wired into the `in_progress → human_review` state-machine
gate in `docs/HARNESS.md` as the executable form of L2. It is additive: the
state machine's existing human_review gate is unchanged, it now simply
receives a pre-triaged report instead of a cold read.

## Alternatives Considered

1. **Leave the Plan Deviation Protocol and Harness Change Policy as-is; pursue
   less human-in-the-loop by loosening Default Posture #6 instead.** Rejected:
   this was the original tension flagged when considering pstack's
   `poteto-mode` — loosening the stop-and-ask instinct without a cheaper
   substitute reintroduces the silent-drift failure mode Decision 0005 was
   written to prevent.
2. **Add CI-checked-in / CI-observed / branch-protection levels now, matching
   repository-harness exactly.** Rejected: no application code or CI exists at
   v0 (`docs/HARNESS.md`'s explicit exclusions); those levels would be
   speculative and unused, violating the same no-premature-infrastructure
   principle Decision 0005 already applied.
3. **Require the L2 independent-rerun gate only once a real external consumer
   project exists.** Rejected: the mechanism only needs a fresh agent without
   the original context to re-verify a claim, which this repo can do today;
   waiting for a consumer adds delay for no real benefit.
4. **Leave L2's "fresh, independent agent" as informal prose guidance instead
   of a named skill.** Rejected: informal guidance is exactly what the
   taxonomy is designed to move away from — without a documented, invocable
   procedure, L2 would quietly degrade back into "trust the implementing
   agent's word," which is the L3-cost failure mode this decision exists to
   avoid paying for L0-L2-sized problems.
5. **Let `harness-supervise` also clear L3 items when its checks happen to
   pass.** Rejected outright: this would let a cheap mechanism silently
   substitute for the expensive one on exactly the decisions the taxonomy
   protects, inverting "never let a weaker level imply a stronger one" into
   its opposite. The hard boundary (escalate, never resolve, on any L3 touch)
   is load-bearing, not a style choice.

## Consequences

Positive:

- Reduces required human stops to the genuinely judgment-laden subset, while
  every currently-caught failure mode stays caught — no gate is removed, only
  re-sourced to a cheaper mechanism where one exists.
- Gives Decision 0007's Skill A/B split a documented justification for why
  "architecture direction" and "feature workflow" changes stayed at L3 even
  while overlay/invocation mechanics were redesigned.
- Closes a long-open `HARNESS_BACKLOG.md` item (installer manifest drift) as a
  direct side effect.

Tradeoffs:

- Introduces taxonomy vocabulary (L0-L3) that future decisions must stay
  consistent with, or the tiering becomes meaningless.
- The L2 rerun-proof gate adds a step to closing backlog items that previously
  needed only a status edit — modest added friction at the backlog layer in
  exchange for honesty about whether a claimed fix actually worked.
- The taxonomy has no mechanical check that a *new* gate was assigned the
  correct tier — that judgment still rests on human review at the point a new
  decision is proposed.

## Follow-Up

- Implement the `Evidence` field in `docs/HARNESS_BACKLOG.md`'s template and
  retrofit existing open items where feasible.
- Implement the install-manifest drift-check in `scripts/harness-check.sh`.
- Write `.claude/skills/harness-supervise/SKILL.md` and wire it into the
  `in_progress → human_review` gate in `docs/HARNESS.md`.
- Revisit CI-level tiers once this scaffold gains application code/CI per a
  future story.

## References

- `docs/decisions/0005-plan-deviation-protocol.md`,
  `docs/decisions/0006-config-driven-validation.md` — the two-layer precedent
  this generalizes.
- `docs/HARNESS_BACKLOG.md` — "Installer Manifest Is Stale Relative to Skills"
  (closed here), "Mechanical Plan-Deviation Enforcement via harness-cli"
  (related, still deferred pending a real CLI).
- `repository-harness` decision 0028 (`encode-invariant` 4-level taxonomy).
- `harness2` README "Harness components" section (evidence field, closed
  editable-surface list, diff-shaped proposals).
- `docs/decisions/0007-overlay-authority-and-explicit-invocation.md` (the
  decision this taxonomy justifies keeping at L3; also where
  `harness-supervise` may be listed in `references/pstack-routing.md` as an
  optional cross-check).
- `pstack` plugin `skills/interrogate/SKILL.md`, `skills/reflect/SKILL.md`
  (structural inspiration for `harness-supervise`'s adversarial-review and
  transcript-mining shape — not ported verbatim).
