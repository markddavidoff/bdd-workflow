#!/usr/bin/env bash
# M6 corpus-scrub: no proprietary blocklist token and no `issue #NN` reference in committed evals.
set -euo pipefail
cd "$(dirname "$0")/.."
# Default: every eval tree (cases live under each plugin). An explicit arg overrides (for tests).
if [ $# -gt 0 ]; then
  targets=("$1")
else
  targets=()
  for d in plugins/*/evals evals; do [ -d "$d" ] && targets+=("$d"); done
fi
[ "${#targets[@]}" -gt 0 ] || { echo "no evals tree — nothing to scrub"; exit 0; }

# Proprietary tokens come from the PRIVATE, gitignored scripts/.domain-blocklist so this public
# script never enumerates the private project names. Absent it (public CI), skip the token scan and
# still run the generic issue-reference scan below.
BLFILE="${DOMAIN_BLOCKLIST_FILE:-scripts/.domain-blocklist}"
if [ -f "$BLFILE" ]; then
  blocklist="$(tr -d '\n' < "$BLFILE")"
  if [ -n "$blocklist" ] && grep -rInE --exclude-dir=__pycache__ --exclude-dir=results --exclude='*.pyc' "$blocklist" "${targets[@]}" 2>/dev/null; then
    echo "FAIL: proprietary blocklist token found in ${targets[*]}" >&2; exit 1
  fi
fi
if grep -rInE --exclude-dir=__pycache__ --exclude-dir=results --exclude='*.pyc' 'issue #[0-9]+' "${targets[@]}" 2>/dev/null; then
  echo "FAIL: issue reference found in ${targets[*]} (corpus must not name private issues)" >&2; exit 1
fi
echo "corpus clean (${targets[*]})"
