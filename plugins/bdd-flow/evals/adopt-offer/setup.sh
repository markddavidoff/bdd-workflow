#!/usr/bin/env bash
# Inferred tier: a .feature file exists but there is no .bdd.json yet.
mkdir -p features
printf 'Feature: Items\n\n  Scenario: List items\n    Given items exist\n    When the user opens the list\n    Then the items are shown\n' > features/items.feature
