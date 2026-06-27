# 0005 Plan Deviation Protocol and Invariant Markers

## Status

Accepted — 2026-06-25

## Context

Plans are reviewed carefully, then implementation often runs in auto-accept on a
fast or weak model. When such a run hits an unexpected warning, error, or
bottleneck, it tends to silently change the planned design, add code outside the
plan, or apply a workaround just to "complete the task." The output diverges from
the approved plan even though the plan was sound.

The execution model in `docs/HARNESS.md` offered only a binary: `blocked`
(reserved for *external* blockers) or keep going. Default Posture #6 explicitly
says `blocked` "is not a shortcut for difficult problems" and to operate
autonomously until truly blocked. So a model hitting a solvable-but-plan-breaking
surprise had **no sanctioned middle path** and was nudged to improvise.

The right axis is **invariant vs. flexible**, not autonomous vs. blocked. Forcing
agents to block more often would trade silent drift for constant stalling and
fight the deliberate anti-stall intent of #6.

This pattern was first proven downstream in the `chronicler` project
(its ADR-0006). This decision brings the protocol upstream into the scaffold so
every project bootstrapped via `scripts/install-harness.sh` inherits it.

## Decision

Add a **Plan Deviation Protocol** to the Execution Phase of `docs/HARNESS.md`,
plus supporting template sections:

- `[INVARIANT]` / `[FLEX]` markers in plans, stories, and execplans. Unmarked
  items default to `[INVARIANT]`.
- A deviation = any departure that crosses an `[INVARIANT]` (signature/data-model
  change, dependency swap, a file not in `## Declared Files`, an AC proof-method
  change, an architecture-constraint bend, or a workaround/`TODO`/suppressed
  warning). Procedure: stop, record in the workpad `## Deviations`, do not ship an
  unratified invariant crossing, escalate to `blocked` only if truly stuck.
  `[FLEX]` adjustments need only a one-line note.
- `## Invariants & Flex`, `## Declared Files`, and `## Stop Conditions` are added
  to the normal `story.md`; `## Invariants & Flex` and `## Declared Files` to the
  high-risk `execplan.md` (which already carried Stop Conditions). Both workpads
  gain a `## Deviations` section.

**Scope:** this scaffold only; all lanes (tiny / normal / high-risk);
**enforcement is legibility-only.**

**Divergence from chronicler's ADR-0006.** chronicler shipped a *mechanical* gate
— a `scripts/validate-plan.sh` bash scan chained into `validate:quick`. That is
the wrong artifact here for two reasons:

1. **No referent.** This scaffold has no product code and no validation scripts
   (`HARNESS.md` → `## Future Validation Ladder` states "No validation scripts
   exist yet"). A bash scan of `frontend/`/`backend/` would be a permanent no-op
   and would assert a gate that does not run.
2. **Wrong enforcement surface for the lineage.** The mature sibling harness
   (`repository-harness`, sharing decisions 0001–0003) enforces mechanically
   through its Rust `harness-cli` + durable layer (`story verify`, `audit`/drift,
   `intervention add`) — not grep scripts. A deviation belongs as a durable
   intervention/audit record plus a `story verify` gate, not a shell scan.

So the mechanical half is **deferred** and recorded in `docs/HARNESS_BACKLOG.md`
as the upgrade path once the scaffold gains that CLI. Until then the protocol
rests on honest recording plus human review at the `in_progress → human_review`
gate.

## Alternatives Considered

1. **Port chronicler's `validate-plan.sh` verbatim.** Rejected: no source tree to
   scan here, and it would violate the v0 "no scripts until implementation" rule
   while claiming an enforcement that never fires.
2. **Generalized, product-agnostic bash gate now.** Rejected: still the wrong
   enforcement surface for this lineage (CLI/durable records, not grep) and
   speculative infrastructure with nothing to exercise it (YAGNI).
3. **Prose only, no deferred plan.** Rejected: leaves no concrete upgrade path;
   the backlog item keeps the mechanical half specced and forward-compatible.
4. **Lower the `blocked` bar instead.** Rejected: trades drift for stalling and
   fights Default Posture #6.

## Consequences

Positive:

- Plan changes surface as explicit, ratifiable deviations instead of silent
  drift; the three reported symptoms (change design / add code / workaround) get
  recorded and reviewed.
- Every project bootstrapped from the scaffold inherits the protocol and the
  template sections.
- The enforcement story is honest: legibility-only today, with a concrete,
  lineage-correct mechanical upgrade specced in the backlog.

Tradeoffs:

- Enforcement is goodwill + human review only until a `harness-cli` exists; a
  weak model could in principle skip recording a deviation. The state machine's
  `in_progress → human_review` gate is the human backstop.
- Plans must now carry a `## Declared Files` list and workpads a `## Deviations`
  section — more template surface to keep current.
- Tiny-lane work has no story/workpad, so it carries no deviation-recording
  surface; there it relies on the prose posture (Default Posture #6) alone. The
  protocol's template sections bind the normal and high-risk lanes.

## Follow-Up

- `docs/HARNESS_BACKLOG.md` — mechanical deviation enforcement via `harness-cli`.

## References

- **Refined by `docs/decisions/0006-config-driven-validation.md`** — the protocol
  is no longer legibility-only: its structural checks run in `harness-check.sh` and
  a portable marker-gate ships as `.harness/deviation-scan.example`.
- `docs/HARNESS.md` — `## Execution Phase` → `### Plan Deviation Protocol`,
  Default Posture #6, state-machine gate.
- `docs/decisions/0004-execution-state-machine.md` — the state machine this
  protocol hangs off.
- `docs/templates/story.md`, `docs/templates/story.workpad.md`,
  `docs/templates/high-risk-story/execplan.md`,
  `docs/templates/high-risk-story/workpad.md`.
- `.claude/skills/harness-git-commit/SKILL.md` — pre-commit deviation self-check.
- `docs/HARNESS_BACKLOG.md` — deferred mechanical enforcement.
