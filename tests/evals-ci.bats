#!/usr/bin/env bats

WF=.github/workflows/evals.yml

@test "evals workflow is valid YAML" {
  run python3 -c "import yaml,sys; yaml.safe_load(open('$WF'))"
  [ "$status" -eq 0 ]
}

@test "eval jobs never run on fork pull_request (they need the API key)" {
  run python3 - <<'PY'
import yaml, sys
wf = yaml.safe_load(open(".github/workflows/evals.yml"))
jobs = wf["jobs"]
bad = []
SAFE = ("!= 'pull_request'", '!= "pull_request"', "== 'schedule'", '== "schedule"',
        "== 'push'", '== "push"', "== 'workflow_dispatch'", '== "workflow_dispatch"')
for name, job in jobs.items():
    uses_key = "ANTHROPIC_API_KEY" in yaml.safe_dump(job)
    guard = str(job.get("if", ""))
    if uses_key and not any(s in guard for s in SAFE):
        bad.append(f"{name}: uses the API key but its `if` does not exclude pull_request")
if bad:
    print("\n".join(bad), file=sys.stderr); sys.exit(1)
PY
  [ "$status" -eq 0 ]
}

@test "the validate job needs no secret (fork-PR safe)" {
  run python3 - <<'PY'
import yaml, sys
job = yaml.safe_load(open(".github/workflows/evals.yml"))["jobs"]["validate"]
assert "ANTHROPIC_API_KEY" not in yaml.safe_dump(job), "validate must not reference the API key"
PY
  [ "$status" -eq 0 ]
}
