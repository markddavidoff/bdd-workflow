#!/usr/bin/env bash
# Tier-1 E2E: install all 4 plugins from the LOCAL marketplace into an isolated
# CLAUDE_CONFIG_DIR and assert each loads enabled with its skills discoverable. No agent
# turn, no API key -> deterministic + CI-gateable. The real ~/.claude is never touched.
#
# CLI shapes this asserts against (verified 2026-09-28, CLI 2.1.x):
#   claude plugin list --json  -> [{ "id": "<name>@<marketplace>", "enabled": true, ... }]
#   claude plugin details <id> -> plain text incl. "  Skills (N)  ..." and "  Hooks (N)  SessionStart"
#   (details has no --json; list has no .name — the id carries name@marketplace)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
MARKET="bdd-workflow"
PLUGINS="bdd-flow bdd-knowledge-base spec-personas bdd-scaffold"

command -v jq >/dev/null || { echo "FAIL: jq is required" >&2; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export CLAUDE_CONFIG_DIR="$TMP/cfg"; mkdir -p "$CLAUDE_CONFIG_DIR"

claude plugin marketplace add "$REPO" >/dev/null

for p in $PLUGINS; do
  # --json + </dev/null: a command-acceptance prompt fails fast rather than hanging.
  out="$(claude plugin install "$p@$MARKET" --json </dev/null)"
  echo "$out" | jq -e '.outcome=="ok"' >/dev/null \
    || { echo "FAIL: install of $p did not report ok: $out" >&2; exit 1; }
done

installed="$(claude plugin list --json)"
for p in $PLUGINS; do
  echo "$installed" | jq -e --arg id "$p@$MARKET" \
    'any(.[]?; .id==$id and .enabled==true)' >/dev/null \
    || { echo "FAIL: $p not installed+enabled" >&2; exit 1; }
  # Skills discoverable in the component inventory: "  Skills (N)  ..." with N>=1.
  claude plugin details "$p@$MARKET" | grep -Eq 'Skills \([1-9][0-9]*\)' \
    || { echo "FAIL: $p exposes no discoverable skills" >&2; exit 1; }
done

# KB SessionStart hook registered (drives the KB fetch on session start).
claude plugin details "bdd-knowledge-base@$MARKET" | grep -q 'SessionStart' \
  || { echo "FAIL: bdd-knowledge-base SessionStart hook not registered" >&2; exit 1; }

echo "OK: 4 plugins installed + enabled, skills discoverable, KB SessionStart present."
