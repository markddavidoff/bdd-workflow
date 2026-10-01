#!/usr/bin/env bash
mkdir -p examples/library-lending/docs/features
cat > examples/library-lending/docs/features/lending.feature <<'FEAT'
Feature: Library lending
  Scenario: A patron borrows an available book
    Given the book "Dune" is available
    When the patron borrows "Dune"
    Then "Dune" is marked on loan
FEAT
printf '# Spec change\n\nReturns now respect the hold queue: spec -> test -> impl.\n' \
  > examples/library-lending/SPEC-CHANGE.md
