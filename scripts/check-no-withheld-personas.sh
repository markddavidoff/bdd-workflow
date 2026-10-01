#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# CR3 gate: the withheld recruiting/nonprofit personas and their taxonomy must not ship.
# Scans ALL shipped content (skills, plugins incl. agents+personas, schemas, fixtures).
#
# The literal taxonomy lives ONLY in the PRIVATE, gitignored scripts/.withheld-personas-blocklist,
# so this public script never enumerates the withheld client-derived terms. Absent that file (e.g.
# public CI, where nothing private can leak), the scan is skipped — it guards the pre-publish workflow.
BLFILE="${WITHHELD_BLOCKLIST_FILE:-scripts/.withheld-personas-blocklist}"
if [ ! -f "$BLFILE" ]; then
  echo "no private withheld-personas blocklist ($BLFILE) — skipping withheld-taxonomy scan"
  exit 0
fi
BLOCK="$(tr -d '\n' < "$BLFILE")"
if [ -z "$BLOCK" ]; then echo "empty blocklist ($BLFILE)" >&2; exit 1; fi
if grep -rniE "$BLOCK" skills plugins schemas fixtures 2>/dev/null; then
  echo "FAIL: withheld recruiting/nonprofit persona taxonomy found in shipped content" >&2
  exit 1
fi
echo "no withheld persona taxonomy"
