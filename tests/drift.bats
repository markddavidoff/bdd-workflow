#!/usr/bin/env bats

setup() { make sync >/dev/null; }

@test "clean tree reports no drift" {
  run bash scripts/check-drift.sh
  [ "$status" -eq 0 ]
}

@test "hand-edit to a generated copy is caught" {
  echo "tampered" >> plugins/bdd-knowledge-base/skills/bdd-kb/SKILL.md
  run bash scripts/check-drift.sh
  [ "$status" -eq 1 ]
  make sync >/dev/null   # restore
}
