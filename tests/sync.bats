#!/usr/bin/env bats

@test "make sync generates all plugin skill copies" {
  make sync >/dev/null
  [ -f plugins/bdd-knowledge-base/skills/bdd-kb/SKILL.md ]
  [ -f plugins/bdd-flow/skills/bdd-feature-sync/SKILL.md ]
  [ -f plugins/bdd-flow/skills/e2e-test-generation/SKILL.md ]
  [ -f plugins/spec-personas/skills/spec-review/SKILL.md ]
  [ -f plugins/spec-personas/skills/persona-manager/SKILL.md ]
  [ -f plugins/bdd-scaffold/skills/bdd-scaffold/SKILL.md ]
}

@test "generated copy is byte-identical to canonical" {
  make sync >/dev/null
  run diff -q skills/bdd-kb/SKILL.md plugins/bdd-knowledge-base/skills/bdd-kb/SKILL.md
  [ "$status" -eq 0 ]
}
