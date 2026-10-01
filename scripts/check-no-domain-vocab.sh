#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# CR1 gate: no proprietary domain vocabulary from the private proving projects may ship.
# Scans ALL shipped content (skills, plugins incl. agents+personas, schemas, fixtures) —
# NOT just agents/ (the base de-leak guard's false-green that made CR1 critical).
#
# The literal codenames/fingerprints live only in the PRIVATE, gitignored scripts/.domain-blocklist,
# so this public script never enumerates the private project names. Absent that file (e.g. public
# CI, where nothing private can leak), the scan is skipped — it guards the pre-publish workflow.
BLFILE="${DOMAIN_BLOCKLIST_FILE:-scripts/.domain-blocklist}"
if [ ! -f "$BLFILE" ]; then
  echo "no private domain blocklist ($BLFILE) — skipping proprietary-vocab scan"
  exit 0
fi
BLOCK="$(tr -d '\n' < "$BLFILE")"
if [ -z "$BLOCK" ]; then echo "empty blocklist ($BLFILE)" >&2; exit 1; fi
if grep -rnE "$BLOCK" skills plugins schemas fixtures 2>/dev/null; then
  echo "FAIL: proprietary domain vocabulary found in shipped content" >&2
  exit 1
fi
echo "no domain vocab"
