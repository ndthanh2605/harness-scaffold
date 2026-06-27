#!/usr/bin/env bash
#
# validate.sh — language-agnostic validation runner for the harness.
#
# Ships the validation MECHANISM, never the policy. Each rung maps to a
# project-owned hook at `.harness/<rung>`; the scaffold ships `.harness/*.example`
# templates. An installed project copies an example to the real name and fills in
# its own commands, in any language — no edits to this script.
#
# Usage: validate.sh <rung>
#   rungs: quick | integration | e2e | platform | release
#
# Rung semantics:
#   quick        always runs scripts/harness-check.sh (the zero-product base),
#                then `.harness/quick` if it exists. A harness-only repo passes
#                on harness-check alone.
#   other rungs  run `.harness/<rung>` if present and executable; its exit code is
#                the result. If the hook is absent the rung is "not configured"
#                and FAILS (exit non-zero) — never a false green. A hook may opt
#                out by printing `skip` as its only output (treated as pass).
#
# This is harness automation, not application code, and an unconfigured rung is
# honest (non-zero), so it does not violate the "no fake validation" rule in
# scripts/README.md.
#
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VALID_RUNGS="quick integration e2e platform release"

log()  { printf '%s\n' "$*"; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

run_hook() {  # $1 = rung; returns hook exit code, or 127 if the hook is absent
  local rung="$1" hook=".harness/$1" out rc
  [ -f "$hook" ] || return 127
  [ -x "$hook" ] || fail "hook '$hook' exists but is not executable (chmod +x $hook)"
  log "=== .harness/$rung ==="
  # Run once; capture so a single-line `skip` sentinel can opt out.
  out="$("$hook" 2>&1)"; rc=$?
  if [ "$(printf '%s' "$out" | tr -d '[:space:]')" = "skip" ]; then
    log "skip: rung '$rung' opted out by its hook"
    return 0
  fi
  printf '%s\n' "$out"
  return "$rc"
}

rung="${1:-}"
[ -n "$rung" ] || fail "usage: validate.sh <$(printf '%s' "$VALID_RUNGS" | tr ' ' '|')>"
printf '%s' "$VALID_RUNGS" | tr ' ' '\n' | grep -qx "$rung" \
  || fail "unknown rung '$rung' (expected one of: $VALID_RUNGS)"

if [ "$rung" = "quick" ]; then
  log "=== harness-check (base) ==="
  bash scripts/harness-check.sh || fail "harness-check failed"
  if [ -f ".harness/quick" ]; then
    run_hook quick || fail "rung 'quick' failed"
  else
    log "note: no .harness/quick hook — quick = harness-check only (harness-only repo)."
  fi
  log ""
  log "=== validate:quick passed ==="
  exit 0
fi

# Non-quick rungs are pure project hooks.
if run_hook "$rung"; then
  log ""
  log "=== validate:$rung passed ==="
  exit 0
else
  rc=$?
  if [ "$rc" -eq 127 ]; then
    fail "rung '$rung' is not configured — add an executable .harness/$rung hook (see .harness/$rung.example), or it cannot be claimed as passing."
  fi
  fail "rung '$rung' failed (hook exit $rc)"
fi
