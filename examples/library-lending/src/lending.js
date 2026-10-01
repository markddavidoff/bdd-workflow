// Toy library lending model — the example end-state (hold-queue-aware returns).
// See ../SPEC-CHANGE.md for how the return behavior changed and which tests regenerated.

function createLibrary() {
  return { books: {} };
}

function addBook(lib, id, copies = 1) {
  lib.books[id] = { id, available: copies, borrowedBy: [], holds: [], reservedFor: null };
  return lib;
}

function borrow(lib, id, patron) {
  const b = lib.books[id];
  if (!b) throw new Error(`unknown book: ${id}`);
  if (b.reservedFor === patron) {          // the reservation is being claimed
    b.reservedFor = null;
    b.borrowedBy.push(patron);
    return { status: 'borrowed' };
  }
  if (b.reservedFor && b.reservedFor !== patron) {
    b.holds.push(patron);
    return { status: 'held', position: b.holds.length };
  }
  if (b.available > 0) {
    b.available -= 1;
    b.borrowedBy.push(patron);
    return { status: 'borrowed' };
  }
  b.holds.push(patron);
  return { status: 'held', position: b.holds.length };
}

function returnBook(lib, id, patron) {
  const b = lib.books[id];
  if (!b) throw new Error(`unknown book: ${id}`);
  const idx = b.borrowedBy.indexOf(patron);
  if (idx !== -1) b.borrowedBy.splice(idx, 1);
  // Post-change behavior: reserve the returned copy for the next patron on the hold queue
  // before making it generally available (was: immediately available to anyone).
  if (b.holds.length > 0) {
    b.reservedFor = b.holds.shift();
    return { status: 'reserved', reservedFor: b.reservedFor };
  }
  b.available += 1;
  return { status: 'available' };
}

function isAvailable(lib, id) {
  const b = lib.books[id];
  return !!b && b.available > 0 && !b.reservedFor;
}

module.exports = { createLibrary, addBook, borrow, returnBook, isAvailable };
