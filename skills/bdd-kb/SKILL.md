---
name: bdd-kb
description: >
  Loads targeted pages from the local BDD knowledge base. Invoke with a task type
  (scenario-authoring, step-definitions, playwright-bdd-setup, test-isolation, ci,
  debugging, parameter-types) to retrieve 3–5 pages of synthesized context.
  No args loads the orientation index. Use this when working on BDD features,
  step definitions, or playwright-bdd test infrastructure.
---

# bdd-kb — BDD Knowledge Base Reference

Loads targeted pages from the local BDD knowledge base at `<KB_ROOT>/docs/`.

## Resolving the KB root

Before reading any page, resolve `<KB_ROOT>` in this order and use the first that exists:

1. `$GHERKIN_KB_PATH` (explicit override)
2. `${CLAUDE_PLUGIN_DATA}/kb` (plugin install — populated by the sync-kb hook)
3. `./.gherkin-kb` (skills-CLI / project-local install)

If none exists, do not guess a path. Tell the user the KB is not installed and to run
`/bdd-kb-sync` (plugin) or set `$GHERKIN_KB_PATH`, then stop.

All page paths below are relative to `<KB_ROOT>`.

## Manual (non-Claude) bootstrap

On Claude Code the `bdd-knowledge-base` plugin's `SessionStart` hook installs the KB automatically.
Off Claude (or on a skills-CLI-only install with no plugin hook), populate `./.gherkin-kb` by hand —
this is the portable path:

```sh
# From the release for the pinned version (see the plugin's kb-version.json for repo/asset/sha256):
repo=markddavidoff/bdd-knowledge-base; ver=1.0.0; asset=bdd-knowledge-base-$ver.tar.gz
base="https://github.com/$repo/releases/download/v$ver"
curl -fsSL "$base/$asset" -o "$asset"
curl -fsSL "$base/$asset.sha256" -o "$asset.sha256"
shasum -a 256 -c "$asset.sha256"          # MUST print "$asset: OK" before trusting the payload
mkdir -p .gherkin-kb && tar -xzf "$asset" -C .gherkin-kb
```

The release build is byte-reproducible, so the downloaded asset's sha256 matches the published
sidecar and the plugin's pin. After this, resolution step 3 (`./.gherkin-kb`) finds the KB.

## Opt out / uninstall

- **Disable auto-fetch:** set `GHERKIN_KB_DISABLE=1` — the SessionStart hook then makes no network
  call and installs nothing.
- **Point at your own copy:** set `GHERKIN_KB_PATH=/path/to/kb` — the hook skips fetching and the
  skill reads your copy directly.
- **Remove the cached KB:** run `/bdd-kb-clean` (plugin) to delete the plugin's KB cache.

## Usage

`bdd-kb [task-type]`

Available task types: `scenario-authoring`, `step-definitions`, `playwright-bdd-setup`,
`test-isolation`, `ci`, `debugging`, `parameter-types`

With no args: loads orientation index (AGENT.md + tab landing pages).

## Instructions

When this skill is invoked:

1. Parse the task type from args (default: `orientation` if none given)
2. Read the pages listed in the routing table below using the Read tool
3. Output: 3–5 bullet-point synthesis of key facts relevant to the current task, then the full page content
4. State which page paths you read

## Page Routing

### orientation (no arg)
- `<KB_ROOT>/docs/AGENT.md`
- `<KB_ROOT>/docs/gherkin/index.md`
- `<KB_ROOT>/docs/practice/index.md`

### scenario-authoring
- `<KB_ROOT>/docs/gherkin/best-practices/declarative-vs-imperative.md`
- `<KB_ROOT>/docs/gherkin/best-practices/scenario-structure.md`
- `<KB_ROOT>/docs/gherkin/best-practices/ubiquitous-language.md`
- `<KB_ROOT>/docs/gherkin/examples/hello-world.md`

### step-definitions
- `<KB_ROOT>/docs/practice/playwright-bdd/writing-steps.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/fixtures.md`
- `<KB_ROOT>/docs/gherkin/reference/custom-parameter-types.md`

### playwright-bdd-setup
- `<KB_ROOT>/docs/practice/playwright-bdd/installation.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/configuration.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/typescript-config.md`

### test-isolation
- `<KB_ROOT>/docs/practice/playwright-bdd/test-isolation.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/parallelism.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/fixtures.md`

### ci
- `<KB_ROOT>/docs/practice/spec-lifecycle/ci-running.md`
- `<KB_ROOT>/docs/practice/spec-lifecycle/ci-enforcement.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/sync-and-hygiene.md`

### debugging
- `<KB_ROOT>/docs/practice/playwright-bdd/debugging.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/sync-and-hygiene.md`
- `<KB_ROOT>/docs/practice/playwright-bdd/typescript-config.md`

### parameter-types
- `<KB_ROOT>/docs/gherkin/reference/custom-parameter-types.md`
- `<KB_ROOT>/docs/gherkin/best-practices/named-test-data-catalog.md`
- `<KB_ROOT>/docs/practice/examples/domain-parameter-registry.md`
