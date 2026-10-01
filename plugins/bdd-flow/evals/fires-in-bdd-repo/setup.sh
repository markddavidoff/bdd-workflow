#!/usr/bin/env bash
mkdir -p docs/features
printf '{"version":1,"featureFilesDir":"docs/features"}' > .bdd.json
printf 'Feature: Data\n\n  Scenario: View data\n    Given a user\n    When they open the page\n    Then they see their data\n' > docs/features/01_data.feature
