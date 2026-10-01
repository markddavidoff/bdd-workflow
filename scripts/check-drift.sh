#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
# Snapshot the current generated tree, regenerate, and diff.
cp -R plugins "$tmp/before" 2>/dev/null || true
bash scripts/sync-skills.sh >/dev/null
if ! diff -r "$tmp/before" plugins >/dev/null 2>&1; then
  echo "DRIFT: plugins/*/skills is out of sync with canonical skills/. Run 'make sync' and commit." >&2
  diff -r "$tmp/before" plugins >&2 || true
  exit 1
fi
echo "no drift"
