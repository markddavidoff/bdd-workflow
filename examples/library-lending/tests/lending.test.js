const { test } = require('node:test');
const assert = require('node:assert');
const { createLibrary, addBook, borrow, returnBook, isAvailable } = require('../src/lending.js');

function oneCopy() { const l = createLibrary(); addBook(l, 'dune', 1); return l; }

test('a patron can borrow an available book', () => {
  const l = oneCopy();
  assert.deepStrictEqual(borrow(l, 'dune', 'ada'), { status: 'borrowed' });
  assert.strictEqual(isAvailable(l, 'dune'), false);
});

test('borrowing an unavailable book puts the patron on the hold queue', () => {
  const l = oneCopy();
  borrow(l, 'dune', 'ada');
  assert.deepStrictEqual(borrow(l, 'dune', 'grace'), { status: 'held', position: 1 });
});

test('a returned book with a hold queue is reserved for the next patron, not made available', () => {
  const l = oneCopy();
  borrow(l, 'dune', 'ada');
  borrow(l, 'dune', 'grace');
  assert.deepStrictEqual(returnBook(l, 'dune', 'ada'), { status: 'reserved', reservedFor: 'grace' });
  assert.strictEqual(isAvailable(l, 'dune'), false);
});

test('the reserved patron can then borrow the book', () => {
  const l = oneCopy();
  borrow(l, 'dune', 'ada');
  borrow(l, 'dune', 'grace');
  returnBook(l, 'dune', 'ada');
  assert.deepStrictEqual(borrow(l, 'dune', 'grace'), { status: 'borrowed' });
});

test('a returned book with no holds becomes available', () => {
  const l = oneCopy();
  borrow(l, 'dune', 'ada');
  assert.deepStrictEqual(returnBook(l, 'dune', 'ada'), { status: 'available' });
  assert.strictEqual(isAvailable(l, 'dune'), true);
});
