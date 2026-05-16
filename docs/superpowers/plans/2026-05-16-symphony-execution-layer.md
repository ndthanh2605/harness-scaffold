# Symphony Execution Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enrich harness-experimental with an execution layer — four git workflow skills, a story execution state machine, a sibling workpad template, parity for the high-risk lane, an ADR explaining the choice, and installer support so the changes ship to consumer projects — so any greenfield project using this harness gets a complete preparation + execution operating model.

**Architecture:**
- `.claude/skills/{commit,push,pull,land}.md` — git workflow skill contracts, discoverable by Claude Code.
- `docs/templates/story.workpad.md` and `docs/templates/high-risk-story/workpad.md` — *sibling* workpad files so the story packet stays a stable contract while execution state mutates freely.
- `docs/templates/story.md` and `docs/templates/high-risk-story/execplan.md` gain a `## Status` field with the state machine documented in a comment.
- `docs/HARNESS.md` gains an `## Execution Phase` section (state machine, default posture, blocked escape hatch) and a `.claude/skills/` pointer in Source Hierarchy.
- `CLAUDE.md` gains the skills pointer and three task-loop checklist questions.
- `docs/decisions/0004-execution-state-machine.md` records why this shape.
- `docs/TEST_MATRIX.md` gains a `harness-execution-layer` row with grep-based proof.
- `scripts/install-harness.sh` manifest gains the new files so consumer installs get them.
- `docs/stories/US-001-install-harness.md` migrates from `implemented` (legacy) to `done` (state-machine).

**Tech Stack:** Markdown, git, GitHub CLI (`gh`), bash installer.

**Pre-existing drift this plan does NOT fix (filed as separate backlog candidates):** the installer still references `AGENTS.md` as the agent entrypoint while the working tree has moved to `CLAUDE.md`; the test-matrix status vocabulary (`planned | in_progress | implemented | changed | retired`) is distinct from the new story-execution state machine and stays distinct (behavior-proof status vs. story-execution status — kept separate intentionally; see ADR 0004).

---

## File Map

| File | Action |
|---|---|
| `scripts/install-harness.sh` | Modify — extend manifest, document protected `.claude/` path |
| `.claude/skills/commit.md` | Create — conventional commit skill |
| `.claude/skills/push.md` | Create — push + PR skill |
| `.claude/skills/pull.md` | Create — sync with main skill |
| `.claude/skills/land.md` | Create — safe merge skill with branch-protection handling |
| `docs/templates/story.md` | Modify — status field + state machine comment + workpad pointer |
| `docs/templates/story.workpad.md` | Create — sibling workpad template |
| `docs/templates/high-risk-story/execplan.md` | Modify — status field + state machine comment + workpad pointer |
| `docs/templates/high-risk-story/workpad.md` | Create — high-risk sibling workpad template |
| `docs/stories/US-001-install-harness.md` | Modify — migrate status to `done` |
| `docs/HARNESS.md` | Modify — Execution Phase section + Source Hierarchy entry |
| `CLAUDE.md` | Modify — skills pointer + task loop questions |
| `docs/decisions/0004-execution-state-machine.md` | Create — ADR for the state machine + sibling-workpad choice |
| `docs/TEST_MATRIX.md` | Modify — add `harness-execution-layer` row |

All commit messages in this plan use `Co-Authored-By: Claude <noreply@anthropic.com>`. Substitute the actual running model name (e.g., `Claude Opus 4.7`) if exact attribution is preferred.

---

## Task 0: Extend Installer Manifest

**Files:**
- Modify: `scripts/install-harness.sh`

The installer ships harness files to consumer projects via a hardcoded manifest (the newline-separated list near the bottom of `scripts/install-harness.sh`). Without this task, target repos receive the new CLAUDE.md / HARNESS.md references to skills but not the skill files themselves — a broken install.

- [ ] **Step 1: Locate the manifest in the installer**

  ```bash
  grep -n 'docs/decisions/0003' scripts/install-harness.sh
  ```

  Use the returned line number as the anchor. The manifest is the contiguous block of file paths around it (look for the heredoc or array boundary).

- [ ] **Step 2: Add new files to the manifest**

  Append these paths to the manifest, alphabetized within their groups:

  ```
  .claude/skills/commit.md
  .claude/skills/land.md
  .claude/skills/pull.md
  .claude/skills/push.md
  docs/decisions/0004-execution-state-machine.md
  docs/templates/high-risk-story/workpad.md
  docs/templates/story.workpad.md
  ```

  These are the *new* files created by this plan. Existing modified files (`docs/templates/story.md`, `docs/HARNESS.md`, `docs/TEST_MATRIX.md`, etc.) are already in the manifest and need no installer change.

- [ ] **Step 3: Document `.claude/` as a protected path (advisory note only)**

  Add a one-line comment above the protected-paths logic (around line 145, `check_protected_target_paths`):

  ```
  # Note: .claude/ is not protected here because target projects may already
  # use it for their own settings; new files under .claude/skills/ install
  # only into matching subdirectories and never overwrite without --force.
  ```

  Do not change the protection list — leave AGENTS.md / docs / scripts intact.

- [ ] **Step 4: Verify the manifest contains the new paths**

  ```bash
  grep -c '\.claude/skills/' scripts/install-harness.sh
  ```

  Expected: `4`.

  ```bash
  grep -c '0004-execution-state-machine\|story\.workpad\|high-risk-story/workpad' scripts/install-harness.sh
  ```

  Expected: `3`.

- [ ] **Step 5: Installer dry-run smoke**

  ```bash
  TMP=$(mktemp -d)
  scripts/install-harness.sh --directory "$TMP" --yes --dry-run | tee /tmp/install-dryrun.log
  grep -c '\.claude/skills/' /tmp/install-dryrun.log
  rm -rf "$TMP"
  ```

  Expected: dry-run lists at least 4 lines mentioning `.claude/skills/`. (The skill files will not yet exist on disk when this task runs first — that is fine; the manifest declares intent, later tasks create the files. Re-run this smoke at Task 8.)

- [ ] **Step 6: Commit**

  ```bash
  git add scripts/install-harness.sh
  git commit -m "$(cat <<'EOF'
  feat(installer): extend manifest for execution-layer files

  Why: the execution-layer plan adds new files under .claude/skills/, new
  template workpads, and a new ADR. Without manifest entries, consumer
  installs would receive the CLAUDE.md references without the underlying
  files, creating a broken install.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 1: Create `.claude/skills/commit.md`

**Files:**
- Create: `.claude/skills/commit.md`

- [ ] **Step 1: Create the skills directory**

  ```bash
  mkdir -p .claude/skills
  ```

  Expected: directory exists, no output.

- [ ] **Step 2: Write commit.md**

  Create `.claude/skills/commit.md` with exactly this content:

  ````markdown
  ---
  name: commit
  description: Produce a well-formed conventional commit with rationale
  ---

  # Commit Skill

  ## Goal

  Stage explicitly chosen changes and commit them with a conventional commit
  message that explains both what changed and why.

  ## Inputs

  - One or more changed files
  - Knowledge of the story or task being implemented

  ## Steps

  1. Run `git status` to review all changed files. Confirm only intended files
     will be committed. Never include `.env*`, `id_rsa*`, `*.key`, `*.pem`,
     `*.p12`, `*.crt`, `*.secret`, or anything under `secrets/`.

  2. **Stage explicitly.** Use `git add <file>` for each intended file.
     Never use `git add -A` or `git add .` — both pick up unintended changes
     and have caused secret leaks in the past.

  3. Run `git diff --staged` and review the exact changes that will be
     committed. If anything unintended is present, unstage it with
     `git restore --staged <file>` and return to step 2.

  4. Draft the commit message using conventional commit format:

     ```
     type(scope): short summary under 72 chars

     Why: one or two sentences explaining the reason for this change.

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

     Valid types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

     The `Why:` line is required. "fix bug" or "add feature" with no rationale
     is not acceptable output. Replace `Claude` with the actual running model
     name (e.g., `Claude Opus 4.7`) if exact attribution is preferred.

  5. Commit using a heredoc to preserve formatting:

     ```bash
     git commit -m "$(cat <<'EOF'
     type(scope): summary

     Why: reason.

     Co-Authored-By: Claude <noreply@anthropic.com>
     EOF
     )"
     ```

  6. Run `git log -1 --oneline` to verify the commit was created correctly.

  ## Output

  A single commit with: type, scope, summary, `Why:` rationale, Co-Authored-By
  trailer. Only explicitly-staged files are included.

  ## Next

  Run the `push` skill to push the branch and update the PR.
  ````

- [ ] **Step 3: Verify the file exists and has the correct sections**

  ```bash
  grep -n "^## " .claude/skills/commit.md
  ```

  Expected output:
  ```
  ## Goal
  ## Inputs
  ## Steps
  ## Output
  ## Next
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add .claude/skills/commit.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add commit git workflow skill

  Why: agents had no standard contract for producing well-formed conventional
  commits with rationale and explicit-stage discipline. Adapted from
  Symphony's commit skill pattern, tightened against accidental staging.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 2: Create `.claude/skills/push.md`

**Files:**
- Create: `.claude/skills/push.md`

- [ ] **Step 1: Write push.md**

  Create `.claude/skills/push.md` with exactly this content:

  ````markdown
  ---
  name: push
  description: Push branch to remote and create or update the PR
  ---

  # Push Skill

  ## Goal

  Push the current branch to origin and ensure a PR is open and linked in the
  story packet Evidence section.

  ## Inputs

  - One or more commits on a feature branch
  - Story packet file path

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

  3. Push the branch:

     ```bash
     git push -u origin HEAD
     ```

     If rejected (non-fast-forward): stop and run the `pull` skill to sync
     with origin/main first, then return to step 1 of this skill.

  4. Check whether a PR already exists:

     ```bash
     gh pr view --json url,state 2>/dev/null
     ```

     - No output or error → create a new PR. Substitute the real story id and
       title — never push literal `US-XXX`:
       ```bash
       gh pr create --title "US-001: actual story title here" --body "$(cat <<'EOF'
       Implements US-001 (real story id).

       Story: docs/stories/US-001-actual-story.md
       Workpad: docs/stories/US-001-actual-story.workpad.md
       EOF
       )"
       ```
     - PR exists → update description if needed:
       ```bash
       gh pr edit --body "updated body"
       ```

  5. Copy the PR URL. Open the story packet and record it in `## Evidence`:

     ```
     PR: https://github.com/<owner>/<repo>/pull/<N>
     ```

  ## Output

  Branch pushed to origin. PR open and URL recorded in story packet Evidence.

  ## Related Skills

  - `pull`: run this first if push is rejected (non-fast-forward).
  - `land`: run this after the PR is approved and CI is green.
  ````

- [ ] **Step 2: Verify the file**

  ```bash
  grep -n "^## " .claude/skills/push.md
  ```

  Expected:
  ```
  ## Goal
  ## Inputs
  ## Steps
  ## Output
  ## Related Skills
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add .claude/skills/push.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add push git workflow skill

  Why: agents needed a standard protocol for pushing branches and creating
  PRs that includes a broad sensitive-file check (env*, id_rsa, *.key/pem/
  p12/crt/secret, secrets/) and links the PR back to the story packet and
  workpad sibling.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 3: Create `.claude/skills/pull.md`

**Files:**
- Create: `.claude/skills/pull.md`

- [ ] **Step 1: Write pull.md**

  Create `.claude/skills/pull.md` with exactly this content:

  ````markdown
  ---
  name: pull
  description: Sync current branch with origin/main before editing
  ---

  # Pull Skill

  ## Goal

  Bring the current branch up to date with `origin/main` before starting or
  continuing work. Record the sync result in the story workpad sibling file.

  ## Inputs

  - A checked-out branch (may be behind origin/main)
  - An open story packet and its workpad sibling
    (`docs/stories/US-XXX.workpad.md` for Normal-lane stories,
    `docs/stories/US-XXX/workpad.md` inside the folder for High-Risk).

  ## Steps

  1. Fetch the latest remote state without changing the working tree:

     ```bash
     git fetch origin
     ```

  2. Check how far behind the branch is:

     ```bash
     git log HEAD..origin/main --oneline
     ```

     If no output: already up to date. Record in workpad Notes and stop.

  3. Default convention is `merge`. If the project explicitly uses rebase
     (check `git config pull.rebase` or recent merged PRs), use:

     ```bash
     git rebase origin/main
     ```

     Otherwise:

     ```bash
     git merge origin/main
     ```

  4. If conflicts appear:

     - Run `git status` to list conflicted files.
     - Open each conflicted file and resolve it explicitly. Do not blindly
       accept `--ours` or `--theirs` without understanding what each side does.
     - Run `git add <resolved-file>` for each resolved file.
     - Run `git merge --continue` (or `git rebase --continue`).

  5. Get the resulting HEAD short SHA:

     ```bash
     git rev-parse --short HEAD
     ```

  6. Record in the **workpad sibling** Notes section:

     ```
     YYYY-MM-DD: Synced with origin/main. Result: clean | conflicts-resolved. HEAD: <short-sha>
     ```

     Do not edit the story packet for sync notes — keep the packet a stable
     contract.

  ## Output

  Branch is up to date with origin/main. Workpad Notes records the sync result
  and resulting HEAD SHA.

  ## Related Skills

  - `push`: run this skill when push is rejected due to non-fast-forward.
  - `commit`: run after pull to commit any conflict-resolution changes.
  ````

- [ ] **Step 2: Verify the file**

  ```bash
  grep -n "^## " .claude/skills/pull.md
  ```

  Expected:
  ```
  ## Goal
  ## Inputs
  ## Steps
  ## Output
  ## Related Skills
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add .claude/skills/pull.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add pull git workflow skill

  Why: agents needed a standard sync protocol that picks merge or rebase
  per project convention and records the result in the workpad sibling
  (keeping the story packet a stable contract).

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 4: Create `.claude/skills/land.md`

**Files:**
- Create: `.claude/skills/land.md`

- [ ] **Step 1: Write land.md**

  Create `.claude/skills/land.md` with exactly this content:

  ````markdown
  ---
  name: land
  description: Safely merge an approved PR and close out the story
  ---

  # Land Skill

  ## Goal

  Merge a PR that has been approved by a human reviewer, verify the merge
  succeeded, and close out the story packet. Handle branch-protected `main`.

  ## Prerequisites

  - Story status is `merging` (human approved PR and set status)
  - PR has at least one approved review
  - CI is green on the latest commit

  ## Steps

  1. Confirm PR approval and CI status with a single pass/fail check:

     ```bash
     gh pr view --json state,reviews,statusCheckRollup --jq '
       if .state != "OPEN" then "FAIL: state is \(.state)"
       elif ([.reviews[]? | select(.state=="APPROVED")] | length) < 1
         then "FAIL: no approved review"
       elif ([.statusCheckRollup[]? | select(.conclusion!=null and .conclusion!="SUCCESS")] | length) > 0
         then "FAIL: failing checks: \([.statusCheckRollup[] | select(.conclusion!=null and .conclusion!="SUCCESS") | .name] | join(","))"
       else "PASS"
       end
     '
     ```

     If output is not `PASS`: stop. Record the failure in workpad Notes.

  2. Determine the project's merge convention from recent merged PRs:

     ```bash
     gh pr list --state merged --limit 5 --json title,mergeCommit \
       --jq '[.[] | select(.mergeCommit != null) | .mergeCommit.oid] | length'
     ```

     If the number is high relative to PR count and squash is the team's
     stated convention, use `--squash`. If unsure, ask the human. Default
     when the project has no history: `--squash`.

  3. Merge the PR and delete the branch:

     ```bash
     gh pr merge --squash --delete-branch
     ```

     (Replace `--squash` with `--merge` if the project convention requires it.)

  4. Switch to main and pull the merged changes:

     ```bash
     git checkout main
     git pull origin main
     ```

  5. Verify the merge is present in main:

     ```bash
     git log --oneline -5
     ```

     Confirm the story's commit (or squash commit) appears in the log.

  6. Update the story packet:

     - Set `## Status` to `done`.
     - Add to `## Evidence`:
       ```
       Merged: <PR URL> at <short-sha> on YYYY-MM-DD
       ```

  7. Update `docs/TEST_MATRIX.md`: set the story's row status to `implemented`
     and add the merge SHA as the evidence reference.

  8. Decide how to ship the doc-close commit based on whether `main` is
     branch-protected. Detect:

     ```bash
     gh api "repos/{owner}/{repo}/branches/main/protection" \
       --jq '.required_status_checks // .required_pull_request_reviews // empty' 2>/dev/null
     ```

     - **No output → main is unprotected.** Commit directly:

       ```bash
       git add docs/stories/US-XXX.md docs/TEST_MATRIX.md
       git commit -m "$(cat <<'EOF'
       docs(US-XXX): mark done, record merge evidence

       Why: story is complete and merged; closing out packet and test matrix.

       Co-Authored-By: Claude <noreply@anthropic.com>
       EOF
       )"
       git push origin main
       ```

     - **Output non-empty → main is protected.** Open a follow-up close PR:

       ```bash
       git checkout -b docs/US-XXX-close
       git add docs/stories/US-XXX.md docs/TEST_MATRIX.md
       git commit -m "$(cat <<'EOF'
       docs(US-XXX): mark done, record merge evidence

       Why: closing out packet and test matrix after the implementation PR
       merged. Branch protection on main requires this as a separate PR.

       Co-Authored-By: Claude <noreply@anthropic.com>
       EOF
       )"
       git push -u origin HEAD
       CLOSE_PR_URL=$(gh pr create --title "docs(US-XXX): close story" --body "Closes story US-XXX after merge. See <impl-PR-URL>." | tail -1)
       gh pr merge --auto --squash --delete-branch || true
       ```

       Record `CLOSE_PR_URL` in the story Evidence under a `Close PR:` line.

  ## Output

  PR merged. Feature branch deleted. Story status `done`. PR URL and merge SHA
  recorded in Evidence. Test matrix row set to `implemented`. Doc-close commit
  is on main (unprotected) or in an auto-merging follow-up PR (protected).

  ## Related Skills

  - `push`: if the branch needs a final update before merge, run push first.
  - `pull`: if main has advanced since the branch was last synced.
  ````

- [ ] **Step 2: Verify the file**

  ```bash
  grep -n "^## " .claude/skills/land.md
  ```

  Expected:
  ```
  ## Goal
  ## Prerequisites
  ## Steps
  ## Output
  ## Related Skills
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add .claude/skills/land.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add land git workflow skill

  Why: agents needed a safe merge protocol with a jq-based pass/fail gate,
  a branch-protection detector that falls back to a doc-close follow-up PR,
  and explicit close-out of the story packet and test matrix.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 5: Story Template — Add Status + State Machine + Workpad Pointer

**Files:**
- Modify: `docs/templates/story.md`

The Workpad lives in a sibling file (Task 5b), not in the story packet itself. The story packet remains a stable contract; the workpad carries mutable execution state. This task adds the new `## Status` block, the state-machine comment, and a one-line pointer to the workpad sibling.

- [ ] **Step 1: Replace the Status section**

  Current content (lines 3–6):
  ```markdown
  ## Status

  planned
  ```

  Replace with:
  ```markdown
  ## Status

  todo

  <!-- State machine — transition only when the gate is fully met:
    todo         → in_progress  : agent creates US-XXX.workpad.md from template, runs pull skill, begins implementation
    in_progress  → human_review : workpad checked, validation green, PR linked, no uncommitted changes
    human_review → merging      : human approves PR
    human_review → rework       : human posts actionable feedback
    rework       → in_progress  : agent resets workpad, re-implements
    merging      → done         : PR merged, test matrix updated, Evidence complete
    any          → blocked      : external blocker documented, human action needed
  -->
  ```

- [ ] **Step 2: Add a workpad pointer above `## Evidence`**

  Find this text near the end of the file:
  ```markdown
  ## Harness Delta

  Document any harness updates made or proposed because of this story.

  ## Evidence

  Add commands, reports, screenshots, or links after validation exists.
  ```

  Replace with:
  ```markdown
  ## Harness Delta

  Document any harness updates made or proposed because of this story.

  ## Workpad

  Execution state lives in `docs/stories/US-XXX.workpad.md`. The agent creates
  the sibling file from `docs/templates/story.workpad.md` at the
  `todo → in_progress` transition and updates it throughout execution. Do not
  embed execution state in this packet — keep the packet a stable contract.

  ## Evidence

  Add commands, reports, screenshots, or links after validation exists.
  ```

- [ ] **Step 3: Verify the final structure**

  ```bash
  grep -n "^## " docs/templates/story.md
  ```

  Expected (line numbers may vary):
  ```
  ## Status
  ## Lane
  ## Product Contract
  ## Relevant Product Docs
  ## Acceptance Criteria
  ## Design Notes
  ## Validation
  ## Harness Delta
  ## Workpad
  ## Evidence
  ```

- [ ] **Step 4: Confirm the state machine comment is present**

  ```bash
  grep -c "todo\|in_progress\|human_review\|merging\|rework\|done\|blocked" docs/templates/story.md
  ```

  Expected: 7 or more (one per state machine row plus the default status value).

- [ ] **Step 5: Commit**

  ```bash
  git add docs/templates/story.md
  git commit -m "$(cat <<'EOF'
  feat(harness): extend story template with state machine and workpad pointer

  Why: stories had no execution state machine (todo→done) and no canonical
  separation between contract (packet) and execution log (workpad). The
  state machine documents the transitions; the workpad pointer references
  the sibling file that carries mutable execution state.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 5b: Create Workpad Templates

**Files:**
- Create: `docs/templates/story.workpad.md`
- Create: `docs/templates/high-risk-story/workpad.md`

- [ ] **Step 1: Write `docs/templates/story.workpad.md`**

  ```markdown
  # US-XXX Workpad

  <!-- This is the live execution log for the story. Mutate freely.
       Do not store contract material here — that belongs in US-XXX.md. -->

  **Environment:** `<host>:<abs-workdir>@<short-sha>`

  ## Plan

  - [ ] Step 1
    - [ ] 1.1 Sub-step

  ## Acceptance Criteria

  - [ ] Criterion 1 (mirrors story AC, checked off as verified)

  ## Validation

  - [ ] `<command>` — <what it proves>

  ## Notes

  - YYYY-MM-DD: <progress note>

  ## Confusions

  <!-- only include when something was genuinely unclear during execution -->
  ```

- [ ] **Step 2: Write `docs/templates/high-risk-story/workpad.md`**

  Same content as above. High-risk stories live in a folder
  (`docs/stories/US-XXX/`), so the workpad becomes `docs/stories/US-XXX/workpad.md`
  alongside `overview.md`, `design.md`, `execplan.md`, `validation.md`.

- [ ] **Step 3: Verify both files exist with the expected sections**

  ```bash
  for f in docs/templates/story.workpad.md docs/templates/high-risk-story/workpad.md; do
    echo "=== $f ==="
    grep "^## " "$f"
  done
  ```

  Each file should have: `## Plan`, `## Acceptance Criteria`, `## Validation`,
  `## Notes`, `## Confusions`.

- [ ] **Step 4: Commit**

  ```bash
  git add docs/templates/story.workpad.md docs/templates/high-risk-story/workpad.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add workpad sibling templates for normal and high-risk lanes

  Why: separating the mutable execution log from the stable story contract
  keeps packet diffs clean and lets the workpad be archived or cleared
  post-merge without rewriting the contract.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 5c: Extend High-Risk `execplan.md` with Status and State Machine

**Files:**
- Modify: `docs/templates/high-risk-story/execplan.md`

High-risk stories use a multi-file bundle; execution state belongs in
`execplan.md`. Add the same `## Status` block as the Normal template so both
lanes flow through the same state machine.

- [ ] **Step 1: Read the current execplan.md**

  ```bash
  cat docs/templates/high-risk-story/execplan.md
  ```

  Identify where to insert the Status section. If the file already has top-
  level sections, insert `## Status` as the first one (after the H1 title).

- [ ] **Step 2: Insert the same Status + state machine block used in story.md**

  Insert immediately after the file's H1:

  ```markdown
  ## Status

  todo

  <!-- State machine — transition only when the gate is fully met:
    todo         → in_progress  : agent creates US-XXX/workpad.md from template, runs pull skill, begins implementation
    in_progress  → human_review : workpad checked, validation green, PR linked, no uncommitted changes
    human_review → merging      : human approves PR
    human_review → rework       : human posts actionable feedback
    rework       → in_progress  : agent resets workpad, re-implements
    merging      → done         : PR merged, test matrix updated, Evidence complete
    any          → blocked      : external blocker documented, human action needed
  -->

  ## Workpad

  Execution state lives in `docs/stories/US-XXX/workpad.md`. The agent creates
  the sibling file from `docs/templates/high-risk-story/workpad.md` at the
  `todo → in_progress` transition.
  ```

- [ ] **Step 3: Verify**

  ```bash
  grep -c "todo\|in_progress\|human_review\|merging\|rework\|done\|blocked" docs/templates/high-risk-story/execplan.md
  ```

  Expected: 7 or more.

- [ ] **Step 4: Commit**

  ```bash
  git add docs/templates/high-risk-story/execplan.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add state machine + workpad pointer to high-risk execplan

  Why: high-risk stories use a multi-file bundle and were previously outside
  the new execution state machine. Adding the same Status block to execplan.md
  unifies both lanes under one execution model.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 5d: Migrate Legacy Story Status

**Files:**
- Modify: `docs/stories/US-001-install-harness.md`

The existing story uses the legacy `implemented` status (which belongs to
TEST_MATRIX vocabulary, not story-execution). Migrate to the closest state-
machine value: `done`.

- [ ] **Step 1: Update the story status**

  Find:
  ```markdown
  ## Status

  implemented
  ```

  Replace with:
  ```markdown
  ## Status

  done
  ```

- [ ] **Step 2: Verify**

  ```bash
  grep -A1 "^## Status" docs/stories/US-001-install-harness.md
  ```

  Expected: `done`.

- [ ] **Step 3: Commit**

  ```bash
  git add docs/stories/US-001-install-harness.md
  git commit -m "$(cat <<'EOF'
  chore(US-001): migrate status from implemented to done

  Why: implemented is TEST_MATRIX vocabulary; the new story-execution state
  machine uses done. Aligning legacy story with the new state machine.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 6: Update HARNESS.md — Execution Phase + Source Hierarchy

**Files:**
- Modify: `docs/HARNESS.md`

Two additions: a new `## Execution Phase` section between `## Spec Lifecycle`
and `## Growth Rule`, plus a `.claude/skills/` entry in the Source Hierarchy
block so it stays in sync with CLAUDE.md.

- [ ] **Step 1: Insert the Execution Phase section**

  Find this exact text in `docs/HARNESS.md`:
  ```markdown
  ## Growth Rule

  The harness grows from friction.
  ```

  Insert the following block immediately before it (with a blank line before
  `## Growth Rule`):

  ```markdown
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
  | `todo` | `in_progress` | Agent creates workpad sibling, runs pull skill, begins implementation |
  | `in_progress` | `human_review` | Workpad Plan + AC checked off, validation green, PR linked, no uncommitted changes |
  | `human_review` | `merging` | Human approves PR |
  | `human_review` | `rework` | Human posts actionable feedback |
  | `rework` | `in_progress` | Agent resets workpad, re-implements |
  | `merging` | `done` | PR merged, test matrix row updated, Evidence complete |
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
  3. **Sync before editing** — invoke the `pull` skill before any code changes.
     Record the sync result in workpad Notes.
  4. **Status gates** — only transition story status when the gate for that
     state is fully met. Do not advance status optimistically.
  5. **Scope discipline** — out-of-scope improvements discovered during
     execution go to `HARNESS_BACKLOG.md`, not into the current story.
  6. **Operate autonomously until truly blocked** — `blocked` is an escape hatch
     for external blockers (missing auth, missing required tool, required human
     decision after exhausting all fallbacks). It is not a shortcut for
     difficult problems.

  ### Blocked-Access Escape Hatch

  When blocked after exhausting all documented fallbacks:

  1. Add to workpad Confusions: what is missing, why it is needed, and what
     human action unblocks it.
  2. Set story status to `blocked`.
  3. Stop. Do not loop or stall indefinitely.

  ```

- [ ] **Step 2: Add a bullet to Harness v0 Scope**

  Find this in `docs/HARNESS.md`:
  ```markdown
  - Harness growth backlog.
  ```
  (Last bullet of the Harness v0 Scope includes list.)

  Replace with:
  ```markdown
  - Harness growth backlog.
  - Git workflow skill contracts (`.claude/skills/`).
  ```

- [ ] **Step 3: Add `.claude/skills/` to the Source Hierarchy block**

  Find this in `docs/HARNESS.md`:
  ```text
  docs/decisions/*
    why the contract changed
  ```

  Replace with:
  ```text
  docs/decisions/*
    why the contract changed

  .claude/skills/*
    git workflow skill contracts (commit, push, pull, land) invoked during execution
  ```

- [ ] **Step 4: Verify section ordering**

  ```bash
  grep -n "^## " docs/HARNESS.md
  ```

  Expected sections in order:
  ```
  ## Mental Model
  ## Harness v0 Scope
  ## Source Hierarchy
  ## Spec Lifecycle
  ## Execution Phase
  ## Growth Rule
  ## Future Validation Ladder
  ```

- [ ] **Step 5: Verify subsections**

  ```bash
  grep -n "^### " docs/HARNESS.md
  ```

  Expected within Execution Phase:
  ```
  ### State Machine
  ### Default Posture
  ### Blocked-Access Escape Hatch
  ```

- [ ] **Step 6: Commit**

  ```bash
  git add docs/HARNESS.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add Execution Phase section to HARNESS.md

  Why: the harness described preparation but nothing about how agents behave
  during execution. Added state machine (applies to both lanes), default
  posture, blocked-access escape hatch, and a .claude/skills/ entry in
  Source Hierarchy so it stays aligned with CLAUDE.md.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 7: Update CLAUDE.md — Skills Pointer and Task Loop

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add item 10 to the Source Of Truth list**

  Find:
  ```markdown
  9. `docs/decisions/` for why important choices were made.
  ```

  Replace with:
  ```markdown
  9. `docs/decisions/` for why important choices were made.
  10. `.claude/skills/` for git workflow skill contracts (commit, push, pull, land).
  ```

- [ ] **Step 2: Add three questions to the Task Loop checklist**

  Find:
  ```markdown
     - Did the next agent need a clearer instruction?
  7. Update routine harness files directly, or add a proposal to
  ```

  Replace with:
  ```markdown
     - Did the next agent need a clearer instruction?
     - Was the workpad sibling updated throughout execution?
     - Was the correct skill used for each git operation (commit, push, pull, land)?
     - Is the story status at the correct state-machine gate for where work stands?
  7. Update routine harness files directly, or add a proposal to
  ```

- [ ] **Step 3: Verify both additions**

  ```bash
  grep -cE "\.claude/skills|workpad sibling|each git operation|state-machine gate" CLAUDE.md
  ```

  Expected: 4.

- [ ] **Step 4: Commit**

  ```bash
  git add CLAUDE.md
  git commit -m "$(cat <<'EOF'
  feat(harness): add skills pointer and execution checklist to CLAUDE.md

  Why: agents need to know .claude/skills/ exists and to confirm the workpad
  was updated, the right skill was used for each git operation, and the
  story is at the correct state-machine gate before finishing a task.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 7b: ADR and TEST_MATRIX Row

**Files:**
- Create: `docs/decisions/0004-execution-state-machine.md`
- Modify: `docs/TEST_MATRIX.md`

- [ ] **Step 1: Write the ADR**

  Create `docs/decisions/0004-execution-state-machine.md` (use the existing
  ADRs `0001`/`0002`/`0003` as the structure reference — read one first if
  unsure):

  ```markdown
  # 0004 Execution State Machine and Sibling Workpad

  ## Status

  Accepted — 2026-05-16

  ## Context

  The harness defined preparation (intake, story templates, validation
  expectations) but nothing about how agents behave during execution.
  Symphony's execution patterns supply a useful default: a defined state
  machine for stories, plus a workpad that carries live execution state.

  Two integration questions had to be settled:

  1. Where does execution state live — inside the story packet or in a
     sibling file?
  2. Does the story-execution status share vocabulary with the existing
     TEST_MATRIX status?

  ## Decision

  - Adopt a seven-state machine for story execution:
    `todo → in_progress → human_review → {merging | rework} → done`,
    with `any → blocked` as an escape hatch.
  - Apply the same state machine to both lanes: Normal stories carry the
    `## Status` field in `story.md`; High-Risk stories carry it in
    `execplan.md`.
  - Put the workpad in a **sibling file** (`US-XXX.workpad.md` for Normal,
    `US-XXX/workpad.md` for High-Risk), not inside the story packet. The
    packet stays a stable contract; the workpad mutates freely during
    execution.
  - Keep story-execution status distinct from TEST_MATRIX behavior-proof
    status. Both coexist: `todo … done` describes a story's execution
    progress; `planned … implemented … retired` describes whether a product
    behavior has proof. A story may be `done` and its matrix row
    `implemented`, but a behavior can also be `retired` long after the story
    that introduced it was `done`.

  ## Consequences

  - Story packets stay stable across execution iterations — diffs reflect
    contract changes, not progress noise.
  - Workpads can be archived, cleared, or kept indefinitely after merge
    without rewriting the contract.
  - Two status vocabularies in the harness; the distinction is explicit in
    `HARNESS.md` and CLAUDE.md.
  - The state machine adds gate checks the agent must satisfy before
    advancing status — minor overhead per transition, paid for by clearer
    handoffs.

  ## Alternatives Considered

  - Workpad embedded inside `story.md` (rejected: contract/log conflation,
    noisy diffs).
  - Unified status vocabulary across story execution and test matrix
    (rejected: they describe different things and would conflict — a
    behavior `retired` is unrelated to whether its origin story `done`d).
  - Apply state machine only to Normal lane (rejected: creates two
    execution models, hurts agent consistency).

  ## References

  - `docs/HARNESS.md` — `## Execution Phase`
  - `.claude/skills/{commit,push,pull,land}.md` — workflow skills referenced
    by the state machine gates
  - `docs/templates/story.workpad.md`,
    `docs/templates/high-risk-story/workpad.md` — sibling workpad shape
  ```

- [ ] **Step 2: Add a TEST_MATRIX row**

  Find the Matrix table in `docs/TEST_MATRIX.md`:
  ```markdown
  | Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
  | --- | --- | --- | --- | --- | --- | --- | --- |
  | TBD | Add rows when story packets are created | no | no | no | no | planned | none |
  ```

  Append a row (keep the TBD row if present, or replace it with the real row):
  ```markdown
  | harness-execution-layer | Execution state machine, workpad sibling, git workflow skills present | no | no | no | yes | implemented | grep proofs in docs/superpowers/plans/2026-05-16-symphony-execution-layer.md Task 8 |
  ```

- [ ] **Step 3: Verify**

  ```bash
  ls docs/decisions/0004-execution-state-machine.md
  grep -c "harness-execution-layer" docs/TEST_MATRIX.md
  ```

  Expected: file exists; grep returns `1`.

- [ ] **Step 4: Commit**

  ```bash
  git add docs/decisions/0004-execution-state-machine.md docs/TEST_MATRIX.md
  git commit -m "$(cat <<'EOF'
  docs(decisions): record state machine + sibling workpad rationale (ADR 0004)

  Why: structural harness changes require an ADR per CLAUDE.md source-of-truth
  rules. ADR explains why a state machine (vs ad-hoc), why a sibling workpad
  (vs embedded), and why story-execution status stays distinct from
  TEST_MATRIX behavior-proof status. Test matrix row records the proof.

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

---

## Task 8: Verification Sweep

No new files. Confirm the full harness is internally consistent.

- [ ] **Step 1: Confirm all four skill files exist**

  ```bash
  ls -1 .claude/skills/
  ```

  Expected:
  ```
  commit.md
  land.md
  pull.md
  push.md
  ```

- [ ] **Step 2: Confirm each skill has the required sections**

  ```bash
  for f in .claude/skills/*.md; do echo "=== $f ==="; grep "^## " "$f"; done
  ```

  Each file should have at minimum: `## Goal`, `## Inputs` (or
  `## Prerequisites`), `## Steps`, `## Output`.

- [ ] **Step 3: Confirm story template state machine and workpad pointer are present**

  ```bash
  grep -c "todo\|in_progress\|human_review\|merging\|rework\|done\|blocked" docs/templates/story.md
  ```

  Expected: 7 or more.

  ```bash
  grep -c "story\.workpad\.md\|Workpad" docs/templates/story.md
  ```

  Expected: ≥2 (heading + reference).

- [ ] **Step 4: Confirm high-risk execplan state machine present**

  ```bash
  grep -c "todo\|in_progress\|human_review\|merging\|rework\|done\|blocked" docs/templates/high-risk-story/execplan.md
  ```

  Expected: 7 or more.

- [ ] **Step 5: Confirm workpad templates exist**

  ```bash
  ls docs/templates/story.workpad.md docs/templates/high-risk-story/workpad.md
  ```

  Expected: both exist.

- [ ] **Step 6: Confirm HARNESS.md execution phase is present**

  ```bash
  grep -c "Execution Phase\|Default Posture\|Blocked-Access" docs/HARNESS.md
  ```

  Expected: 3.

  ```bash
  grep -c "\.claude/skills/" docs/HARNESS.md
  ```

  Expected: ≥2 (Source Hierarchy entry + Scope bullet).

- [ ] **Step 7: Confirm CLAUDE.md additions**

  ```bash
  grep -cE "\.claude/skills|workpad sibling|each git operation|state-machine gate" CLAUDE.md
  ```

  Expected: 4.

- [ ] **Step 8: Confirm ADR + TEST_MATRIX row**

  ```bash
  ls docs/decisions/0004-execution-state-machine.md
  grep -c "harness-execution-layer" docs/TEST_MATRIX.md
  ```

  Expected: file exists; grep returns `1`.

- [ ] **Step 9: Confirm legacy story migration**

  ```bash
  grep -A1 "^## Status" docs/stories/US-001-install-harness.md | tail -1
  ```

  Expected: `done`.

- [ ] **Step 10: Smoke test — create scratch story + workpad from updated templates**

  ```bash
  cp docs/templates/story.md /tmp/US-TEST.md
  cp docs/templates/story.workpad.md /tmp/US-TEST.workpad.md
  grep "^## " /tmp/US-TEST.md
  grep "^## " /tmp/US-TEST.workpad.md
  grep "todo" /tmp/US-TEST.md | head -3
  rm /tmp/US-TEST.md /tmp/US-TEST.workpad.md
  ```

  Expected: all section headers present in both files; `todo` appears as the
  status default and in the state machine comment.

- [ ] **Step 11: Installer dry-run smoke (re-run from Task 0)**

  ```bash
  TMP=$(mktemp -d)
  scripts/install-harness.sh --directory "$TMP" --yes --dry-run | tee /tmp/install-dryrun.log
  grep -c '\.claude/skills/' /tmp/install-dryrun.log
  grep -c '0004-execution-state-machine\|story\.workpad\|high-risk-story/workpad' /tmp/install-dryrun.log
  rm -rf "$TMP"
  ```

  Expected: ≥4 lines for `.claude/skills/`; ≥3 lines for the other new files.

- [ ] **Step 12: Confirm git log shows all commits from this plan**

  ```bash
  git log --oneline -12
  ```

  Expected: ~10 commits visible (Tasks 0, 1, 2, 3, 4, 5, 5b, 5c, 5d, 6, 7, 7b),
  each with a descriptive `feat(harness):` / `feat(installer):` /
  `docs(decisions):` / `chore(US-001):` prefix.
