# Scripts

This directory is reserved for harness automation.

## Installer

The upstream installer applies the Harness v0 operating files and folder
structure to a target project directory. It defaults to the current directory,
accepts a target path, and asks interactive users whether to `1. Merge`,
`2. Override`, or `3. Stop` when the target already contains `CLAUDE.md`,
`docs/`, or `scripts/`.
Non-interactive installs stop on those protected paths unless `--merge` or
`--override` is provided.

```bash
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

```bash
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes
```

The installer must stay limited to harness files. Do not use it to scaffold
application source folders, package scripts, CI, tests, platform shells, or fake
validation commands. The installer script is not part of the installed project
payload.

## Validation And Support Scripts

These are harness automation (not application source), so they are exempt from the
"no application scaffolding" rule above. None of them hardcodes a language or
toolchain — that keeps the scaffold general.

- **`validate.sh <rung>`** — language-agnostic validation runner. Rungs:
  `quick | integration | e2e | platform | release`. Each rung dispatches to a
  project-owned hook at `.harness/<rung>` (see `.harness/README.md`). `quick`
  always runs `harness-check.sh` first. An unconfigured rung **fails** (exits
  non-zero) — it is never falsely green, so this is the opposite of a fake
  validation command.
- **`harness-check.sh`** — harness self-check (doc-lint). Validates the harness's
  own artifacts (story sections, workpad siblings, `## Declared Files` fences, no
  unratified deviations on done stories, decision-record references, the test
  matrix). Needs no product code; it is the always-on base of `validate:quick`.
- **`new-story.sh <US-ID> <slug> [--high-risk]`** — scaffolds a story packet (and
  workpad) from `docs/templates/`.

A project adapts validation by editing `.harness/` hooks, never these scripts.

```text
quick        format, lint, typecheck, unit tests, harness self-check
integration  backend contract and integration checks
e2e          user-visible end-to-end flows
platform     platform / shell / desktop / mobile / deployment smoke
release      full suite, log checks, and performance smoke
```
