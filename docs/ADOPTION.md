# Harness Adoption Guide

This guide covers how to bring the harness into a project — both projects starting from
nothing (greenfield) and projects with existing code and conventions (brownfield). The two
paths are meaningfully different and are documented separately.

Read `docs/HARNESS.md` for the operating model this guide assumes. Read
`docs/FEATURE_INTAKE.md` before running any work through the harness.

---

## Part 1: Greenfield Projects

A greenfield project has a fresh repo — typically nothing beyond a `git init` and maybe a
README. The harness installs without conflict and shapes the project from day one.

### Step 1: Install the harness

Run the installer against your new project directory:

```bash
# From within the project directory:
curl -fsSL https://raw.githubusercontent.com/ndthanh2605/harness-scaffold/main/scripts/install-harness.sh \
  | bash -s -- --yes

# Or clone harness-experimental and run locally:
bash /path/to/harness-experimental/scripts/install-harness.sh --directory /path/to/project --yes
```

The installer copies the harness file manifest — `CLAUDE.md`, `HARNESS.md`,
`FEATURE_INTAKE.md`, story templates, decision templates, `.claude/skills/`, and more — into
your project. It does not scaffold app code, package configs, or CI. Those arrive only when
a story needs them.

After install, commit the harness baseline:

```bash
git add -A
git commit -m "chore: install harness v0"
```

### Step 2: Orient — read the three files

Before writing any code or spec, read in this order:

1. `CLAUDE.md` — the agent entrypoint. This is what every agent reads first.
2. `docs/HARNESS.md` — the operating model: what the harness does, how work flows, the
   execution state machine, and the growth rule.
3. `docs/FEATURE_INTAKE.md` — the gate every task passes through before implementation.

This takes 10 minutes. It prevents the next 10 hours of confusion.

### Step 3: Write your initial spec

The spec is your job, not the harness's. Write what the product does — user-facing behaviors,
not implementation decisions. It can be rough; the harness will process it.

The spec does **not** live permanently in the repo. Treat it as input material that gets
decomposed into product docs, stories, and decisions. After decomposition, stop extending the
spec — extend the product docs instead.

A useful spec answers:
- Who uses this product and what do they want to accomplish?
- What are the 3–5 core behaviors the product must have on day one?
- What are the hard constraints (platform, compliance, latency, data model)?

Save it anywhere for now (even a scratch file). It enters the harness in the next step.

### Step 4: Run intake — turn the spec into harness artifacts

Open a Claude Code session in the project directory and provide your spec. The agent will:

1. Classify it as a **New spec** input type (see `docs/FEATURE_INTAKE.md`).
2. Create product doc stubs in `docs/product/` — one file per product domain.
3. Identify candidate story slices.
4. Propose an initial `docs/decisions/0001-*.md` for any architecture choices already made
   (language, framework, data store, deployment target).

You do not need to get this perfect. Product docs grow and correct themselves as stories are
executed. The goal of the first intake pass is to have something concrete to work from, not
a complete specification.

### Step 5: Create your first story

Pick the smallest behavior from the spec that delivers visible value. Create a story packet
from the template:

```bash
cp docs/templates/story.md docs/stories/US-001-<short-name>.md
```

Fill in:
- **Status**: `todo`
- **Lane**: run the risk checklist in `docs/FEATURE_INTAKE.md` — most first stories are
  `normal`, but auth or data-model work is `high-risk`
- **Product Contract**: which `docs/product/*.md` file governs this behavior
- **Acceptance Criteria**: 2–5 concrete, testable conditions
- **Validation**: what command will prove it works

Add a row to `docs/TEST_MATRIX.md` for this story.

### Step 6: Execute the story

When you're ready to implement, hand the story to Claude Code (or dispatch via
`opencode-dispatch`). The agent will:

1. Create a workpad sibling (`docs/stories/US-001-<name>.workpad.md`) from the template.
2. Run the `pull` skill to sync the branch.
3. Work through the implementation, updating the workpad's Plan and Notes throughout.
4. Transition the story status through the state machine as gates are met.
5. Advance to `human_review` when the PR is ready and validation is green.

You review, approve or give feedback, and the story lands.

### Greenfield operating rhythm

After the first story, the rhythm becomes:

```
new intent → intake → story packet → execution → review → merge → next
```

Every two or three stories, check whether the harness needs to grow: did an agent repeat
manual reasoning that should be a template? Did a validation command get invented three times
that should be in the matrix? That friction belongs in `docs/HARNESS_BACKLOG.md`.

---

## Part 2: Brownfield Projects

A brownfield project has existing code, existing conventions, and possibly existing docs,
`CLAUDE.md`, or agent config. The harness needs to fit alongside what already works —
not replace it wholesale.

**The key insight:** the harness governs future work, not past work. Do not audit your
existing codebase or try to retroactively story-ize everything. Start using the harness for
new work and let it grow naturally.

### Step 1: Audit conflicts before installing

Run a dry-run to see what the installer would change:

```bash
bash /path/to/harness-experimental/scripts/install-harness.sh \
  --directory /path/to/project --dry-run
```

Review the output for:

| Conflict type | Risk | Action |
|---------------|------|--------|
| `CLAUDE.md` exists | High — harness will overwrite it | Back it up first; merge manually after install |
| `docs/` exists | Low — `--merge` installs only missing files | Use `--merge`; existing docs are untouched |
| `scripts/` exists | Low | Protected; `--merge` skips conflicts |
| `.claude/skills/` exists | Low | Installer adds new files only |

### Step 2: Install with the right flags

**Safest for most brownfield projects:**

```bash
bash /path/to/harness-experimental/scripts/install-harness.sh \
  --directory /path/to/project --merge --yes
```

`--merge` keeps all existing protected files (`CLAUDE.md`, `docs/`, `scripts/`) and installs
only the harness files that are missing. Your existing docs are preserved.

**If you want the full harness structure and are willing to merge manually:**

```bash
# Back up first
cp -r /path/to/project /tmp/project-backup-$(date +%Y%m%d)

bash /path/to/harness-experimental/scripts/install-harness.sh \
  --directory /path/to/project --override --yes
```

`--override` backs up and replaces protected files, then installs everything. You will need
to re-apply your project's existing conventions manually afterward.

### Step 3: Integrate CLAUDE.md

If your project had a `CLAUDE.md` before install (or you used `--merge` and it wasn't
replaced), you now need to merge the harness instructions with your existing rules.

Open the new `CLAUDE.md` (installed by the harness) and your backup. Merge them:

1. Keep the harness **Source Of Truth** list (items 1–10). Add any project-specific sources
   below item 10.
2. Keep the harness **Task Loop** checklist. Add project-specific checklist items after the
   harness ones.
3. Keep the harness **Harness Change Policy** and **Done Definition** sections verbatim —
   these are the behavioral contracts agents rely on.
4. Append any existing project-specific rules in a clearly labelled section at the bottom:

   ```markdown
   ## Project-Specific Rules

   [your existing CLAUDE.md content here]
   ```

5. Review for conflicts: if your existing rules contradict the harness (e.g., a different
   commit format), decide which wins and document the decision in `docs/decisions/`.

### Step 4: Map existing work — do the minimum

Resist the urge to audit everything. Do only this:

**In-flight work (being actively developed):**
- Create a story packet for each active work stream
- Set `Status: in_progress`
- Fill in AC and Validation based on what you already know
- Create a workpad sibling and note current state in Notes

**Planned future work:**
- Create story packets at `Status: todo`
- This is the work the harness will govern going forward

**Completed past work:**
- Leave it alone. Do not create stories for code that is already shipped and stable.
- Exception: if a past architectural decision is still load-bearing and agents need to know
  about it, write a brief ADR in `docs/decisions/`.

**TEST_MATRIX:**
- Do not audit existing tests into the matrix all at once.
- Add rows only as you create new stories or touch existing behaviors.

### Step 5: Retroactive ADRs — only what agents need

Look at your project's most important past decisions: the ones an agent would make wrong
without knowing about them. Common examples:

- Why a non-obvious framework or library was chosen
- Why a data model is shaped a certain unusual way
- Why an API contract diverges from a standard convention
- Why a security decision was made a certain way

Write an ADR for each one that still shapes future work. Use `docs/templates/decision.md`.
Number them starting from `0001`. The goal is not completeness — it is preventing agents
from undoing deliberate choices.

A useful test: "If a new agent saw only the code and not this ADR, would it make a costly
mistake?" If yes, write the ADR. If no, skip it.

### Step 6: Run your first intake

Pick the next piece of planned work and run it through `docs/FEATURE_INTAKE.md` as if the
harness had always been there. Classify it, create a story packet, run the risk checklist.

This is the moment the harness becomes real. The first intake pass reveals whether your
product docs are good enough to anchor a story. If they aren't — and for most brownfield
projects they won't be yet — the intake will surface what's missing. That's the friction the
harness is designed to catch.

### Step 7: Stabilization — expect friction for 2–4 stories

The first few stories through a brownfield harness will feel slower than before. This is
normal. The harness is learning the shape of your project:

- Agents will find gaps in the product docs — fill them.
- Risk classifications will feel off at first — adjust the intake notes.
- Existing conventions (commit format, branch naming, test structure) may conflict with
  harness defaults — document the winning convention in `CLAUDE.md` or a decision record.

After 2–4 stories, the friction drops sharply. The harness has enough context to operate
autonomously on routine work.

**Do not skip this friction.** The `docs/HARNESS_BACKLOG.md` file exists precisely to
capture it. Agents should be adding items there when they hit repeated confusion.

---

## Shared Checkpoints

Regardless of greenfield or brownfield, the harness is working when:

- [ ] Every new task is classified via `docs/FEATURE_INTAKE.md` before implementation starts
- [ ] Story packets are created before implementation, not after
- [ ] `docs/TEST_MATRIX.md` has a row for every story
- [ ] Agents update the workpad throughout execution, not just at the end
- [ ] Story status transitions happen at real gates, not optimistically
- [ ] `docs/HARNESS_BACKLOG.md` grows with friction — agents are noticing and capturing it
- [ ] `docs/decisions/` grows when architecture changes — not every change, just the load-bearing ones

If any of these are consistently skipped, the harness is being bypassed. Investigate why —
usually it means a template is unclear, a rule is missing from `CLAUDE.md`, or a lane
boundary is wrong for the project.
