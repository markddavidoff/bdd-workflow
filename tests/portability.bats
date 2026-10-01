#!/usr/bin/env bats

DOC=docs/PORTABILITY.md

@test "PORTABILITY.md exists" {
  [ -f "$DOC" ]
}

@test "states what is portable (methodology, KB, .bdd.json schema)" {
  run grep -qi 'portable' "$DOC"; [ "$status" -eq 0 ]
  run grep -q '\.bdd\.json' "$DOC"; [ "$status" -eq 0 ]
}

@test "states bdd-feature-sync fan-out survives skills-CLI via general-purpose" {
  run grep -q 'general-purpose' "$DOC"; [ "$status" -eq 0 ]
  run grep -qi 'bdd-feature-sync' "$DOC"; [ "$status" -eq 0 ]
}

@test "states spec-review machinery is Claude/plugin-only" {
  run grep -qi 'spec-review' "$DOC"; [ "$status" -eq 0 ]
  run grep -qiE 'claude|plugin-only|only on claude' "$DOC"; [ "$status" -eq 0 ]
}

@test "states off-Claude activation is fail-closed on .bdd.json" {
  run grep -qi 'fail-closed' "$DOC"; [ "$status" -eq 0 ]
}
