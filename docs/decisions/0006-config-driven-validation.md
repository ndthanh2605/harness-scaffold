# 0006 Config-Driven, Language-Agnostic Validation Layer

## Status

Accepted — 2026-06-26

## Context

The scaffold shipped no validation or support scripts — `HARNESS.md` said "No
validation scripts exist yet" and `scripts/README.md` only sketched a future
contract. So the Plan Deviation Protocol (ADR-0005) had no mechanical enforcement,
and nothing runnable proved harness integrity.

The binding constraint is that this is a **general harness scaffold** installed
into any kind of project (Node, Python, Rust, Go, …). A validation layer therefore
cannot hardcode tooling. chronicler's `validate-quick.sh` (hardcodes its
frontend/backend pnpm+cargo stack) and repository-harness's Rust `harness-cli`
were both rejected as too project-specific to live in the generic scaffold.
`scripts/README.md` also forbids shipping "fake validation commands."

## Decision

Ship the validation **mechanism**, never the **policy**:

- **`scripts/validate.sh <rung>`** — a thin runner for the documented ladder
  (`quick | integration | e2e | platform | release`). Each rung dispatches to a
  project-owned executable hook at `.harness/<rung>` (git-hooks style). The scaffold
  ships `.harness/*.example` templates with commented per-stack samples; a project
  copies one to the real name and fills in its commands, in any language. No
  scaffold edits per project.
- **`scripts/harness-check.sh`** — a language-agnostic harness self-check that
  validates the harness's own doc artifacts and needs **zero product code**. It is
  the always-on base of `quick`, so `validate:quick` is meaningful and green even in
  a harness-only repo. This is the key move: it turns "no validation exists" into
  "the harness validates itself; product rungs are project-configured."
- **`scripts/new-story.sh`** — a support script that scaffolds a story packet from
  the templates.

**Honest by construction.** A rung with no hook **fails** (runner exits non-zero);
it is never falsely green. A project opts a rung out deliberately by having its hook
print `skip`. Because an unconfigured rung is non-zero (not a phantom pass), this
does not violate the "no fake validation" rule — these are harness automation, not
application source.

### How this refines ADR-0005

ADR-0005 deferred deviation enforcement, arguing a bash gate was the wrong artifact
because the scaffold has no source to scan and the lineage enforces via a Rust
`harness-cli`. That reasoning over-indexed on repository-harness — a *general*
scaffold cannot assume every project will build a CLI. This decision splits the
enforcement cleanly:

- The **structural** part (no unratified deviation on a done story, Declared-Files
  fences parse) is harness doc-linting → folded into `harness-check.sh` now. No
  product code, no CLI needed.
- The **source-marker** part (workaround markers on added lines; new files vs.
  `## Declared Files`) needs a diff and a source referent → shipped as the opt-in
  `.harness/deviation-scan.example` hook, language-agnostic via configurable globs.

So ADR-0005's protocol is no longer legibility-only: its structural half is
mechanical, and a portable mechanical marker-gate is available per project. The
heavier `harness-cli` durable surface remains a future option, not a prerequisite.

## Alternatives Considered

1. **Hardcode a stack (copy chronicler's `validate-quick.sh`).** Rejected: breaks
   the general-scaffold constraint.
2. **Require a Rust `harness-cli` (repository-harness model).** Rejected: too heavy
   to assume for every installed project; the scaffold must work with bash alone.
3. **A sourced shell config (`harness.config.sh`) of command strings.** Rejected in
   favour of executable hooks: hooks can be written in any language, carry no
   sourcing/quoting fragility, and are trivially "exists ⟺ configured."
4. **Make unconfigured rungs pass (skip silently).** Rejected: that is exactly the
   "fake validation" / silent-green failure mode the harness forbids.

## Consequences

Positive:

- The scaffold has a real, green `validate:quick` with no product code, and a
  ladder that any project adapts by editing `.harness/` hooks.
- ADR-0005's protocol gains mechanical teeth (structural now; markers opt-in).
- Story creation is scripted and consistent with the templates.

Tradeoffs:

- More shipped scripts to maintain, and they must be added to the installer
  manifest (`.example` files only, so real hooks are never clobbered).
- `harness-check.sh` is bash and intentionally lenient on newer/optional sections
  to stay green on pre-existing stories; it is a doc-lint, not a full schema.
- Bash baseline only; projects needing Windows-native validation provide their own
  hook interpreter.

## Follow-Up

- `docs/HARNESS_BACKLOG.md` — richer `harness-cli` durable deviation surface
  (unchanged), and the existing installer-manifest-staleness item.

## References

- `scripts/validate.sh`, `scripts/harness-check.sh`, `scripts/new-story.sh`.
- `.harness/README.md` and `.harness/*.example`.
- `docs/HARNESS.md` — `## Validation Ladder`, Plan Deviation Protocol Enforcement.
- `docs/decisions/0005-plan-deviation-protocol.md` — the protocol this enforces.
