# Domain hazards — a worked example (illustration only)

> This is an example from a **fictional reading-queue app**, included to show the *shape* of a
> domain hazard. It is **not** an instruction to look for these specific fields in your project —
> your project's hazards come from `.bdd.json` `domainHazards`. Treat it as a pattern, not a checklist.

## The shape: display set ≠ computation set

On a shelf, a book can be flagged `isLent` (checked out to someone else and hidden from the visible
list), `sample`, or `grouped`. The shelf view **filters out** `isLent` books, but the reorder
operation computed `queuePosition` over the **unfiltered** set — so dragging a book next to a hidden
`isLent` book silently no-oped. Happy-path tests passed because their fixtures had no `isLent` books.

The transferable lesson: **when the display set and the computation set can differ, generate a
scenario where they *do* differ** — a hidden/filtered/flagged item interleaved with visible ones,
at a boundary position (first / last / only), so the two sets diverge.

## Why this belongs in a project's `domainHazards`, not here

The concrete fields above (`isLent`, `queuePosition`, the shelf filter) are one app's vocabulary. A
project declares its own equivalents in `.bdd.json`:

```json
{
  "domainHazards": [
    { "name": "hidden-item reorder", "flags": ["isLent", "sample"],
      "description": "list view filters these out but rank/position computes over the full set" }
  ]
}
```

The adversarial review agents receive those entries in their task prompt and hunt for the
project-specific version of this mismatch — the abstract hazard *class* is shipped in the agent
prompts; the concrete hazards are yours.
