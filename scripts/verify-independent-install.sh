#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.."; pwd)"
CFG="$(mktemp -d)"; export CLAUDE_CONFIG_DIR="$CFG"
trap 'rm -rf "$CFG"' EXIT
echo "isolated CLAUDE_CONFIG_DIR=$CFG (real ~/.claude untouched)"
claude plugin marketplace add "$REPO" >/dev/null
fail=0
for p in bdd-flow bdd-knowledge-base bdd-scaffold spec-personas; do
  claude plugin install "$p@bdd-workflow" >/dev/null 2>&1 || { echo "FAIL install $p"; fail=1; continue; }
  if find "$CFG" -path "*$p*/SKILL.md" | grep -q .; then echo "OK   $p resolves non-empty"; else echo "FAIL $p empty"; fail=1; fi
  claude plugin uninstall "$p@bdd-workflow" >/dev/null 2>&1 || true
done
exit "$fail"
