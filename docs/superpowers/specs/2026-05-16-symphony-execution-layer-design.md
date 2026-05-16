# Symphony Execution Layer — Design Spec

**Date:** 2026-05-16
**Status:** approved
**Scope:** harness-experimental enrichment

---

## Context

harness-experimental is a *work preparation* harness: it turns human intent and specs into product docs, story packets, and validation expectations. What it lacks is an *execution layer* — behavioral contracts and workflow tools for what agents do while actually implementing a story.

Symphony (OpenAI's agent harness) is a complementary *work execution* harness: it specifies agent behavior during implementation via a state machine, workpad tracking, git workflow skills, and a default posture. Its preparation layer (spec intake, test matrix, risk classification) is weak where harness-experimental's is strong.

This spec defines how to merge Symphony's three most valuable execution patterns into harness-experimental so any greenfield project that installs this harness gets a complete preparation + execution operating model.

---

## What We're Adding

### 1. Git Workflow Skills — `.claude/skills/`

Four skill files, agent-framework agnostic markdown docs that Claude Code discovers via the Skill tool.

```
.claude/skills/
├── commit.md    — conventional commit with rationale
├── push.md      — push branch + create/update PR
├── pull.md      — sync with origin/main, conflict resolution
└── land.md      — safe merge after PR approval
```

**Commit skill:** Stages changes, writes a conventional commit (`type(scope): summary` + rationale + tests + `Co-Authored-By` trailer). Rationale line is required — "fix bug" commits are not acceptable output. References the push skill for the next step.

**Push skill:** Validates no untracked secret files before pushing. Pushes branch, creates or updates PR using `gh pr create`/`gh pr edit`. Links PR to story packet. References pull skill if push is rejected (non-fast-forward).

**Pull skill:** Syncs with `origin/main` via merge. Records the sync result (merge source, result, resulting HEAD SHA) in the story workpad Notes. If conflicts arise, resolves them with explicit reasoning before proceeding.

**Land skill:** Safe merge loop — does not call `gh pr merge` directly. Checks CI status, waits for green, merges via skill-defined flow, verifies post-merge state. Calls push skill to ensure branch is current before merging.

Skills cross-reference each other: `push` → `pull` on rejection; `land` → `push` + CI check loop.

---

### 2. Story Template Changes — `docs/templates/story.md`

**a. Extended status field**

Replace the current status vocabulary with the full execution state machine:

```
todo | in_progress | human_review | merging | done | blocked | rework
```

State machine transitions (encoded as template comments):

| Transition | Trigger |
|---|---|
| `todo` → `in_progress` | Agent begins workpad and runs pull skill |
| `in_progress` → `human_review` | Workpad fully checked, validation green, PR linked |
| `human_review` → `merging` | Human approves PR |
| `human_review` → `rework` | Human leaves actionable feedback |
| `rework` → `in_progress` | Agent resets workpad and re-implements |
| `merging` → `done` | PR merged, test matrix updated, Evidence complete |
| `any` → `blocked` | External blocker documented, human action needed |

**b. Workpad section**

New `## Workpad` section inserted between `## Acceptance Criteria` and `## Evidence`. The agent maintains this in-place throughout execution. It is the single source of truth for live progress.

```markdown
## Workpad
<!-- Agent updates this section throughout execution. Do not remove. -->

**Environment:** `<host>:<abs-workdir>@<short-sha>`

### Plan
- [ ] Step 1
  - [ ] 1.1 sub-step

### Acceptance Criteria
- [ ] Criterion 1 (mirrors story AC, checked off as verified)

### Validation
- [ ] `<command>` — <what it proves>

### Notes
- YYYY-MM-DD: <progress note>

### Confusions
- <only when something was genuinely unclear during execution>
```

The existing `## Evidence` section stays for final completed proof (test output, screenshots, validation reports). Workpad is live; Evidence is committed.

---

### 3. HARNESS.md — Execution Phase Section

New `## Execution Phase` section added to `docs/HARNESS.md`, covering:

**a. State machine + quality gates**

Documents what must be true before each status transition. The key gate is `in_progress` → `human_review`:
- Workpad Plan and Acceptance Criteria fully checked off
- Validation commands green on latest commit
- PR linked to the story packet
- No untracked or uncommitted changes

The `human_review` → `done` path requires PR merged and test matrix row updated.

**b. Default posture**

Six behavioral rules agents follow during any story execution:

1. **Reproduce before changing** — confirm the current broken or missing behavior (for bugs) or confirm the feature is absent (for new work) before editing code. Record the reproduction signal in workpad Notes.
2. **Workpad-first** — update the workpad plan before writing implementation. Planning in the file, not in your head.
3. **Sync before editing** — run the `pull` skill before any code changes. Record the pull result in workpad Notes.
4. **Status gates** — only transition story status when the gate for that state is fully met. Don't optimistically advance.
5. **Scope discipline** — out-of-scope improvements discovered during execution go to `HARNESS_BACKLOG.md`, not into the current story.
6. **Operate autonomously until truly blocked** — `blocked` is an escape hatch for external blockers (missing auth, missing tool, missing required human decision). It is not a shortcut for hard problems.

**c. Blocked-access escape hatch**

When blocked after exhausting all documented fallbacks:
1. Document the blocker in workpad Confusions section: what is missing, why it is needed, what human action unblocks it.
2. Move story status to `blocked`.
3. Stop. Do not stall or loop.

---

### 4. CLAUDE.md — Execution References

Two additions to the project CLAUDE.md:

**Source Of Truth list** gets a new entry:
```
10. `.claude/skills/` for git workflow skill contracts (commit, push, pull, land).
```

**Task Loop** gets three new final checklist questions:
- Was the workpad updated in the story file throughout execution?
- Was the correct skill used for each git operation?
- Is the story status at the correct gate for where work stands?

---

## Files to Create or Modify

| File | Action | Description |
|---|---|---|
| `.claude/skills/commit.md` | Create | Conventional commit skill |
| `.claude/skills/push.md` | Create | Push + PR creation skill |
| `.claude/skills/pull.md` | Create | Sync with main skill |
| `.claude/skills/land.md` | Create | Safe merge skill |
| `docs/templates/story.md` | Modify | Extended status field + Workpad section |
| `docs/HARNESS.md` | Modify | New `## Execution Phase` section |
| `CLAUDE.md` | Modify | Skills pointer + execution loop questions |

---

## What This Does Not Include

- PR description template or PR feedback sweep protocol (not selected)
- `WORKFLOW.md` orchestrator prompt (not selected — no live orchestrator)
- CI configuration or test runner setup (excluded by Harness v0 scope)
- Application-specific guardrails (those arrive with the first project spec)

---

## Verification

After implementation, verify by:

1. Checking `.claude/skills/` contains all four skill files and each has Goals, Inputs, Steps, Output sections.
2. Opening `docs/templates/story.md` and confirming the status field lists all 7 states with transition comments, and that the Workpad section is present and structured correctly.
3. Opening `docs/HARNESS.md` and confirming the `## Execution Phase` section is present with all three subsections (state machine, default posture, blocked escape hatch).
4. Opening `CLAUDE.md` and confirming the skills pointer appears in Source Of Truth and the three workpad/status questions appear in the Task Loop checklist.
5. Creating a scratch story from the updated template to confirm the workpad renders correctly and status states are readable.
