#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# plugin:skill,skill,...  — canonical skills/ is the single source of truth.
MAP=(
  "bdd-flow:bdd-feature-sync,e2e-test-generation"
  "bdd-knowledge-base:bdd-kb,bdd-tutorial"
  "spec-personas:spec-review,persona-manager,persona-moa-synthesis,moa-synthesis"
  "bdd-scaffold:bdd-scaffold"
)

for entry in "${MAP[@]}"; do
  plugin="${entry%%:*}"; skills="${entry#*:}"
  dest="plugins/$plugin/skills"
  rm -rf "$dest"; mkdir -p "$dest"
  IFS=',' read -ra list <<< "$skills"
  for s in "${list[@]}"; do
    cp -R "skills/$s" "$dest/$s"
  done
done
echo "synced $(printf '%s ' "${MAP[@]}")"
