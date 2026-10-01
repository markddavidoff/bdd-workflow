#!/usr/bin/env bats

load lib/blocklist

@test "agent prompts hardcode no proprietary domain nouns" {
  bl_present || skip "no private blocklist available"
  for a in qa-engineer exploratory-tester product-manager; do
    run grep -nE "$(bl_pattern)" "plugins/bdd-flow/agents/$a.md"
    [ "$status" -ne 0 ]
  done
}

@test "the concrete example survives as a labeled reference (shelfie, not proprietary)" {
  f=plugins/bdd-flow/references/domain-hazards-example.md
  [ -f "$f" ]
  run grep -qiE 'example|illustration' "$f"; [ "$status" -eq 0 ]
  run grep -qE 'isLent|queuePosition' "$f"; [ "$status" -eq 0 ]   # concreteness relocated, shelfie domain
  if bl_present; then run grep -qE "$(bl_pattern)" "$f"; [ "$status" -ne 0 ]; fi   # no proprietary vocab
}

@test "skill injects project domainHazards into the adversarial dispatch" {
  run grep -q 'domainHazards' skills/bdd-feature-sync/SKILL.md
  [ "$status" -eq 0 ]
}
