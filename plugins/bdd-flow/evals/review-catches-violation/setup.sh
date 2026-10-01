#!/usr/bin/env bash
mkdir -p docs/features src
cat > docs/features/is-even.feature <<'MD'
Feature: is-even
  Scenario: zero is even
    Given the number 0
    When I check isEven
    Then the result is true
  Scenario: two is even
    Given the number 2
    When I check isEven
    Then the result is true
MD
cat > src/is-even.js <<'JS'
// Planted violation: returns false for 0, contradicting the "zero is even" scenario.
function isEven(n) { return n !== 0 && n % 2 === 0; }
module.exports = { isEven };
JS
