#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Search shipped content (skills, agents, personas, manifests, schemas, fixtures) AND the
# public docs/ + NOTICE — docs were previously unguarded and leaked a private ~/work path.
if grep -rnE --exclude-dir=__pycache__ --exclude-dir=results --exclude='*.pyc' '(/Users/|/home/|~/work/)' skills plugins schemas fixtures .claude-plugin docs NOTICE 2>/dev/null; then
  echo "FAIL: absolute or ~ paths found in shipped content" >&2
  exit 1
fi
echo "no absolute paths"
