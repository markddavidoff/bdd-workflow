#!/usr/bin/env python3
"""UserPromptSubmit hook: two-tier BDD detection.

Emits a context line naming the tier so the skill's standing instruction can gate on it:
  configured = `.bdd.json` present
  inferred   = `.feature` files (outside pruned dirs) or a BDD runner in a manifest
  none       = silent

Fail-soft: any error exits 0 with no output (never blocks a prompt).
"""
import json
import subprocess
import sys
from pathlib import Path

CONFIGURED = ("[BDD project — configured] `.bdd.json` present. bdd-feature-sync is a standing "
              "instruction here: route feature adds / behaviour changes / bug fixes through it.")
INFERRED = ("[BDD project — inferred] `.feature` files or a BDD runner detected, but no "
            "`.bdd.json`. Offer to generate one before taking over the workflow.")

# Directories that must never count as a BDD signal (H12).
PRUNE = ("node_modules", ".git", "vendor")


def tier(cwd: Path) -> str:
    if (cwd / ".bdd.json").exists():
        return "configured"
    # -maxdepth is a global option, so it precedes -name; prune the noise dirs first.
    prune_expr = []
    for d in PRUNE:
        prune_expr += ["-name", d, "-o"]
    prune_expr = prune_expr[:-1]  # drop the trailing -o
    cmd = ["find", ".", "-maxdepth", "5", "("] + prune_expr + [")", "-prune", "-o",
           "-name", "*.feature", "-print"]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd, timeout=5)
        if r.stdout.strip():
            return "inferred"
    except (subprocess.TimeoutExpired, OSError):
        return "none"
    for mf, needle in (("package.json", "playwright-bdd"), ("package.json", "@cucumber/cucumber"),
                       ("pyproject.toml", "pytest-bdd"), ("pyproject.toml", "behave")):
        p = cwd / mf
        if p.exists():
            try:
                if needle in p.read_text():
                    return "inferred"
            except OSError:
                pass
    return "none"


def main() -> None:
    try:
        json.load(sys.stdin)  # consume required input; fields not needed
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)
    try:
        t = tier(Path.cwd())
    except OSError:
        sys.exit(0)
    if t == "configured":
        print(CONFIGURED)
    elif t == "inferred":
        print(INFERRED)
    # 'none' -> silent


if __name__ == "__main__":
    main()
