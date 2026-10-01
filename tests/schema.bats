#!/usr/bin/env bats

load lib/blocklist

validate() { npx --yes ajv-cli@5 validate -s schemas/bdd-config.schema.json --spec=draft2020 -d "$1"; }

@test "valid minimal config passes" { run validate fixtures/bdd-config/valid-minimal.json; [ "$status" -eq 0 ]; }
@test "valid full config passes"    { run validate fixtures/bdd-config/valid-full.json;    [ "$status" -eq 0 ]; }
@test "legacy 'file' alias passes"  { run validate fixtures/bdd-config/valid-legacy-alias.json; [ "$status" -eq 0 ]; }
@test "config missing featureFilesDir fails" { run validate fixtures/bdd-config/invalid-missing-dir.json; [ "$status" -ne 0 ]; }

@test "fixtures carry no proprietary domain vocab (CR1)" {
  # Agency|agencies (the CR3 agencies-fixture guard) are generic words, kept inline; the private
  # codenames/fingerprints come from the gitignored blocklist when present.
  if bl_present; then pat="$(bl_pattern)|Agency|agencies"; else pat="Agency|agencies"; fi
  run grep -rEl "$pat" fixtures/
  [ "$status" -ne 0 ]
}
