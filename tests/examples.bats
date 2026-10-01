#!/usr/bin/env bats

# The example is a living, verified artifact — not static docs that bit-rot. Its config must be
# schema-valid and its own tests must pass against its implementation.

EX=examples/library-lending

@test "example .bdd.json validates against the schema" {
  run npx --yes ajv-cli@5 validate -s schemas/bdd-config.schema.json --spec=draft2020 -d "$EX/.bdd.json"
  [ "$status" -eq 0 ]
}

@test "example tests pass against the implementation" {
  run bash -c "cd '$EX' && node --test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"# fail 0"* ]]
}
