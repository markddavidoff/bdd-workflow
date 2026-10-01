#!/usr/bin/env bash
# M8 portable smoke: each SKILL.md loads (parseable frontmatter with name + description) and any
# subagent_type it names resolves to a built-in or a shipped plugin agent (no dangling refs).
set -euo pipefail
cd "$(dirname "$0")/.."
root="${1:-skills}"
python3 - "$root" <<'PY'
import sys, glob, os, re
root = sys.argv[1]
agents = {"general-purpose"}  # built-in, always present
for a in glob.glob("plugins/*/agents/*.md"):
    agents.add(os.path.splitext(os.path.basename(a))[0])

skills = sorted(glob.glob(os.path.join(root, "*", "SKILL.md")))
if not skills:
    print(f"no skills under {root}"); sys.exit(0)

fail = False
for s in skills:
    text = open(s).read()
    m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
    if not m:
        print(f"{s}: no YAML frontmatter", file=sys.stderr); fail = True; continue
    fm = m.group(1)
    if not re.search(r'^name:\s*\S', fm, re.M):
        print(f"{s}: missing name", file=sys.stderr); fail = True
    if not re.search(r'^description:\s*\S', fm, re.M):
        print(f"{s}: missing description", file=sys.stderr); fail = True
    for ref in re.findall(r'subagent_type:\s*["\']?([A-Za-z0-9_-]+)', text):
        if ref not in agents:
            print(f"{s}: dangling subagent_type '{ref}'", file=sys.stderr); fail = True

sys.exit(1 if fail else 0)
PY
