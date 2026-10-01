#!/usr/bin/env bats

# H5 contract: the README must carry the sections a first-time installer needs.

@test "README has an Install section" {
  run grep -qiE '^##[[:space:]]+(Install|Quickstart)' README.md
  [ "$status" -eq 0 ]
}

@test "README has a three-plugin chooser" {
  run grep -qiE '^##[[:space:]].*which plugin' README.md
  [ "$status" -eq 0 ]
}

@test "README states the KB lives only in bdd-flow" {
  run bash -c "grep -qi 'knowledge base' README.md && grep -q 'bdd-flow' README.md"
  [ "$status" -eq 0 ]
}

@test "README discloses hooks + KB download cost" {
  run grep -qiE '^##[[:space:]].*(hook|knowledge base|download)' README.md
  [ "$status" -eq 0 ]
}

@test "README documents offline behavior" {
  run grep -qiE '^##[[:space:]].*offline' README.md
  [ "$status" -eq 0 ]
}

@test "README documents uninstall / opt-out" {
  run grep -qiE '^##[[:space:]].*(uninstall|opt-out|opt out)' README.md
  [ "$status" -eq 0 ]
}

@test "README carries the no-warranty / not-affiliated block" {
  run bash -c "grep -qi 'no warranty' README.md && grep -qi 'not affiliated' README.md"
  [ "$status" -eq 0 ]
}

@test "README carries a trademark disclaimer" {
  run grep -qi 'SmartBear' README.md
  [ "$status" -eq 0 ]
}

@test "README discloses the KB fetch and its opt-out controls" {
  # The fetch ships (Phase 2): disclose that it is pinned + verified, and how to opt out.
  run bash -c "grep -qiE 'pinned.*(verif|sha256)|sha256-verified' README.md"; [ "$status" -eq 0 ]
  run grep -q 'GHERKIN_KB_DISABLE' README.md; [ "$status" -eq 0 ]
  run grep -q 'GHERKIN_KB_PATH' README.md; [ "$status" -eq 0 ]
  run grep -q '/bdd-kb-clean' README.md; [ "$status" -eq 0 ]
}
