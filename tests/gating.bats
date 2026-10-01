#!/usr/bin/env bats

SKILL=skills/bdd-feature-sync/SKILL.md

@test "description gates on BDD setup while keeping breadth" {
  run grep -qi 'configured for BDD' "$SKILL"; [ "$status" -eq 0 ]
  run grep -qi 'no BDD setup' "$SKILL"; [ "$status" -eq 0 ]
  run grep -qi 'add a feature' "$SKILL"; [ "$status" -eq 0 ]   # breadth preserved
}

@test "skill body has a fail-closed Step 0 gate" {
  run grep -qi 'fail-closed' "$SKILL"; [ "$status" -eq 0 ]
  run grep -qi 'Step 0' "$SKILL"; [ "$status" -eq 0 ]
  run grep -qi '\.bdd\.json' "$SKILL"; [ "$status" -eq 0 ]              # gate is file-presence
  run grep -qiE 'produce no output|stop\.' "$SKILL"; [ "$status" -eq 0 ]  # hard stop, not soft
}

@test "the plugin copy of bdd-feature-sync matches canonical (drift-synced)" {
  run diff -q skills/bdd-feature-sync/SKILL.md plugins/bdd-flow/skills/bdd-feature-sync/SKILL.md
  [ "$status" -eq 0 ]
}
