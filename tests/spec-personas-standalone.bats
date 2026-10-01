#!/usr/bin/env bats

@test "spec-personas has no dependency on bdd-flow or the KB" {
  run bash -c "grep -rniE 'bdd-flow|bdd-feature-sync|bdd-kb|GHERKIN_KB' skills/spec-review skills/persona-manager plugins/spec-personas 2>/dev/null"
  [ "$status" -ne 0 ]
}
