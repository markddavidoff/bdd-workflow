#!/usr/bin/env bats

@test "every skill loads: parseable frontmatter with name + description" {
  run bash scripts/smoke-skills.sh
  [ "$status" -eq 0 ]
}

@test "smoke fails a skill with no description" {
  tmp="$(mktemp -d)"; mkdir -p "$tmp/broken"
  printf -- '---\nname: broken\n---\nbody\n' > "$tmp/broken/SKILL.md"
  run bash scripts/smoke-skills.sh "$tmp"
  rm -rf "$tmp"
  [ "$status" -ne 0 ]
}

@test "smoke fails a dangling subagent_type reference" {
  tmp="$(mktemp -d)"; mkdir -p "$tmp/refs"
  printf -- '---\nname: refs\ndescription: x\n---\nUse subagent_type: "no-such-agent" here.\n' > "$tmp/refs/SKILL.md"
  run bash scripts/smoke-skills.sh "$tmp"
  rm -rf "$tmp"
  [ "$status" -ne 0 ]
}
