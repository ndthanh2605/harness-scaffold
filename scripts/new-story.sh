#!/usr/bin/env bash
#
# new-story.sh — scaffold a story packet from the templates in docs/templates/.
#
# Usage: new-story.sh <US-ID> <slug> [--high-risk]
#   normal lane (default): docs/stories/<US-ID>-<slug>.md  + <...>.workpad.md
#   --high-risk         : docs/stories/<US-ID>-<slug>/ bundle (overview, design,
#                         execplan, validation, workpad)
#
# Pure file operations — language-agnostic. The "US-XXX" placeholder in the
# templates is substituted with the real ID. Refuses to overwrite existing files.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

log()  { printf '%s\n' "$*"; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

ID="" SLUG="" HIGH_RISK=0
for arg in "$@"; do
  case "$arg" in
    --high-risk) HIGH_RISK=1 ;;
    -h|--help)   sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          fail "unknown option '$arg'" ;;
    *) if [ -z "$ID" ]; then ID="$arg"; elif [ -z "$SLUG" ]; then SLUG="$arg"; else fail "unexpected argument '$arg'"; fi ;;
  esac
done

[ -n "$ID" ] && [ -n "$SLUG" ] || fail "usage: new-story.sh <US-ID> <slug> [--high-risk]"
printf '%s' "$ID"   | grep -qE '^[A-Za-z]+-[0-9]+$' || fail "ID '$ID' should look like US-001"
printf '%s' "$SLUG" | grep -qE '^[a-z0-9-]+$'       || fail "slug '$SLUG' should be kebab-case (a-z, 0-9, -)"

# Title Case the slug for the heading, e.g. install-harness -> Install Harness.
title="$(printf '%s' "$SLUG" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}; print}')"

# Copy a template into place with US-XXX substituted, refusing to clobber.
emit() {  # $1 = template path, $2 = destination path
  [ -f "$1" ] || fail "template '$1' not found"
  [ -e "$2" ] && fail "refusing to overwrite existing '$2'"
  sed -e "s/US-XXX/${ID}/g" "$1" > "$2"
  log "created $2"
}

if [ "$HIGH_RISK" -eq 1 ]; then
  dir="docs/stories/${ID}-${SLUG}"
  [ -e "$dir" ] && fail "refusing to overwrite existing '$dir'"
  mkdir -p "$dir"
  for part in overview design execplan validation workpad; do
    emit "docs/templates/high-risk-story/${part}.md" "${dir}/${part}.md"
  done
  # Set the execplan heading to something meaningful.
  sed -i "1s|.*|# ${ID} ${title} — Exec Plan|" "${dir}/execplan.md"
  log ""
  log "High-risk story bundle ready at ${dir}/ (fill in overview/design/execplan/validation, set Status when work starts)."
else
  story="docs/stories/${ID}-${SLUG}.md"
  workpad="docs/stories/${ID}-${SLUG}.workpad.md"
  emit "docs/templates/story.md"          "$story"
  emit "docs/templates/story.workpad.md"  "$workpad"
  sed -i "1s|.*|# ${ID} ${title}|" "$story"
  log ""
  log "Story ready at ${story} (+ workpad). Set Status to in_progress when work starts."
fi
