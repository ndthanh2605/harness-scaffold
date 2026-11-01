---
name: harness-git-push
description: >
  Push committed work to origin/main, with a pre-push security scan and
  story packet Evidence linking. Use instead of commit-commands:commit-push-pr
  in this project — no PR is created (Decision 0009: solo-maintainer
  workflow, review happens in chat). Invoke after committing to push work.
---

# Harness Git Push

## Goal

Push the current branch (in practice, almost always `main` — see
`docs/decisions/0009-retire-pr-gate.md`) to origin, and record what was
pushed in the story packet Evidence section.

## Inputs

- One or more commits, ready to push.
- Story packet file path.

## Steps

1. Run `git status` — confirm the working tree is clean (no untracked or
   modified files that should have been committed).

2. Check for sensitive files about to be pushed:

   ```bash
   git diff --name-only origin/main..HEAD 2>/dev/null \
     | grep -E '(\.env([./]|$)|id_rsa|\.(key|pem|p12|crt|secret)$|(^|/)secrets/)'
   ```

   If any match: abort, remove or `.gitignore` the file, re-commit, then
   return to step 1. If `origin/main` does not exist locally, run
   `git fetch origin main` first.

3. Push:

   ```bash
   git push origin HEAD
   ```

   If rejected (non-fast-forward): stop and run the `harness-git-pull` skill
   to sync with origin/main first, then return to step 1 of this skill.

4. Open the story packet and record the pushed commit(s) in `## Evidence`:

   ```
   Pushed: <short-sha> on YYYY-MM-DD.
   ```

## Output

Work pushed to `origin/main`. Pushed commit SHA recorded in story packet
Evidence. No PR is created or required.

## Related Skills

- `harness-git-pull`: run this first if push is rejected (non-fast-forward).
- `harness-git-commit`: run before this skill, to produce the commit(s) being pushed.
