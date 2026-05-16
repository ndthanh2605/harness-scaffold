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

