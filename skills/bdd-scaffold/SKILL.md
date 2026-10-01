---
name: bdd-scaffold
description: >
  Scaffold a BDD-ready project — generate a schema-valid .bdd.json, feature/step
  file templates, Playwright + CI wiring. Use when the user wants to add BDD to a
  project or start a new BDD project. Stack-opinionated (defaults to playwright-bdd).
---

# BDD Scaffold

Generates BDD project structure from the templates in this plugin's `templates/` directory. The
emitted `.bdd.json` MUST validate against `schemas/bdd-config.schema.json` (version 1, canonical on
`featureFile`).

## Interactive flow

Do this as a short dialogue — one decision at a time, sensible defaults offered.

1. **Confirm intent.** If a `.bdd.json` already exists, stop and tell the user the project is
   already scaffolded (offer to show it); do not overwrite.
2. **Ask the stack** (default `playwright-bdd`; other valid values: `cucumber-js`, `pytest-bdd`,
   `reqnroll`, `behave`). Only `playwright-bdd` ships full templates today — for another stack,
   still write `.bdd.json` but tell the user the step/config/CI templates are Playwright-specific.
3. **Ask the feature directory** (default `docs/features`), the steps directory (default
   `tests/bdd/steps`), and the e2e directory (default `tests/e2e`).
4. **Write the files** from `templates/`, substituting `{{featureFilesDir}}` / `{{stepsDir}}` with
   the answers:
   - `.bdd.json` (from `.bdd.json.template`, with the chosen values)
   - `<featureFilesDir>/01_example.feature` (from `01_example.feature.template`)
   - `<stepsDir>/common.steps.ts` (from `common.steps.ts.template`)
   - `playwright.config.ts` (from `playwright.config.ts.template`)
   - `.github/workflows/bdd.yml` (from `ci.yml.template`)
   Never overwrite a file that already exists — skip it and report the skip.
5. **Validate** the emitted `.bdd.json` against `schemas/bdd-config.schema.json` before finishing.
   If it does not validate, fix it and re-validate; do not leave an invalid config on disk.
6. **Optional first-run analysis.** You MAY scan the codebase and propose `domainMap` /
   `domainHazards` entries for the user to approve (this feeds the `bdd-feature-sync` adversarial
   review — see that skill's domain-hazards handling). Only write approved entries.
7. **Report** what was written, what was skipped, and the next step (write your first real feature,
   then run `npx bddgen && npx playwright test`).

## Contract

- The `.bdd.json` you write always sets `version: 1` and a `featureFilesDir`, and uses `featureFile`
  (not the deprecated `file`) in any `domainMap` entry.
- Keep everything generic — no domain-specific nouns in the scaffolded files.
