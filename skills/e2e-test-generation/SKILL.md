---
name: e2e-test-generation
description: Write or update a Playwright spec file in tests/e2e/ whenever a feature is implemented, a bug is fixed, a BDD feature file is updated, or a feature is manually validated. Trigger on: feature implementation complete, bug fix verified, BDD .feature file edited, runTest() called, or user confirms feature works. Do NOT wait for runTest() — any validation milestone is sufficient.
---

# E2E Test Generation

Every time a feature is implemented or validated — including after editing a BDD feature file — you must write or update a permanent Playwright spec file covering those scenarios. The spec files live in `tests/e2e/` and run as a separate Playwright project alongside the BDD suite.

## When to apply

After **any** of the following — whether for a new feature, bug fix, or behavioural change:

- A BDD `.feature` file is created or updated
- A feature implementation is complete (code changes made and reviewed)
- A bug fix has been applied
- `runTest()` is called to validate behaviour
- The user manually confirms a feature works as expected

Do not wait for `runTest()` specifically — any validation milestone is sufficient to trigger spec writing.

> The upstream stage is `bdd-feature-sync` (agrees the Gherkin scenarios before code). This skill covers the *downstream* stage: turning implemented/validated scenarios into Playwright specs. Together they form one BDD pipeline; neither replaces the other.

## File location and naming

```
tests/e2e/{feature-name}.spec.ts
```

Use kebab-case. Name the file after the feature being tested, not the task number:
- `shelf-view.spec.ts`
- `reading-queue.spec.ts`
- `bulk-import.spec.ts`

If a spec file for that feature already exists, **add new `test()` blocks to it** rather than creating a second file.

## Running the tests

Always ensure dependencies are installed before running. Use `make test` for the full suite (it auto-installs), or install manually then run playwright:

```bash
# Preferred: full suite via Make (auto-installs deps)
make test

# Install deps if node_modules is absent, then run e2e specs only
[ -d node_modules ] || npm install
npx playwright test --project=e2e

# Run a specific spec file
[ -d node_modules ] || npm install
npx playwright test tests/e2e/shelf-view.spec.ts --project=e2e
```

After writing a spec, always run it to verify it passes before reporting back to the user.

## Test structure

### Imports

```typescript
import { test, expect, APIRequestContext } from '@playwright/test';
```

### Setup and teardown

- Use `test.beforeAll` to set up test data via the API and save original values.
- Use `test.afterAll` to restore original state — tests must leave the DB in the same condition they found it.
- Use `test.skip(true, 'reason')` inside `test.beforeAll` (or at the top of the test) to skip gracefully when required data doesn't exist.

### API calls in tests

Use `request` (from `APIRequestContext`) for API setup/teardown and `page.request` for in-test API checks:

```typescript
test.beforeAll(async ({ request }) => {
  await request.patch(`/api/books/${bookId}`, {
    data: { holdDays: 3, holdDuration: 'extended' },
  });
});
```

### Assertions

- Use `data-testid` attributes as primary selectors: `page.getByTestId('reading-queue')`
- Use `toContainText` for content checks, `toBeVisible` for presence, `not.toBeAttached()` for true absence
- Avoid asserting exact counts (the DB has existing data)

## What to cover

Write at least one test per significant behaviour path:

| Behaviour | What to test |
|-----------|-------------|
| Feature hidden by condition | Verify element is absent when condition is false |
| Feature shown by condition | Verify element appears when condition is true |
| Form save | Verify PATCH persists the value (re-fetch via API or re-open form) |
| Warning/error states | Verify warning appears under the right conditions |
| Happy path | Verify the primary user flow works end-to-end |

## Edge-case coverage via adversarial QA agent (mandatory)

After writing the initial tests for the happy path and explicit scenarios, launch a **single
sub-agent** (using the `Agent` tool with `subagent_type: "general-purpose"`) to identify coverage
gaps. The agent receives:
- The spec file you just wrote (or updated)
- The source code files that implement the feature
- The relevant BDD feature file (if one exists)

Use this prompt for the agent:

> "You are a senior QA engineer reviewing a Playwright E2E test suite. Your job is to find
> **test coverage gaps** — realistic scenarios where the feature could break but the current
> tests wouldn't catch it. Read the test file, the source code, and the feature file. Then
> identify 3–5 specific edge-case tests that are MISSING.
>
> Focus on:
> 1. **Data state variations**: The tests create specific test data. What if items have
>    different flags (skipped, hidden/isLent, grouped)? Would the feature still work?
>    Create tests that set these flags on test data to verify.
> 2. **Filter mismatches**: Does the feature display a filtered subset of items but operate
>    (reorder, count, position) on the full set? If so, write a test where the filtered and
>    unfiltered sets differ (e.g., hidden items interleaved with visible ones).
> 3. **Boundary conditions**: First item, last item, only item, maximum items.
> 4. **Persistence verification**: After a UI interaction, does the saved API state match
>    what the UI showed? Write tests that save and then verify via API.
> 5. **Double-action**: What if the user performs the same action twice? Does it work both times?
>
> Return each gap as a concrete `test('...', async ({ page, request }) => { ... })` block
> with full Playwright code. Use the same test data setup patterns as the existing tests."

Review the agent's output. For each suggested test that covers a genuinely new code path
(not just a trivial variation), add it to the spec file. Discard suggestions that are
duplicative or test framework/infrastructure rather than product behaviour.

> **Why this step exists:** Happy-path tests pass even when critical edge cases are broken.
> The canonical example: a queue test that passes for available books but misses a bug where
> the reading-queue position silently mis-numbers when a lent-out `isLent` book is adjacent —
> because the test data didn't include lent-out books. The QA agent catches these gaps by
> adversarially reading the source code for alternate data paths.

## Example spec

```typescript
import { test, expect } from '@playwright/test';

test.describe('Reading Queue', () => {
  let shelfId: number;
  let bookId: number;
  let originalHoldDays: number | null;

  test.beforeAll(async ({ request }) => {
    const res = await request.get('/api/shelves');
    const shelves = await res.json();
    const shelfRes = await request.get(`/api/shelves/${shelves[0].id}`);
    const shelf = await shelfRes.json();
    shelfId = shelf.id;
    bookId = shelf.books[0].id;
    originalHoldDays = shelf.books[0].holdDays ?? null;
  });

  test.afterAll(async ({ request }) => {
    await request.patch(`/api/books/${bookId}`, { data: { holdDays: originalHoldDays } });
  });

  test('queue hidden when book has no holdDays', async ({ page, request }) => {
    await request.patch(`/api/books/${bookId}`, { data: { holdDays: null } });
    await page.goto(`/shelf/${shelfId}`);
    await page.waitForLoadState('networkidle');
    await expect(page.getByTestId(`book-card-${bookId}-1`)).not.toBeVisible();
  });

  test('queue shows one card per holdDay', async ({ page, request }) => {
    await request.patch(`/api/books/${bookId}`, { data: { holdDays: 3 } });
    await page.goto(`/shelf/${shelfId}`);
    await page.waitForLoadState('networkidle');
    await expect(page.getByTestId(`book-card-${bookId}-1`)).toBeVisible();
    await expect(page.getByTestId(`book-card-${bookId}-3`)).toBeVisible();
    await expect(page.getByTestId(`book-card-${bookId}-4`)).not.toBeAttached();
  });
});
```
