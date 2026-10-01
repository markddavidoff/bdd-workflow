#!/usr/bin/env bash
mkdir -p docs/features src
printf '{"version":1,"featureFilesDir":"docs/features","e2eDir":"tests"}' > .bdd.json
cat > docs/features/cart.feature <<'MD'
Feature: Cart
  Scenario: add item
    Given an empty cart
    When I add an item
    Then the cart has 1 item
MD
