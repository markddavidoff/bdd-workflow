#!/usr/bin/env bats

@test "bdd-feature-sync treats the KB as optional and names the install hint" {
  f=skills/bdd-feature-sync/SKILL.md
  run grep -qiE 'if .*(bdd-knowledge-base|KB).*(installed|available|present)' "$f"; [ "$status" -eq 0 ]
  run grep -qi 'bdd-knowledge-base' "$f"; [ "$status" -eq 0 ]
  run grep -qiE 'proceed|continue|without' "$f"; [ "$status" -eq 0 ]
}
