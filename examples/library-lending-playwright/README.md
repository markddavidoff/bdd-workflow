# library-lending — playwright-bdd variant

The same library-lending behavior as [`../library-lending/`](../library-lending/), wired on the
**flagship [playwright-bdd](https://vitalets.github.io/playwright-bdd/) stack** the knowledge base
goes deep on: real `.feature` files, Gherkin step definitions, and `playwright-test` as the runner.

The minimal `../library-lending/` example uses `node --test` and needs no dependencies; this variant
shows the real BDD toolchain. These scenarios exercise pure domain logic, so **no browser is needed**.

## Run it

```bash
git clone https://github.com/markddavidoff/bdd-workflow
cd bdd-workflow/examples/library-lending-playwright
npm install
npm test        # bddgen generates specs from features/, then playwright-test runs them
```

Expected: `4 passed`.

## Layout

| Path | What it is |
|------|------------|
| `features/lending.feature` | The Gherkin scenarios (borrow, hold queue, queue-respecting return) |
| `steps/lending.steps.js` | Step definitions binding each Gherkin step to the model, via `createBdd()` |
| `src/lending.js` | The toy implementation under test |
| `playwright.config.js` | `defineBddConfig({ features, steps })` wired into `defineConfig` |
| `package.json` | `test` script = `bddgen && playwright test`; pins `playwright-bdd` + `@playwright/test` |

> **Note on API versions:** step callbacks take the fixtures object as their first argument via
> object destructuring — `Given('the number {int}', async ({}, n) => …)`. playwright-bdd's API differs
> across major versions; this example is verified against the versions pinned in `package.json`.
