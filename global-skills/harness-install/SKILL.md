---
name: harness-install
description: >
  Install or update the harness-scaffold template into a target project:
  copies the harness payload (docs/skills/scripts) via the existing
  install-harness.sh script, then merges the managed CLAUDE.md block
  without touching the target's own, pre-existing CLAUDE.md content.
  Explicit-invoke only — never auto-triggered. Run from the target
  project's own working directory, or pass --directory.
disable-model-invocation: true
---

# Harness Install

## Goal

Drop (or update) the harness-scaffold operating model into a target
project, without clobbering that project's own `CLAUDE.md` content or
existing skills. Implements
`docs/decisions/0007-overlay-authority-and-explicit-invocation.md`.

This skill is **global** (lives in the maintainer's own
`~/.claude/skills/`, not inside `harness-scaffold`'s own `.claude/skills/`)
because it must be invocable from any target project's working directory,
not only from `harness-scaffold` itself.

## Inputs

- A target directory (defaults to the current working directory).
- A conflict mode: `--merge` (default — add missing files, skip existing
  ones), `--override` (back up and replace), or `--dry-run`.

## Steps

1. **Bulk payload copy.** Run the existing installer remotely — no local
   clone of `harness-scaffold` is required:

   ```bash
   curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" \
     | bash -s -- --directory "<target>" --merge
   ```

   Substitute `--override` or `--dry-run` per the human's instruction. This
   copies `docs/`, `scripts/`, `.harness/*.example`, and every
   `.claude/skills/harness-*` and `.claude/skills/principle-*` directory,
   using the script's own tested manifest and conflict logic, unchanged.

2. **Check whether the target already had its own `CLAUDE.md` before step 1.**
   - No `CLAUDE.md` existed → step 1 already created one (a copy of
     `harness-scaffold`'s own `CLAUDE.md`, which already carries the
     `<!-- HARNESS:BEGIN -->`/`<!-- HARNESS:END -->` block). Nothing more to
     do — skip to Step 4.
   - A `CLAUDE.md` already existed → step 1's `--merge` mode left it
     completely untouched (the script never edits existing files in merge
     mode). Continue to Step 3.

3. **Merge the managed block into the target's existing `CLAUDE.md`.**

   a. Fetch the upstream block:

      ```bash
      curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/CLAUDE.md?$(date +%s)" \
        > /tmp/harness-upstream-claude.md
      ```

   b. Extract everything from `<!-- HARNESS:BEGIN -->` to
      `<!-- HARNESS:END -->` inclusive:

      ```bash
      sed -n '/<!-- HARNESS:BEGIN -->/,/<!-- HARNESS:END -->/p' \
        /tmp/harness-upstream-claude.md > /tmp/harness-block.md
      ```

   c. In the target's `CLAUDE.md`:
      - Already contains a `<!-- HARNESS:BEGIN -->` / `<!-- HARNESS:END -->`
        pair (a prior install) → replace exactly that span with the freshly
        extracted block. Everything outside the span is untouched.
      - No such markers yet (first install into an existing file) → append
        the extracted block to the end of the file, separated by a blank
        line. Everything already in the file stays exactly as it was, above
        the appended block.

   d. In `--dry-run` mode, print what would change (diff-style) instead of
      writing the file.

4. **Report** what was created, updated, or left untouched — mirroring
   `scripts/install-harness.sh`'s own summary-line style.

## Output

Target project has the current harness payload, and a `CLAUDE.md` whose
`<!-- HARNESS:BEGIN -->`/`<!-- HARNESS:END -->` block matches
`harness-scaffold`'s `main` branch. Content outside the markers — the
target's own instructions — is exactly as it was before.

## Related Skills

None — this skill is global and runs independently of any
`harness-scaffold`-specific skill set, since its job is to install that set
into a project that doesn't have it yet.
