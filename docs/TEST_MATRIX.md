# Test Matrix

This file maps product behavior to proof.

No product behavior has been defined or implemented yet. Do not mark a row
implemented until tests or validation evidence exist.

## Status Values

| Status | Meaning |
| --- | --- |
| planned | Accepted as intended behavior, not implemented |
| in_progress | Actively being built |
| implemented | Implemented and proof exists |
| changed | Contract changed after earlier implementation |
| retired | No longer part of the product contract |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | Add rows when story packets are created | no | no | no | no | planned | none |
| harness-execution-layer | Execution state machine, workpad sibling, git workflow skills present | no | no | no | yes | implemented | grep proofs in docs/superpowers/plans/2026-05-16-symphony-execution-layer.md Task 8 |
| harness-validation-layer | Language-agnostic validate.sh runner, harness-check.sh self-check, new-story.sh scaffolder; unconfigured rungs fail honestly | no | no | no | yes | implemented | scripts/harness-check.sh exit 0 on repo; validate.sh quick green, validate.sh e2e non-zero; harness-check red on broken fixture; ADR-0006 |
| US-002 (tiered-enforcement-foundations) | L0-L3 enforcement taxonomy named in HARNESS.md, Plan Deviation Protocol and Harness Change Policy categories re-tiered, Evidence field required in HARNESS_BACKLOG.md, closed editable-surfaces list in Growth Rule, install-manifest drift-check in both directions | no | no | no | yes | implemented | harness-check.sh red on seeded missing-from-manifest fixture and on seeded manifest-points-nowhere fixture, green on real repo state; validate.sh quick green; ADR-0007, ADR-0008 |
| US-003 (harness-supervise) | New skill mechanizing Decision 0008 L2: independently reruns Declared Files / Deviations / Validation / Evidence checks at the in_progress to human_review gate, reports rather than approves, escalates (never resolves) L3-category touches | no | no | no | yes | implemented | harness-check.sh red when the new skill's manifest entry is removed, green with it present; validate.sh quick green; ADR-0008 item 6; merged 0ccd8b0 |
| US-004 (intake-router-principles) | Four explicit-invoke-only principle-* skills (plan-deviation, invariant-markers, default-posture, enforcement-tiers) distill HARNESS.md house rules for citation; harness-intake's Intake Report names relevant principles per lane and cites harness-supervise at the review gate | no | no | no | yes | implemented | harness-check.sh red when a principle skill's manifest entry is removed, green with all four present and listed; validate.sh quick green; ADR-0007 item 2; merged a9f25fd |
| US-005 (managed-claude-md-and-install-skill) | CLAUDE.md wrapped in a managed HARNESS:BEGIN/END block; global harness-install skill wraps install-harness.sh and merges the block into a target's own CLAUDE.md without touching content outside it; optional pstack-routing.md reference map | no | no | no | yes | implemented | manual merge simulation: first-install append preserves pre-existing content byte-identical, re-merge replaces only the marker span, exactly one BEGIN/END pair; harness-check.sh and validate.sh quick green with global-skills/ and the new references file present; ADR-0007 items 1/3/4; merged 5076bd6 |
| US-006 (retire-pr-gate-and-minor-fixes) | State machine/harness-git-push/harness-git-land drop PR requirement per ADR-0009; harness-git-land deprecated not deleted; 5 deferred Minor findings fixed (garbled sentence, drift-check wording, broadened reverse-check, CRLF-stripping, pull-skill naming) | no | no | no | yes | implemented | harness-check.sh red on a seeded non-SKILL.md manifest entry pointing nowhere (new fixture, proves the broadened reverse-check), green on real repo state; validate.sh quick green; real install test against F:\Projects\LeanGoes-Dict (0 pre-existing files touched); ADR-0009 |
| US-007 (fix-false-state-claims-in-install-payload) | CLAUDE.md/docs/README.md/harness-intake Step 5 no longer assert the target repo has no implementation; README.md and docs/decisions/0001-0009 removed from the install manifest; HARNESS.md cites no literal decision paths; docs/templates/seed/TEST_MATRIX.md installs in place of harness-scaffold's own live, filled-in copy via a new source:target manifest syntax | no | no | no | yes | in_progress | scratch-target dry-run and real install show no README.md/numbered-decisions created, seed TEST_MATRIX.md installed clean; target's own harness-check.sh passes with 0 story packets; re-verified against the real F:\Projects\LeanGoes-Dict (0 pre-existing files touched, no false claims, harness-check.sh and validate.sh quick green there) |

## Evidence Rules

- Unit proof covers pure domain and application rules.
- Integration proof covers backend enforcement, data integrity, provider
  behavior, jobs, or service contracts.
- E2E proof covers user-visible browser flows.
- Platform proof covers only shell, deployment, mobile, desktop, or runtime
  behavior that cannot be proven in lower layers.
- A story can be implemented without every proof column if the story packet
  explains why.
