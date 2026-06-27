# `.harness/` — project validation hooks

The harness ships a language-agnostic runner (`scripts/validate.sh`) but **no
tool-specific commands**. Each validation rung maps to one executable hook in this
directory. This is how the generic scaffold adapts to any stack (Node, Python,
Rust, Go, …) without editing harness scripts.

## How it works

`scripts/validate.sh <rung>` runs `.harness/<rung>` if it exists and is
executable; the hook's exit code is the rung's result. Rungs:

| Rung | Meaning |
| --- | --- |
| `quick` | format, lint, typecheck, unit tests, architecture check |
| `integration` | backend / database / provider / service checks |
| `e2e` | user-visible end-to-end flows |
| `platform` | shell / desktop / mobile / deployment smoke |
| `release` | full suite, log checks, performance smoke |

`quick` is special: it **always** runs `scripts/harness-check.sh` first (the
harness self-check, which needs no product code), then your `.harness/quick` hook
if present. A harness-only repo therefore passes `quick` with no hook at all.

## The honest-unconfigured rule

A rung whose hook is **absent fails** (`validate.sh <rung>` exits non-zero) — it is
never falsely green. This is deliberate: an agent must not claim a rung passes
before it exists. To deliberately opt a rung out (genuinely not applicable to this
project), make its hook print `skip` as its only output and exit 0.

## Setup

Copy the example for each rung you want and make it executable:

```bash
cp .harness/quick.example .harness/quick
chmod +x .harness/quick
$EDITOR .harness/quick    # replace the sample commands with your stack's
```

Commit your real hooks — they are project policy. The `*.example` files are
shipped by the scaffold and are safe to keep alongside your real hooks; a
re-install never overwrites a hook you have created.

## Optional: plan-deviation marker gate

`deviation-scan.example` is an opt-in, language-agnostic check that enforces the
Plan Deviation Protocol (`docs/HARNESS.md`) mechanically: it fails on workaround
markers added without a `DEVIATION:` annotation and on new source files missing
from the active story's `## Declared Files`. Configure its source globs at the top
of the file, then call it from your `quick` hook if you want it.
