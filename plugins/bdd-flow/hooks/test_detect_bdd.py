import json
import os
import subprocess
import sys

SCRIPT = os.path.join(os.path.dirname(__file__), "detect-bdd.py")


def run(cwd):
    p = subprocess.run(
        [sys.executable, SCRIPT],
        input=json.dumps({"prompt": "x", "session_id": "s"}),
        capture_output=True,
        text=True,
        cwd=str(cwd),
    )
    assert p.returncode == 0, p.stderr  # fail-soft: never non-zero
    return p.stdout


def test_configured_when_bdd_json_present(tmp_path):
    (tmp_path / ".bdd.json").write_text('{"featureFilesDir":"docs/features"}')
    assert "configured" in run(tmp_path).lower()


def test_inferred_when_feature_files_present(tmp_path):
    d = tmp_path / "docs" / "features"
    d.mkdir(parents=True)
    (d / "a.feature").write_text("Feature: x")
    assert "inferred" in run(tmp_path).lower()


def test_inferred_when_bdd_runner_in_manifest(tmp_path):
    (tmp_path / "package.json").write_text('{"devDependencies":{"playwright-bdd":"^7"}}')
    assert "inferred" in run(tmp_path).lower()


def test_silent_when_neither(tmp_path):
    assert run(tmp_path).strip() == ""


def test_silent_when_feature_only_under_node_modules(tmp_path):
    # H12: pruned dirs must not count as a BDD signal.
    d = tmp_path / "node_modules" / "somepkg"
    d.mkdir(parents=True)
    (d / "foo.feature").write_text("Feature: vendored")
    assert run(tmp_path).strip() == ""
