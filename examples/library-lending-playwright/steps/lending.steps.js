const { createBdd } = require('playwright-bdd');
const { expect } = require('@playwright/test');
const { createLibrary, addBook, borrow, returnBook, isAvailable } = require('../src/lending.js');

const { Given, When, Then } = createBdd();

// Per-scenario state. playwright-bdd runs each scenario in its own worker test, so module state
// is fresh per scenario file execution; we reset in the first Given to be safe.
let lib, lastResult;

Given('the library has {int} copy of {string}', async ({}, copies, title) => {
  lib = createLibrary();
  addBook(lib, title, copies);
});

Given('Ada has borrowed {string}', async ({}, title) => {
  borrow(lib, title, 'ada');
});

Given('Grace is on the hold queue for {string}', async ({}, title) => {
  borrow(lib, title, 'grace');
});

When('Ada borrows {string}', async ({}, title) => {
  lastResult = borrow(lib, title, 'ada');
});

When('Grace tries to borrow {string}', async ({}, title) => {
  lastResult = borrow(lib, title, 'grace');
});

When('Ada returns {string}', async ({}, title) => {
  lastResult = returnBook(lib, title, 'ada');
});

Then('Ada has {string}', async ({}, title) => {
  expect(lastResult).toEqual({ status: 'borrowed' });
});

Then('{string} is not available', async ({}, title) => {
  expect(isAvailable(lib, title)).toBe(false);
});

Then('{string} is available', async ({}, title) => {
  expect(isAvailable(lib, title)).toBe(true);
});

Then('Grace is placed on the hold queue at position {int}', async ({}, pos) => {
  expect(lastResult).toEqual({ status: 'held', position: pos });
});

Then('{string} is reserved for Grace', async ({}, title) => {
  expect(lastResult).toEqual({ status: 'reserved', reservedFor: 'grace' });
});
