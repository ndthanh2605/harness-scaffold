---
name: harness-install
description: >
  Install or update the harness-scaffold template into a target project:
  runs install-harness.sh, which copies the harness payload and merges the
  managed CLAUDE.md block natively, without touching the target's own,
  pre-existing CLAUDE.md content. Explicit-invoke only — never
  auto-triggered. Run from the target project's own working directory, or
  pass --directory.
disable-model-invocation: true
---

# Harness Install

## Goal

Drop (or update) the harness-scaffold operating model into a target
project, without clobbering that project's own `CLAUDE.md` content,
existing skills, or any non-harness content under `docs/`/`scripts/`.
Implements `docs/decisions/0007-overlay-authority-and-explicit-invocation.md`.

This skill is **global** (lives in the maintainer's own
`~/.claude/skills/`, not inside `harness-scaffold`'s own `.claude/skills/`)
because it must be invocable from any target project's working directory,
not only from `harness-scaffold` itself.

As of `docs/decisions/0008`'s follow-on fix (US-008), `scripts/
install-harness.sh` itself implements the `CLAUDE.md` managed-block merge
natively (`merge_claude_md()`) and never wholesale-moves `docs/`/`scripts/`
on override — this skill no longer needs to carry that logic as separate
manual steps; it only needs to invoke the script.

## Inputs

- A target directory (defaults to the current working directory).
- A conflict mode: `--merge` (default — add missing files, skip existing
  ones, except `CLAUDE.md` which always merges safely by marker),
  `--override` (back up and replace existing harness-owned files
  individually — never anything outside the manifest), or `--dry-run`.

## Steps

1. Run the installer remotely — no local clone of `harness-scaffold` is
   required:

   ```bash
   curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" \
     | bash -s -- --directory "<target>" --merge
   ```

   Substitute `--override` or `--dry-run` per the human's instruction. This
   copies `docs/`, `scripts/`, `.harness/*.example`, and every
   `.claude/skills/harness-*` and `.claude/skills/principle-*` directory,
   and merges `CLAUDE.md`'s managed block — all using the script's own
   tested, manifest-driven logic.

2. Report what the script printed (created/updated/skipped/merged counts)
   back to the human.

## Output

Target project has the current harness payload, and a `CLAUDE.md` whose
`<!-- HARNESS:BEGIN -->`/`<!-- HARNESS:END -->` block matches
`harness-scaffold`'s `main` branch. Content outside the markers — the
target's own instructions — and any non-harness content under `docs/`/
`scripts/` are exactly as they were before.

## Related Skills

None — this skill is global and runs independently of any
`harness-scaffold`-specific skill set, since its job is to install that set
into a project that doesn't have it yet.
