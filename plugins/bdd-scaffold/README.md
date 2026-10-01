# bdd-scaffold

Add BDD to a project from scratch: `.bdd.json`, feature and step templates, and Playwright + CI
wiring. Stack-opinionated.

## What it does

Bootstraps the files a BDD project needs so the other plugins have something to work with: a
schema-valid `.bdd.json`, starter `.feature` and step-definition templates, a Playwright-BDD test
setup, and a CI workflow.

## Components

- **Skill** — `bdd-scaffold`: interactive scaffolding that emits a schema-valid `.bdd.json` and the
  template set.

## How to use

```
/plugin install bdd-scaffold@bdd-workflow
```

Run it in a project without BDD ("scaffold BDD into this project") and answer the prompts; it writes
`.bdd.json` and the templates. Then use `bdd-flow` to author specs and generate tests.

## Where it fits

The first stage — **scaffold → author spec → review → generate tests → implement**. See the repo root
[README](../../README.md) for the full lifecycle.
