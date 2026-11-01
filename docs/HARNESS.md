# Harness

The project goal is to provide a reusable operating harness that lets humans and
agents turn a future product spec into safe, validated work.

The app is what users touch. The harness is what agents touch.

## Mental Model

```text
------------------+
| Human intent    |
+------------------+
         |
         v
+------------------+
| Feature intake   |
+------------------+
         |
         v
+------------------+
| Story packet     |
+------------------+
         |
         v
+------------------+
| Agent work loop  |
+------------------+
         |
         v
+------------------+
| Product delta    |
+------------------+
         |
         v
+------------------+
| Validation proof |
+------------------+
         |
         v
+------------------+
| Harness delta    |
+------------------+
         |
         v
+------------------+
| Next intent      |
+------------------+
```

Every task has two possible outputs:

1. Product delta: app code, tests, API shape, data model, or product docs.
2. Harness delta: docs, templates, validation expectations, backlog items, or
   decision records that make the next task easier.

## Harness v0 Scope

Harness v0 includes:

- Agent entrypoint.
- Empty product documentation structure.
- Feature intake and risk lanes.
- Story templates.
- Decision log template.
- Validation report template.
- Test matrix placeholder.
- Harness growth backlog.
- Git workflow skill contracts (`.claude/skills/`).

Harness v0 deliberately excludes:

- A project-specific `SPEC.md`.
- Pre-sliced product domains.
- A locked application stack.
- App source scaffolding.
- Package scripts.
- Test runner config.
- CI workflows.
- Database migrations or infrastructure.

Those should arrive only when a selected story needs them.

## Source Hierarchy

```text
User-provided spec or prompt
  input material for first buildout or future changes

docs/product/*
  current product contract derived from accepted input

docs/stories/*
  story-sized work packets and historical evidence

docs/TEST_MATRIX.md
  behavior-to-proof control panel

docs/decisions/*
  why the contract changed

.claude/skills/*
  git workflow skill contracts (commit, push, pull, land) invoked during execution
```

Before implementation, product docs describe intent. After implementation,
product docs plus executable tests become the living contract.

## Spec Lifecycle

Harness v0 starts without a tracked project spec. When the human provides a
specification, treat it as input material, not as a permanent operating manual.
Use it to populate product docs, story packets, architecture decisions, and
validation expectations during the first buildout.

After the specification has been decomposed, do not keep extending it as the
living product plan. Ongoing work should update the smaller product docs,
stories, test matrix, and decision records.

Ongoing work should enter the harness as one of these input types:

- New spec: a project specification that needs to become product docs and
  initial story candidates.
- Spec slice: a selected behavior from the provided spec.
- Change request: a bounded behavior change, bug fix, or product refinement.
- New initiative: a larger product area that needs multiple stories.
- Maintenance request: dependency, architecture, performance, security, or
  operational work.
- Harness improvement: a process, template, proof, or agent-instruction change.

The spec-to-work loop is:

```text
human intent or supplied spec
  -> classify input type
  -> update or create product contract
  -> create story packet or initiative notes when needed
  -> define validation proof
  -> implement or document the blocker
  -> update product docs, stories, test matrix, and decisions
  -> capture harness friction
```

Large product areas should use scoped initiative notes instead of a second
monolithic specification. An initiative should explain the goal, affected
product docs, candidate stories, validation shape, open decisions, and exit
criteria. If initiative work becomes a repeated pattern, add a template or
proposal to `docs/HARNESS_BACKLOG.md`.

## Execution Phase

Stories move through a defined execution state machine. Agents follow the
default posture rules and honor quality gates at every transition. The state
machine applies to both the Normal lane (single `story.md` packet) and the
High-Risk lane (multi-file bundle — the `## Status` field lives in
`execplan.md`).

### State Machine

Transition the story `## Status` field only when the gate for that state is
fully met. Never advance status optimistically.

| From | To | Gate |
|---|---|---|
| `todo` | `in_progress` | Agent creates workpad sibling, runs `harness-git-pull`, begins implementation |
| `in_progress` | `human_review` | Workpad Plan + AC checked off, validation green, any plan deviations recorded and ratified (see Plan Deviation Protocol), no uncommitted changes. The `harness-supervise` skill (L2, see Enforcement below) runs here — additive: the gate itself is unchanged, the human now receives a pre-triaged report alongside the agent's summary. No PR is required (Decision 0009) — the agent presents the work (commits, diff, summary) in chat. |
| `human_review` | `merging` | Human approves in chat; the agent records the approval in the workpad Notes (Decision 0009) |
| `human_review` | `rework` | Human posts actionable feedback |
| `rework` | `in_progress` | Agent resets workpad, re-implements |
| `merging` | `done` | Changes pushed to `origin/main`, test matrix row updated, Evidence complete |
| `any` | `blocked` | External blocker documented, human action needed |

Story-execution status (`todo … done`) is distinct from behavior-proof
status in `TEST_MATRIX.md` (`planned … implemented … retired`). Both stay.
See `docs/decisions/0004-execution-state-machine.md` for the rationale.

### Default Posture

1. **Reproduce before changing** — confirm the current broken or missing
   behavior (for bugs) or confirm the feature is absent (for new work) before
   editing code. Record the reproduction signal in workpad Notes.
2. **Workpad-first** — update the workpad sibling's plan before writing
   implementation. Planning lives in the file, not in the agent's memory.
3. **Sync before editing** — invoke the `harness-git-pull` skill before any
   code changes. Record the sync result in workpad Notes.
4. **Status gates** — only transition story status when the gate for that
   state is fully met. Do not advance status optimistically.
5. **Scope discipline** — out-of-scope improvements discovered during
   execution go to `HARNESS_BACKLOG.md`, not into the current story.
6. **Operate autonomously until truly blocked** — `blocked` is an escape hatch
   for external blockers (missing auth, missing required tool, required human
   decision after exhausting all fallbacks). It is not a shortcut for
   difficult problems. But difficult is not the same as plan-breaking: when a
   surprise forces you off the approved plan across an `[INVARIANT]`, do not
   improvise a workaround — follow the Plan Deviation Protocol below.

### Plan Deviation Protocol

The default posture keeps an agent moving autonomously. This protocol is the
sanctioned middle path between "push through" and `blocked`: it fires when
reality diverges from the approved plan but work could still proceed. It exists
so that plan changes **surface and get ratified** instead of being silently
worked around — the failure mode that hurts most when implementation runs in
auto-accept on a fast or weak model.

**Invariant markers.** Plans, stories, and execplans tag load-bearing items so
the line between "must not change" and "free to decide" is explicit:

- `[INVARIANT]` — load-bearing. Interfaces and signatures, the data model, the
  declared file list, dependency choices, architecture constraints, and an
  acceptance criterion's proof method. Must not change without a ratified
  deviation (or a decision record for cross-cutting choices).
- `[FLEX]` — implementer's discretion. Internal structure, naming, helper
  decomposition. Adjust freely; a one-line Deviations note is enough.

Anything a plan does not mark is treated as `[INVARIANT]` by default — when in
doubt, it is load-bearing.

**What counts as a deviation.** Any departure from the approved plan that
crosses an `[INVARIANT]`:

- changing a declared interface, signature, or data model;
- swapping or adding a dependency;
- adding a file or module not in the plan's `## Declared Files` list;
- changing an acceptance criterion's proof method;
- bending an architecture constraint;
- introducing a workaround, `TODO`/`FIXME`/`HACK`, or a suppressed
  warning/type error to make something pass.

**Procedure.** When a deviation is forced:

1. **Stop at the deviation point.** Do not implement the crossing change yet.
2. **Record it** in the workpad `## Deviations` section: what was planned, what
   you did or propose instead, why, which `[INVARIANT]` it crosses, and the
   proposed resolution.
3. **Do not ship an unratified invariant crossing.** Implement the parts that
   do not cross an invariant, leave the crossing change for human ratification,
   and set status to `blocked` if you cannot make further progress without it.
4. A `[FLEX]` adjustment needs only the one-line Deviations note, then continue.

**Deviation vs. blocked.** `blocked` means an *external* obstacle stops all
progress (missing auth/tool/decision). A *deviation* is *internal*: the plan no
longer matches reality and you could proceed — but must not silently cross an
invariant. A deviation may escalate to `blocked` if the crossing change is the
only way forward.

**Enforcement.** Enforcement runs through four named levels — never let a
weaker level imply a stronger one. The goal is cheaper gates wherever one
catches the same failure, not fewer gates: every level below still catches
what it always caught, with human review remaining the backstop at the
`in_progress → human_review` gate.

- **L0 — structural/mechanical (always on).** `scripts/harness-check.sh` —
  the base of `validate:quick` — fails when a `done` story still carries an
  unratified (`open`) deviation in its workpad, checks that `## Declared
  Files` fences parse, and checks that the install manifest
  (`scripts/install-harness.sh`) and this repo's shipped
  `.claude/skills/<name>/SKILL.md` files agree in both directions, one
  directory level deep (matching how skills are actually discovered; not
  arbitrarily nested). This needs no product code, so it runs even in a
  harness-only repo.
- **L1 — source markers (opt-in, project-level).** `.harness/deviation-scan`
  (shipped as `.harness/deviation-scan.example`) is a language-agnostic gate
  that fails on workaround markers added without a `DEVIATION:` note and on
  new source files missing from the active story's `## Declared Files`. A
  project enables it by copying the example and wiring it into its
  `.harness/quick` hook.
- **L2 — evidence + independent rerun.** A claimed improvement, a
  `HARNESS_BACKLOG.md` item closing, or a story reaching
  `in_progress → human_review` requires a recorded `Evidence` field (what
  observation proves the claim is real) plus a fresh, independent agent
  re-verifying it — no external consumer required, a fresh fork with no
  shared context satisfies it. Mechanized by the `harness-supervise` skill
  (`.claude/skills/harness-supervise/SKILL.md`; see
  `docs/decisions/0008-tiered-enforcement.md`), invoked at the
  `in_progress → human_review` transition, which may confirm or flag L0–L2
  items only — it must escalate, never resolve, anything that touches an L3
  category below.
- **L3 — human confirmation.** Reserved for genuinely judgment-laden,
  not-mechanically-verifiable decisions: a deviation that changes a public
  interface/signature, swaps a dependency, or bends an architecture
  constraint (see "What counts as a deviation" above), and all five
  categories in `CLAUDE.md`'s Harness Change Policy — architecture
  direction, removing or weakening a validation requirement, changing the
  source-of-truth hierarchy, changing risk classification rules, and
  replacing the feature workflow. This list cannot demote itself, or any of
  the five Harness Change Policy categories, to a lower level without going
  through this same L3 gate.

Mechanically checkable deviations (an undeclared file, a workaround marker
without a `DEVIATION:` note) stay caught at L0/L1 as above — no change there.
Deviations that are hard to verify by pattern-matching stay at L3, unchanged.

Beyond these, recording deviations honestly remains the agent's responsibility; a
richer durable surface (a `harness-cli` deviation/intervention record + a
`story verify` gate) stays the future option in `docs/HARNESS_BACKLOG.md`. See
`docs/decisions/0005-plan-deviation-protocol.md`,
`docs/decisions/0006-config-driven-validation.md`, and
`docs/decisions/0008-tiered-enforcement.md`.

### Blocked-Access Escape Hatch

When blocked after exhausting all documented fallbacks:

1. Add to workpad Confusions: what is missing, why it is needed, and what
   human action unblocks it.
2. Set story status to `blocked`.
3. Stop. Do not loop or stall indefinitely.

## Growth Rule

The harness grows from friction.

When an agent is confused, repeats manual reasoning, needs a new validation
command, discovers a missing rule, or sees a recurring failure pattern, it must
either improve the harness directly or add a proposal to `HARNESS_BACKLOG.md`.

Editable harness surfaces are a closed, named list: skills (`.claude/skills/`),
docs, templates (`docs/templates/`), validation hooks (`.harness/`), and
decision records (`docs/decisions/`) — explicitly **not** application source,
per the v0 scope rule above. A `HARNESS_BACKLOG.md` proposal must state its
change as a diff against one of these named surfaces, not free prose, and must
carry an `Evidence` field proving the friction is real (see
`docs/decisions/0008-tiered-enforcement.md`).

## Validation Ladder

Validation runs through a single language-agnostic runner so the harness adapts to
any stack without per-project script edits:

```text
scripts/validate.sh <rung>     rung ∈ quick | integration | e2e | platform | release
```

Each rung dispatches to a project-owned hook at `.harness/<rung>` (see
`.harness/README.md`). The scaffold ships the runner plus `.harness/*.example`
templates; a project copies an example to the real name and fills in its commands.

```text
quick        scripts/harness-check.sh (always) + .harness/quick
             format, lint, typecheck, unit tests, harness self-check
integration  .harness/integration — backend / database / provider / service
e2e          .harness/e2e — user-visible end-to-end flows
platform     .harness/platform — shell / desktop / mobile / deployment smoke
release      .harness/release — full suite, log checks, performance smoke
```

`scripts/harness-check.sh` validates the harness's **own** artifacts (story
sections, workpad siblings, `## Declared Files` fences, no unratified deviations on
done stories, decision-record references, the test matrix) and needs no product
code — so `validate:quick` is meaningful and green even in a harness-only repo.

**Honest by construction.** A rung with no configured hook **fails** (the runner
exits non-zero); it is never falsely green. Agents must not claim a rung passes
until its hook exists and has been run. A project deliberately opts a rung out by
making its hook print `skip`.
