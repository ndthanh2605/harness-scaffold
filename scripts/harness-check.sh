#!/usr/bin/env bash
#
# harness-check.sh — language-agnostic harness self-check (doc-lint).
#
# Validates the harness's OWN artifacts (stories, workpads, decisions, the test
# matrix). It needs zero product code, so it is the always-on base of
# `validate.sh quick` and gives a harness-only repo a real, green validation rung.
#
# Exit 0 = clean. Non-zero = one or more violations (all are reported, not just
# the first). It is strict on core invariants and lenient on optional/newer
# sections (checked only when present) so it stays green on pre-existing stories.
#
set -uo pipefail   # deliberately not -e: collect every violation before exiting

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VALID_STATUS_RE='^(todo|in_progress|human_review|merging|rework|done|blocked)$'
violations=0

viol() { printf 'FAIL: %s\n' "$*" >&2; violations=$((violations + 1)); }
ok()   { printf 'ok: %s\n' "$*"; }

# First non-empty token after a '## Status' heading, whitespace-stripped.
field_status() {
  awk '/^## Status/{f=1; next} f && NF {print; exit}' "$1" | tr -d '[:space:]'
}

# --- Collect story packets, excluding index files and workpad siblings ---------
mapfile -t normal_stories < <(find docs/stories -maxdepth 1 -name 'US-*.md' ! -name '*.workpad.md' 2>/dev/null | sort)
mapfile -t hr_execplans  < <(find docs/stories -mindepth 2 -name 'execplan.md' 2>/dev/null | sort)

packet_count=$(( ${#normal_stories[@]} + ${#hr_execplans[@]} ))

# --- Check one story packet ----------------------------------------------------
# $1 = packet file, $2 = workpad path, $3 = require_ac (1 for normal-lane story.md;
# 0 for high-risk execplan.md, whose acceptance criteria live in the workpad).
check_packet() {
  local f="$1" workpad="$2" require_ac="$3" st
  [ -f "$f" ] || return 0

  grep -qE '^## Status' "$f" || viol "$f: missing '## Status'"
  if [ "$require_ac" -eq 1 ]; then
    grep -qE '^## Acceptance Criteria' "$f" || viol "$f: missing '## Acceptance Criteria'"
  fi

  st="$(field_status "$f")"
  if [ -z "$st" ]; then
    viol "$f: '## Status' has no value"
  elif ! printf '%s' "$st" | grep -qE "$VALID_STATUS_RE"; then
    viol "$f: invalid status '$st'"
  fi

  # Workpad sibling is required only while a story is in_progress.
  if [ "$st" = "in_progress" ] && [ ! -f "$workpad" ]; then
    viol "$f: status is in_progress but workpad '$workpad' is missing"
  fi

  # Declared Files fence, if present, must be closed (lenient — optional section).
  # Track the 'files' fence specifically: counting all bare ``` closings would be
  # fooled by other code blocks (```bash, etc.) and miss a genuinely open fence.
  if grep -qE '^```files' "$f"; then
    awk '
      /^```files/       { infiles=1; next }
      infiles && /^```/ { infiles=0; next }
      END               { exit infiles }
    ' "$f" || viol "$f: a '\`\`\`files' fence is not closed"
  fi

  # A done story must not carry an unratified (open) deviation in its workpad.
  # A real entry reads "(status: open)"; the template placeholder reads
  # "(status: open | ratified)". Anchor on the closing paren so only genuine open
  # entries match — not the placeholder (the ' |' after open defeats the '\)').
  if [ "$st" = "done" ] && [ -f "$workpad" ]; then
    if grep -qiE 'status:[[:space:]]*open[[:space:]]*\)' "$workpad"; then
      viol "$workpad: a '## Deviations' entry is still open on a done story"
    fi
  fi
}

for f in "${normal_stories[@]:-}"; do
  [ -n "$f" ] || continue
  check_packet "$f" "${f%.md}.workpad.md" 1
done
for f in "${hr_execplans[@]:-}"; do
  [ -n "$f" ] || continue
  check_packet "$f" "$(dirname "$f")/workpad.md" 0
done

# --- Decision records referenced in HARNESS.md must exist ----------------------
if [ -f docs/HARNESS.md ]; then
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    [ -f "$ref" ] || viol "docs/HARNESS.md references missing decision record '$ref'"
  done < <(grep -oE 'docs/decisions/[0-9]{4}-[a-z0-9-]+\.md' docs/HARNESS.md | sort -u)
fi

# --- Test matrix shape ---------------------------------------------------------
if [ -f docs/TEST_MATRIX.md ]; then
  grep -qE '^## Matrix'                 docs/TEST_MATRIX.md || viol "docs/TEST_MATRIX.md: missing '## Matrix' section"
  grep -qE '^\| Story \| Contract \|'   docs/TEST_MATRIX.md || viol "docs/TEST_MATRIX.md: matrix header row not found"
fi

# --- Report --------------------------------------------------------------------
printf '\n'
if [ "$violations" -eq 0 ]; then
  ok "harness-check passed — $packet_count story packet(s) validated, no violations."
  exit 0
fi
printf 'harness-check FAILED with %d violation(s).\n' "$violations" >&2
exit 1
