# Spec change: returns respect the hold queue

This is the example's spec-first change story — how a behavior change enters through the **spec**
first, then regenerates tests, then drives the implementation. The files in this folder show the
**after** state; the diffs below show what changed and why.

## The change

**Before:** a returned copy became available to whoever asked next, even if someone was already
waiting for it. The librarian persona flagged this as unfair queue-jumping.

**After:** a returned copy with an active hold queue is **reserved for the next patron in line**,
and is not reported as generally available until the queue clears.

## Step 1 — edit the spec first

The scenario in `docs/features/lending.feature` changed before any code:

```diff
-  Scenario: A returned book becomes available to anyone
-    Given Ada has borrowed the only copy of "Dune"
-    And Grace is on the hold queue for "Dune"
-    When Ada returns "Dune"
-    Then "Dune" is available
+  Scenario: A returned book is reserved for the next patron in the hold queue
+    Given Ada has borrowed the only copy of "Dune"
+    And Grace is on the hold queue for "Dune"
+    When Ada returns "Dune"
+    Then "Dune" is reserved for Grace
+    And "Dune" is not generally available
```

Under the workflow's fail-closed gate, this spec edit is proposed and approved **before** the
source changes — that is the spec-first rule the `spec-first-enforcement` eval also checks.

## Step 2 — regenerate the affected test

The changed scenario regenerated its test in `tests/lending.test.js`:

```diff
-test('a returned book becomes available to anyone', () => {
-  const l = oneCopy();
-  borrow(l, 'dune', 'ada');
-  borrow(l, 'dune', 'grace');
-  assert.deepStrictEqual(returnBook(l, 'dune', 'ada'), { status: 'available' });
-  assert.strictEqual(isAvailable(l, 'dune'), true);
-});
+test('a returned book with a hold queue is reserved for the next patron, not made available', () => {
+  const l = oneCopy();
+  borrow(l, 'dune', 'ada');
+  borrow(l, 'dune', 'grace');
+  assert.deepStrictEqual(returnBook(l, 'dune', 'ada'), { status: 'reserved', reservedFor: 'grace' });
+  assert.strictEqual(isAvailable(l, 'dune'), false);
+});
```

The other scenarios (borrow, join queue, return with no holds) were unaffected, so their tests
stayed as they were.

## Step 3 — the implementation follows

`src/lending.js` `returnBook` changed to honor the queue:

```diff
 function returnBook(lib, id, patron) {
   const b = lib.books[id];
   const idx = b.borrowedBy.indexOf(patron);
   if (idx !== -1) b.borrowedBy.splice(idx, 1);
-  b.available += 1;                 // old: always available to anyone
-  return { status: 'available' };
+  if (b.holds.length > 0) {         // new: reserve for the next patron in line
+    b.reservedFor = b.holds.shift();
+    return { status: 'reserved', reservedFor: b.reservedFor };
+  }
+  b.available += 1;
+  return { status: 'available' };
 }
```

Running `node --test` now passes against the new spec. The order is what matters: spec → test →
implementation, never the reverse.
