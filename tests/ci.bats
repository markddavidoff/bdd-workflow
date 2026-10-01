#!/usr/bin/env bats

@test "ci runs the drift check before any standalone 'make sync' (else committed drift is masked)" {
  drift_line=$(grep -n 'check-drift.sh' .github/workflows/ci.yml | head -1 | cut -d: -f1)
  sync_line=$(grep -nE '^[[:space:]]+run: make sync[[:space:]]*$' .github/workflows/ci.yml | head -1 | cut -d: -f1)
  [ -n "$drift_line" ]
  [ -z "$sync_line" ] || [ "$drift_line" -lt "$sync_line" ]
}

@test "ci wires all four content guards" {
  grep -q 'check-drift.sh' .github/workflows/ci.yml
  grep -q 'check-no-abs-paths.sh' .github/workflows/ci.yml
  grep -q 'check-no-domain-vocab.sh' .github/workflows/ci.yml
  grep -q 'check-no-withheld-personas.sh' .github/workflows/ci.yml
}
