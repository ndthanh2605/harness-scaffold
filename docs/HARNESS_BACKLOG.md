# Harness Backlog

Use this file when an agent discovers a missing harness capability but should
not change the operating model immediately.

## Template

```md
## Missing Harness Capability

### Title

Short name.

### Discovered While

Task or story that exposed the gap.

### Current Pain

What was hard, repeated, ambiguous, or unsafe?

### Evidence

What observation proves this pain point is real, not a hunch (a reproduced
failure, a repeated transcript pattern, a specific friction moment — not "this
seems like it would help"). When moving to `implemented`, append what an
independent rerun (a fresh agent with no shared context, per
`docs/decisions/0008-tiered-enforcement.md`'s L2) confirmed the fix actually
worked.

### Suggested Improvement

What should be added or changed?

### Risk

Tiny, normal, or high-risk.

### Status

proposed | accepted | implemented | rejected
```

## Items

## Missing Harness Capability

### Title

Formal Merge-Approval Mechanism Doesn't Match Solo-Maintainer Reality

### Discovered While

US-002 and US-003 (2026-11-01) — both stories hit the same gap independently.

### Current Pain

`harness-git-land`'s step 1 requires a GitHub `APPROVED` PR review before
merging. In practice, review on this repo happens live in chat with the
agent, not via GitHub's review UI — there is no second human reviewer, and
the maintainer approves verbally ("ok, merge"). Both US-002 (which skipped
the PR step entirely, D1) and US-003 (which opened a PR but had no formal
GitHub review, D1) had to record a ratified deviation for the same reason.
Recording the same deviation every story is honest but repetitive, and the
skill contract increasingly describes a process that doesn't match how this
repo is actually used.

### Evidence

Two independent occurrences of the identical gap: `docs/stories/US-002-
tiered-enforcement-foundations.workpad.md` D1 (direct-to-main push, no PR)
and `docs/stories/US-003-harness-supervise.workpad.md` D1 (PR opened, no
formal GitHub review, chat approval instead). Same root cause both times,
confirmed by `gh pr view --json reviews` returning no approved review on a
PR the maintainer had already approved in chat.

### Suggested Improvement

Either (a) update `harness-git-land`'s step 1 to accept an explicit
"approved in chat" substitute — e.g. require the agent to quote the
maintainer's verbatim approval message in the workpad instead of a GitHub
review object, or (b) decide this repo's actual convention is direct-to-main
for a solo maintainer and formally retire the PR-based gate in
`harness-git-push`/`harness-git-land`. Either is a change to the documented
feature workflow (Harness Change Policy L3) and needs the maintainer's
explicit decision, not an agent's unilateral choice — this item only
proposes it.

### Risk

Normal — touches two existing skill contracts, no application code.
Testable by running a story through the chosen convention end-to-end.

### Status

implemented — resolved via `docs/decisions/0009-retire-pr-gate.md` and
US-006 (2026-11-01): the maintainer decided directly (option (b)) to retire
the PR-based gate rather than add a chat-approval substitute. State machine
gates, `harness-git-push`, and `harness-git-land` updated accordingly.

## Missing Harness Capability

### Title

Git Worktree Isolation Per Story (Autonomous Multi-Agent Support)

### Discovered While

Symphony execution layer design session — evaluating what Symphony's orchestrator
provides that the harness git skills do not cover.

### Current Pain

The git skills (commit, push, pull, land) assume the agent is already on the
correct branch in the correct working directory. There is no skill or protocol
for creating an isolated workspace per story before work begins. This means:

- Two agents working simultaneously on different stories would trample each
  other's working tree.
- Agents have no standard way to create and clean up a per-story branch.
- The harness cannot support autonomous task pickup (agent selects a `todo`
  story and starts work) without first solving workspace isolation.

### Suggested Improvement

Add a `worktree.md` skill to `.claude/skills/` that:

1. Creates a `git worktree` for the story (`git worktree add ../US-XXX story/US-XXX`).
2. Is called at the `todo → in_progress` state transition, before the `pull` skill.
3. Records the worktree path in the story workpad Environment stamp.
4. Tears down the worktree at `done` (`git worktree remove`).

Update the story template state machine to reference this skill at the
`todo → in_progress` gate. Update the `pull` skill to pull into the worktree
rather than the main workspace.

This enables agents to autonomously pick well-planned isolated stories, work
in parallel without conflict, and commit independently — each story gets its
own working tree from the moment an agent claims it.

### Risk

Normal — touches story state machine and two existing skills, but no
application code. Testable by running two agents against different stories.

### Status

proposed

## Missing Harness Capability

### Title

Mechanical Plan-Deviation Enforcement via `harness-cli`

### Discovered While

Adopting the Plan Deviation Protocol (ADR-0005) from chronicler. chronicler
enforced it with a `scripts/validate-plan.sh` bash gate; that artifact is wrong
for this lineage (no product code to scan here, and the mature sibling harness
enforces through a Rust `harness-cli` + durable layer, not grep scripts).

### Current Pain

**Partially addressed by ADR-0006.** The structural half now runs mechanically in
`scripts/harness-check.sh` (no `open` deviation on a done story; `## Declared Files`
fences parse), and a language-agnostic source-marker gate ships as
`.harness/deviation-scan.example`. What remains for this item is a **durable**
record: bash gates are diff/branch-scoped and project-opt-in, with no queryable
history of deviations across stories. A `harness-cli` durable surface would close
that gap.

### Suggested Improvement

Once the scaffold gains a `harness-cli` (as in `repository-harness`), add a
mechanical deviation gate modeled on that surface:

1. A durable deviation/intervention record (cf. `harness-cli intervention add`)
   so deviations live in the durable layer, not only in workpad prose.
2. A `story verify` check that fails when the workpad `## Deviations` has an
   `open` (unratified) entry, when an added source file is absent from the
   story's `## Declared Files`, or when a workaround marker was introduced
   without a logged, ratified deviation.
3. Wire that check into whatever validation gate the state machine enforces at
   `in_progress → human_review` (the equivalent of chronicler's `validate:quick`
   chaining), so "done via an undocumented workaround" no longer passes.

### Risk

Normal — adds CLI behavior and a state-machine gate, but no product/application
code. Testable with seeded story packets (positive: ratified deviation passes;
negative: open deviation / undeclared file / unannotated workaround fails).

### Status

proposed

## Missing Harness Capability

### Title

Installer Manifest Is Stale Relative to Skills

### Discovered While

Adding the Plan Deviation Protocol (ADR-0005) and checking whether the change
seeds downstream projects via `scripts/install-harness.sh`.

### Current Pain

The installer copies a hardcoded file manifest. It still lists the pre-rename
skills `.claude/skills/{commit,land,pull,push}.md` — which have been deleted —
and omits the current `.claude/skills/harness-{intake,git-commit,git-push,
git-pull,git-land}/SKILL.md` skills entirely. So a freshly installed project
gets no git/intake skills (or stale references to deleted files), and the
deviation protocol's commit-skill self-check does not propagate. The manifest
must be hand-edited for every new doc/skill, which is how it drifted.

### Suggested Improvement

Update the manifest to the current skill layout (the `harness-*/SKILL.md`
directories), drop the deleted single-file skill entries, and consider deriving
the manifest from a glob or a tracked `MANIFEST` file so it cannot silently
drift from the repo contents again.

### Risk

Normal — touches only the installer script's file list, no application code.
Testable by running the installer into an empty target and diffing the result
against the scaffold's tracked files.

### Evidence

`scripts/harness-check.sh` now asserts manifest⇄filesystem parity in both
directions (US-002, 2026-11-01): it fails on a seeded skill file missing from
the manifest and on a seeded manifest entry pointing to a file that doesn't
exist, and passes on the real, in-sync repo state. Independently re-verified
by a fresh reviewer agent with no shared context (both fixtures reproduced
and confirmed, 2026-11-01) — satisfies Decision 0008's L2 gate.

### Status

partially implemented — the immediate breakage is fixed (2026-06-26, ratified
deviation during the validation-layer work): the stale `{commit,land,pull,push}.md`
entries are replaced with the current `harness-*/SKILL.md` skills, and the missing
decision records (0005, 0006) were added; installer now runs clean into an empty
target. The drift-detection gap is now closed (US-002, 2026-11-01):
`harness-check.sh` asserts manifest⇄filesystem parity in both directions, so a
future drift is caught mechanically instead of silently recurring. **Still
open:** deriving the manifest from a glob / tracked MANIFEST file is not
done — the heredoc list in `scripts/install-harness.sh` remains hand-maintained,
so the check detects drift after the fact rather than preventing it
structurally. That root-cause item stays open.

