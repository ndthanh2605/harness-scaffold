# harness-scaffold

A reusable preparation and execution harness for agent-driven software development.

> Forked from [hoangnb24/harness-experimental](https://github.com/hoangnb24/harness-experimental).

This is not an app template. It is a repository-level operating harness for
turning human intent or a product spec into agent-ready work — and then
guiding agents through that work safely and traceably.

The app is what users touch. The harness is what agents touch.

## Why This Exists

Coding agents are becoming useful enough to participate in real software work,
but the model alone is not the whole system. A repository also needs clear
instructions, shared product truth, validation loops, git workflow contracts,
and decision records so an agent can understand what matters before it changes
code — and behave predictably while doing so.

Harness Engineering is the practice of designing that operating environment.
The goal is not simply to make AI write code faster. The goal is to make
AI-assisted software development more reliable, inspectable, and easier for
humans to steer.

## Current State

This repository is in Harness v0.

There is no application implementation and no baked-in product specification
yet. The current work is the reusable project harness: the file structure,
agent operating model, feature intake process, story templates, execution state
machine, git workflow skills, and validation expectations that help humans and
agents turn a future user-provided spec into implementation work.

## What a Harness Includes

A repository starts to have a harness when it helps an agent answer practical
engineering questions without relying only on chat history:

**Preparation layer** — what to work on and how risky it is:
- What should I read first?
- What type of work is this?
- Which product contract does it affect?
- How risky is the change?
- What proof will show the work is done?

**Execution layer** — how to behave while doing the work:
- What is the current state of this story?
- What must be true before I can advance to the next gate?
- Where does my live execution log live?
- Which git workflow should I follow?
- What decision or lesson should future agents inherit?

In this repo, those answers live in `CLAUDE.md`, `docs/HARNESS.md`,
`docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md`, `docs/TEST_MATRIX.md`,
`docs/stories/`, `docs/decisions/`, `docs/templates/`, and `.claude/skills/`.

## Try The Flow

The fastest way to understand the harness is to inspect a tiny example:

- `docs/demo/README.md`: shows how a simple product idea becomes product docs,
  stories, validation expectations, and decisions before implementation starts.

## Execution Layer

The harness includes a story execution state machine and git workflow skills
merged from Symphony (OpenAI's agent harness).

### Story State Machine

Every story packet carries a `## Status` field. Agents transition it only when
the gate for that state is fully met:

```
todo → in_progress → human_review → merging → done
                  ↘ rework ↗          ↘ (any) → blocked
```

The workpad sibling file (`US-XXX.workpad.md`) carries live execution state —
the step-by-step plan, checked-off acceptance criteria, validation commands, and
progress notes. The story packet stays a stable contract; the workpad mutates
freely. See `docs/decisions/0004-execution-state-machine.md` for the rationale.

### Skills

Each skill lives at `.claude/skills/<name>/SKILL.md`:

- `harness-intake/SKILL.md` — feature intake: classify the request, select the
  lane, locate or propose the story packet (invoke at task start)
- `harness-git-commit/SKILL.md` — conventional commit with explicit staging and
  required rationale
- `harness-git-push/SKILL.md` — push branch, create or update PR, link PR to story
  packet
- `harness-git-pull/SKILL.md` — sync with `origin/main`, record result in workpad
  Notes
- `harness-git-land/SKILL.md` — safe merge after approval, with branch-protection
  detection

Skills cross-reference each other: `harness-git-push` calls `harness-git-pull` on
rejection; `harness-git-land` calls `harness-git-push` and checks CI before merging.

## Product Sources

No product contract is currently defined.

When a user provides a project specification, add or reference it as the input
spec for the first buildout, then derive smaller living artifacts from it:

- `docs/product/`: current product contract files, created from the spec.
- `docs/stories/`: story packets and backlog created from selected work.
- `docs/TEST_MATRIX.md`: behavior-to-proof control panel.
- `docs/decisions/`: durable decisions and tradeoffs.

Do not keep a project-specific spec or product breakdown in this harness until
a real project supplies one.

## Harness Sources

- `CLAUDE.md`: agent entrypoint, source-of-truth hierarchy, and task loop.
- `docs/HARNESS.md`: human-agent collaboration model, execution phase, state
  machine, default posture, and growth rule.
- `docs/FEATURE_INTAKE.md`: tiny, normal, and high-risk work classification.
- `docs/ARCHITECTURE.md`: generic architecture discovery and boundary rules.
- `docs/HARNESS_BACKLOG.md`: proposed harness improvements.
- `docs/templates/`: reusable spec-intake, story, workpad, decision, and
  validation templates.
- `.claude/skills/`: skill contracts — `harness-intake` plus the `harness-git-*`
  (commit, push, pull, land) git workflow set.
- `scripts/`: `validate.sh` (validation-ladder runner), `harness-check.sh`
  (zero-product self-check), `new-story.sh` (packet scaffolder), `install-harness.sh`.
- `.harness/`: project-owned validation hooks (`<rung>` + `*.example` templates).

## Repository Structure

```text
project/
  CLAUDE.md                          agent entrypoint and operating rules
  README.md
  .claude/
    skills/
      harness-intake/SKILL.md        feature intake and lane classification
      harness-git-commit/SKILL.md    conventional commit skill
      harness-git-push/SKILL.md      push + PR skill
      harness-git-pull/SKILL.md      sync with main skill
      harness-git-land/SKILL.md      safe merge skill
  .harness/                          project-owned validation hooks
    README.md
    quick.example                    hook templates per ladder rung
    integration.example
    e2e.example
    platform.example
    release.example
    deviation-scan.example           opt-in plan-deviation marker gate
  docs/
    HARNESS.md                       full operating model
    FEATURE_INTAKE.md                work classification and risk lanes
    ARCHITECTURE.md                  architecture discovery rules
    TEST_MATRIX.md                   behavior-to-proof control panel
    HARNESS_BACKLOG.md               proposed harness improvements
    GLOSSARY.md
    ADOPTION.md
    product/
    stories/                         story packets and workpad siblings
    decisions/                       architecture decision records
    demo/
    templates/
      story.md                       normal-lane story packet template
      story.workpad.md               normal-lane workpad sibling template
      high-risk-story/               multi-file bundle for high-risk work
        execplan.md
        workpad.md
        overview.md
        design.md
        validation.md
      decision.md
      spec-intake.md
      validation-report.md
  scripts/
    validate.sh                      validation-ladder runner (dispatches to .harness/<rung>)
    harness-check.sh                 zero-product harness self-check (validate:quick base)
    new-story.sh                     scaffold a story packet from templates
    install-harness.sh
    README.md
```

## Working Rule

Implementation prompts do not go straight to code. They first pass through
feature intake, become story-sized work when needed, and then carry product
validation, execution state, and harness maintenance expectations.

## Install Harness Into A Project

From a target project directory, run:

```bash
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

If the target already has `CLAUDE.md`, `docs/`, or `scripts/`, choose one:

```bash
# Keep existing files and add only missing Harness files
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes

# Back up and replace CLAUDE.md, docs/, and scripts/
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --override --yes
```

Or install into a specific path:

```bash
curl -fsSL "https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --directory /path/to/project --yes
```

If the target already contains `CLAUDE.md`, `docs/`, or `scripts/`, interactive
installs ask whether to `1. Merge`, `2. Override`, or `3. Stop`. Non-interactive
installs using `--yes` stop before writing unless `--merge` or `--override` is
provided. Use `--dry-run` to preview changes. The installer itself and this
repository's installer story are not copied into the target project.
