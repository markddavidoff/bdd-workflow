# Evals & E2E tests

The plugins are tested in two tiers. Tier 1 needs no API key and runs in CI on every push;
Tier 2 runs real agent sessions and needs a key, so it runs nightly.

## Tier 1 — install-smoke (keyless, per-push)

```bash
bash tests/e2e/install-smoke.sh
```

Installs all four plugins from the local marketplace into an isolated `CLAUDE_CONFIG_DIR` and
asserts each loads enabled, exposes at least one skill, and — for `bdd-knowledge-base` — registers
its `SessionStart` hook. No agent turn, so it is deterministic. It also runs under `make test`
(where it skips if the `claude` CLI is absent) and gates every push through the unauthenticated
`validate` job in `.github/workflows/evals.yml`.

## Tier 2 — behavior evals (real agent runs, keyed)

Each case is a prompt plus graders under `plugins/<plugin>/evals/<case>/`. Run a case with the
`claude plugin eval` CLI (ensure `ANTHROPIC_API_KEY` is available in your environment):

```bash
claude plugin eval plugins/<plugin> --case <name> --scaffold --max-cost-usd N --no-publish --trust-plugin
```

`--scaffold` is required for every case that has a `setup.sh` (all the new cases do) — without it the
fixture is never created and the case runs in an empty workspace.

| Case | Plugin | What it proves |
|------|--------|----------------|
| `kb-accuracy` | bdd-knowledge-base | The answer reproduces a planted knowledge-base fact (grounded, cited), not a hallucination |
| `persona-create` | spec-personas | Writes a valid, security-focused `.persona` file |
| `persona-review` | spec-personas | The review reflects the persona's specific concerns |
| `full-dev-loop` | bdd-flow | persona → spec → tests → implementation, with the generated tests actually passing |
| `review-catches-violation` | bdd-flow | The review flags a planted spec violation |
| `spec-first-enforcement` | bdd-flow | A change request yields a spec change first, with no source written |

CI runs the Tier-2 cases nightly (`nightly-evals` job), gated behind the `ANTHROPIC_API_KEY` repo
secret; they never run on fork pull requests.

## Grader types

Cases use the standard `claude plugin eval` graders: `file_exists`, `regex`, `tool_used`, and `llm`
(rubric in the file body, judged PASS on ≥2 of 3 votes). The `full-dev-loop` "tests passed" check
follows the documented pattern — the agent runs the tests and writes the outcome to a file, a
`regex` grader reads that file, and a `tool_used` grader confirms the command ran.

Structure is validated for free by `tests/evals-structure.bats`; a green structure gate is not a
green case — only a real run through the keyed runner scores the graders.
