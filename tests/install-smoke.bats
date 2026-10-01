#!/usr/bin/env bats

# Tier-1 install E2E. Needs the `claude` CLI; where it is absent (e.g. the CLI-less
# ci.yml runner) the test skips so `bats tests/` stays green. The real CI gate lives in
# evals.yml's unauthenticated validate job, which installs the CLI (no API key needed).

setup() {
  command -v claude >/dev/null || skip "claude CLI not installed"
  command -v jq >/dev/null || skip "jq not installed"
}

@test "all 4 plugins install from the local marketplace, load enabled, expose skills" {
  run bash tests/e2e/install-smoke.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK: 4 plugins installed"* ]]
}
