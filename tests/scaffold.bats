#!/usr/bin/env bats

TDIR=skills/bdd-scaffold/templates

@test "the .bdd.json template validates against the schema" {
  # The template keeps a .template extension (ajv parses by extension), so copy its literal JSON
  # to a .json file first, then validate with the same ajv-cli the rest of the suite uses.
  tmp="$(mktemp -d)"
  cp "$TDIR/.bdd.json.template" "$tmp/bdd.json"
  run npx --yes ajv-cli@5 validate -s schemas/bdd-config.schema.json --spec=draft2020 -d "$tmp/bdd.json"
  rm -rf "$tmp"
  [ "$status" -eq 0 ]
}

@test "scaffold ships feature + step + playwright + ci templates" {
  for t in 01_example.feature common.steps.ts playwright.config.ts ci.yml; do
    [ -f "$TDIR/$t.template" ]
  done
}

@test "the plugin copy of bdd-scaffold matches canonical (drift-synced)" {
  run diff -rq skills/bdd-scaffold plugins/bdd-scaffold/skills/bdd-scaffold
  [ "$status" -eq 0 ]
}
