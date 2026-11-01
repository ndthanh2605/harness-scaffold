# 0007 Overlay Authority: Explicit-Invoke Skills, Managed CLAUDE.md Block, Global Install Skill

Date: 2026-11-01

## Status

Accepted — 2026-11-01

## Context

`docs/HARNESS.md` states the project goal as "a reusable operating harness," but
today the harness only operates correctly when it **is** the repository: this
repo's own `CLAUDE.md` requires every task to invoke `harness-intake` first, and
`.claude/skills/harness-*` live only inside this repo's own `.claude/skills/`,
with no mechanism to copy them into another project.

Turning this into a template/overlay harness for other projects means solving
two separate problems:

1. How does the harness get copied into another repo without clobbering that
   repo's own `CLAUDE.md` content or existing skills?
2. Once installed, should a harness skill claim the right to auto-trigger on
   every task in a repo it does not own, alongside whatever other skills and
   instructions that repo already has?

Research into the sibling repo `repository-harness` (its decisions 0019, 0026,
0028) found this exact problem already solved: skills there are **explicit-invoke
only** — a skill's own manifest never claims universal auto-trigger rights — and
the installed `CLAUDE.md` fragment uses a **managed-marker block**, so repeated
installs/updates touch only the harness-owned region and never the consumer's own
content. Their stated rationale: an auto-triggering skill "competes with the
repository for authority" once dropped into someone else's project.

Research into the `pstack` Claude Code plugin found a complementary *structural*
shape worth reusing: a single thin router skill (`poteto-mode`) that cites a
catalog of small, independently invocable skills by name, rather than one skill
holding all logic inline. pstack's own autonomy philosophy ("Never Block on the
Human") was considered and explicitly **rejected** for this project — it conflicts
with the hard gates already in place (Harness Change Policy, Plan Deviation
Protocol); see Decision 0008 for how reduced human-in-the-loop load is instead
achieved without weakening those gates.

## Decision

**1. Skill A — `harness-install` (new, global skill).** Lives in the maintainer's
personal global skill directory (`~/.claude/skills/`), **not** inside this repo's
own `.claude/skills/` — it must be invocable from any target project's working
directory, not only from this one. Explicit-invoke only. **Wraps, rather than
replaces, `scripts/install-harness.sh`:**

- For bulk payload — `docs/`, `scripts/`, `.harness/*.example`,
  `.claude/skills/harness-*` — Skill A shells out to
  `scripts/install-harness.sh --merge` (or `--override`/`--dry-run` per the
  human's instruction), reusing its existing tested manifest and
  create/skip/backup logic as-is. The script keeps working standalone,
  curl-pipeable, with no Claude Code required — that remains the path for
  bootstrapping a brand-new, empty project.
- For `CLAUDE.md` specifically, Skill A adds the one thing the script cannot
  do: today, when `CLAUDE.md` already exists, the script's `--merge` mode
  skips the whole file untouched — on a real consumer project (which already
  has its own `CLAUDE.md`) that installs nothing. Skill A instead writes or
  updates a managed block, delimited by `<!-- HARNESS:BEGIN -->` /
  `<!-- HARNESS:END -->`, inside that file. Only content inside the markers is
  ever touched on re-run; content outside — the consumer's own, pre-existing
  instructions — is never modified.
- Idempotent: re-running cleanly updates the managed region, including dropping
  entries for skills retired upstream since the last install (same idempotent
  full-rewrite shape as pstack's `setup-pstack`).
- Never silently overwrites a file it did not itself create or that sits
  outside the managed marker, in either the script-delegated bulk copy or the
  marker-block `CLAUDE.md` merge.

**2. Skill B — rework of the existing `harness-intake` skill, not a new skill.**
Its frontmatter/description is edited to drop any language implying universal
auto-trigger (the current "invoke at the start of every non-trivial task" moves
out of the skill's own manifest). It remains callable by explicit name from any
project. Its body is restructured from one monolithic `SKILL.md` into a thin
router: classify input type and risk lane, then **cite** smaller, independently
invocable `principle-*` skills by name for the house rules (Plan Deviation
Protocol, Default Posture, etc. — see Decision 0008) instead of inlining all
rule prose into one file.

The initial `principle-*` extraction set (maintainer's call, open to revision
during implementation): `principle-plan-deviation` (Decision 0005's protocol),
`principle-invariant-markers` (`[INVARIANT]`/`[FLEX]`), `principle-default-posture`
(the six Default Posture rules, including the never-block-but-not-unconditionally
stance), and `principle-enforcement-tiers` (Decision 0008's L0-L3 taxonomy). All
four live under this repo's own `.claude/skills/`, alongside `harness-intake` and
the `harness-git-*` skills — they are part of the harness payload Skill A
installs and Decision 0008's manifest drift-check covers, not a separate,
unlisted library. `harness-supervise` (Decision 0008) is a fifth skill in this
same directory, cited by Skill B at the `in_progress → human_review` step.

**3. The managed block covers this scaffold's entire harness-authored
`CLAUDE.md` content**, not just the one invoke-directive line: `## Source Of
Truth`, `## Task Loop` (including "call `harness-intake` before any task"),
`## Harness Change Policy`, and `## Done Definition` all live inside
`<!-- HARNESS:BEGIN -->`/`<!-- HARNESS:END -->` as a single block. Narrower
options (wrapping only the Task Loop, or only the single invoke line) were
rejected: this project's governance rules (Harness Change Policy, Done
Definition) are exactly the kind of content that must not silently drift
between the upstream scaffold and an installed copy — wrapping only the
procedural steps while leaving governance text as free-editable prose would
let a consumer's copy of the *rules* diverge unnoticed, defeating the point of
Decision 0008's tiering. A consuming project's own, pre-existing `CLAUDE.md`
content sits entirely outside this block and is never touched. This
repository dogfoods the identical mechanism: its own `CLAUDE.md` becomes
managed-block content installed into itself by the same Skill A — this repo's
present-day behavior is unchanged, only its authority source changes from "the
skill says so" to "this repo's own CLAUDE.md, which I installed, says so."

**4. Skill B may reference `references/pstack-routing.md`** (narrow scope — 4-5
touchpoints: high-risk execplan design, Growth Rule transcript-mining,
human_review-gate critique, parallel research/exploration, validation-hook
generation), mapping specific harness-workflow moments to specific optional
`pstack` skills. Documented explicitly as optional/soft: Skill B must work
correctly with `pstack` absent, falling back to the current manual approach at
every touchpoint. Scope chosen narrow as the maintainer's call; revisit if it
proves too thin in practice.

## Alternatives Considered

1. **Keep `harness-intake` auto-triggering via its own description; solve
   overlay only via the managed `CLAUDE.md` block.** Rejected: the skill would
   still claim universal authority, which breaks the moment a consumer's own
   `CLAUDE.md` or another installed skill also claims first-task authority —
   the exact failure repository-harness's decision 0019 names.
2. **Ship Skill A as a Claude Code plugin (marketplace-distributed, versioned)
   instead of a personal global skill.** Rejected for now — a plain global
   skill is sufficient per the maintainer; packaging as a plugin is a
   distribution concern that can be revisited later without changing Skill A's
   install logic.
3. **Adopt pstack's `poteto-mode` wholesale as Skill B** (single router +
   playbook catalog + blanket "never block" autonomy rule). Rejected: the
   never-block default conflicts with this project's existing hard gates; see
   Decision 0008 for how reduced human-in-the-loop load is achieved via
   enforcement tiering instead of a blanket autonomy rule.
4. **Build a real self-updating CLI now** (three-way merge, as in
   repository-harness's Rust binary). Rejected: no CLI exists at v0; the
   lighter `--dry-run` convention inside Skill A captures the same "never
   silently overwrite divergent content" principle without needing a binary.
5. **Rewrite all install logic inside Skill A, retiring
   `scripts/install-harness.sh`.** Rejected: the script's bulk-copy
   manifest/conflict logic already works and is independently useful
   curl-pipeable, with no Claude Code required — bootstrapping a brand-new
   project from a bare terminal is a real, still-valid use case distinct from
   overlaying onto an existing one. Rewriting it would duplicate working logic
   for no behavioral gain.
6. **Keep Skill A and the script as two fully independent, non-interacting
   systems.** Rejected: would require maintaining two separate manifests in
   parallel indefinitely, which is the same drift risk Decision 0008's
   install-manifest check exists to close.
7. **Wrap only the Task Loop section, or only the single invoke-directive
   line, in the managed `CLAUDE.md` block.** Rejected: both leave this
   project's governance text (Harness Change Policy, Done Definition) as
   silently-driftable prose, undermining Decision 0008's point that
   governance-level rules deserve the same non-drift guarantee as code.

## Consequences

Positive:

- `harness-scaffold` can be dropped into another project without fighting that
  project's existing `CLAUDE.md` or skills.
- This repo's own task-loop requirement is preserved behaviorally; only its
  authority source changes to the mechanism a consumer would also use.
- Skill B's router shape makes house rules independently citable, setting up
  Decision 0008's `principle-*` extraction.

Tradeoffs:

- Skill A's manifest and Skill B's description must stay in sync with whatever
  this scaffold ships; drift here is caught by Decision 0008's drift-check.
- Skill A lives outside this repo's version control; this repo cannot fully
  self-document its exact current contents. Link to wherever its source is
  tracked once written.
- Skill A now depends on `scripts/install-harness.sh`'s manifest and exit
  behavior for the bulk-copy half of its work — a breaking change to the
  script's flags or manifest format must update Skill A too, and this
  dependency only runs in one direction (the script stays usable standalone).
- Because the managed `CLAUDE.md` block covers all four harness-authored
  sections, a consumer who wants to keep this scaffold's Task Loop but write
  their own Harness Change Policy text cannot do so inside the managed region
  — they would need to deliberately move that content outside the markers,
  accepting that it then no longer updates from upstream.
- Splitting `harness-intake` into a router plus cited `principle-*` skills
  trades one-stop-reading for composability — a new contributor now opens more
  files to see full behavior.

## Follow-Up

- Implement Skill A (`harness-install`) and the `harness-intake` rework as
  follow-on stories once this decision is accepted.
- `docs/HARNESS_BACKLOG.md` — track `references/pstack-routing.md` scope as a
  minor open item to revisit.
- Decision 0008 — tiered enforcement, Evidence field, drift-check,
  `principle-*` extraction mechanics this decision depends on.

## References

- `docs/HARNESS.md` — current task-loop / state machine whose authority source
  this changes.
- `docs/HARNESS_BACKLOG.md` — "Installer Manifest Is Stale Relative to Skills"
  (closed by Decision 0008's manifest drift-check).
- `repository-harness` decisions 0019, 0025, 0026, 0028 (sibling repo —
  explicit-invoke, managed-marker, merge/override/dry-run precedent).
- `scripts/install-harness.sh` — the existing installer Skill A wraps for bulk
  payload copy; its current `--merge`/`--override`/`--dry-run` flags and
  protected-path conflict logic are reused as-is.
- `pstack` plugin `skills/poteto-mode/SKILL.md`, `skills/setup-pstack/SKILL.md`
  (structural precedent for router shape and idempotent rule-writer).
- Decision 0008 (tiered enforcement — the reason "architecture direction" and
  "feature workflow" changes stayed gated even while invocation mechanics were
  redesigned).
