# bdd-knowledge-base

On-demand access to a curated Gherkin/BDD reference — fetched, pinned, and sha256-verified — that you
can query directly or use to back `bdd-flow`.

## What it does

Backs the `bdd-kb` skill with a local copy of the `bdd-knowledge-base` dataset (Gherkin language
reference, best practices, worked examples, BDD methodology). On first session it fetches a pinned,
verified release into the plugin's data directory; after that it works offline with no further
network. This is the **only** plugin in the suite that fetches anything.

## Components

- **Skill** — `bdd-kb`: resolves the KB and answers BDD/Gherkin questions from it, by task type
  (scenario-authoring, step-definitions, playwright-bdd-setup, and others).
- **Skill** — `bdd-tutorial`: an adaptive, hands-on onboarding walkthrough — assesses what you know,
  then tours the `library-lending` example or delegates to `persona-manager` / `bdd-feature-sync` for
  your own project.
- **Commands** — `/bdd-kb-sync` (fetch or update the KB), `/bdd-kb-clean` (remove the cache),
  `/bdd-tutorial` (start the onboarding walkthrough anytime).
- **Hooks** — `SessionStart`: (1) fetches the pinned KB on first use — announces itself, fail-soft,
  skippable; (2) a marker-gated one-line invite to `/bdd-tutorial` on first interactive startup. The
  invite fires once per install and never in CI, subagents, or non-`startup` sessions. One residual:
  a local headless `claude -p` first run against a fresh data dir may surface the invite line once
  (marker-gated, harmless). Suppress the invite entirely with `CLAUDE_TUTORIAL_NONINTERACTIVE=1`.

## How to use

```
/plugin install bdd-knowledge-base@bdd-workflow
```

Ask a Gherkin/BDD question and `bdd-kb` answers from the reference. Offline or air-gapped: point at a
local copy with `GHERKIN_KB_PATH=/path/to/kb`, or run the manual bootstrap documented in the skill.
Disable the fetch entirely with `GHERKIN_KB_DISABLE=1`.

## Where it fits

The reference layer — standalone for BDD questions, or the knowledge source `bdd-flow` consults while
authoring specs. The KB content and its license live in the separate `bdd-knowledge-base` content repo.
