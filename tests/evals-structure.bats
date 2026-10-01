#!/usr/bin/env bats

# Structural validation of the eval suite (runs need an API key; structure does not).

@test "every eval case has a prompt and at least one grader" {
  run python3 - <<'PY'
import glob, os, sys
cases = sorted({os.path.dirname(p) for p in glob.glob("plugins/*/evals/*/prompt.md")})
assert cases, "no eval cases found"
bad = []
for c in cases:
    if not os.path.exists(os.path.join(c, "prompt.md")):
        bad.append(f"{c}: no prompt.md")
    graders = glob.glob(os.path.join(c, "graders", "*.md"))
    if not graders:
        bad.append(f"{c}: no graders")
if bad:
    print("\n".join(bad), file=sys.stderr); sys.exit(1)
print(f"{len(cases)} cases OK")
PY
  [ "$status" -eq 0 ]
}

@test "every grader declares a type" {
  run python3 - <<'PY'
import glob, re, sys
bad = []
for g in glob.glob("plugins/*/evals/*/graders/*.md"):
    if not re.search(r'^type:\s*\S', open(g).read(), re.M):
        bad.append(g)
if bad:
    print("graders missing type: " + ", ".join(bad), file=sys.stderr); sys.exit(1)
PY
  [ "$status" -eq 0 ]
}

@test "no grader uses arm: both (POC 2: no-op on tool_used: Skill)" {
  run bash -c "grep -rInE 'arm:\\s*both' plugins/*/evals 2>/dev/null"
  [ "$status" -ne 0 ]   # grep finds nothing -> non-zero
}

@test "case.yaml files are valid YAML" {
  run python3 - <<'PY'
import glob, yaml, sys
bad = []
for c in glob.glob("plugins/*/evals/*/case.yaml"):
    try:
        yaml.safe_load(open(c))
    except Exception as e:
        bad.append(f"{c}: {e}")
if bad:
    print("\n".join(bad), file=sys.stderr); sys.exit(1)
PY
  [ "$status" -eq 0 ]
}
