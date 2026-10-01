#!/usr/bin/env bash
mkdir -p docs/features tests/e2e
printf '{"version":1,"featureFilesDir":"docs/features","e2eDir":"tests/e2e"}' > .bdd.json
printf 'Feature: Auth\n\n  @smoke\n  Scenario: Log in\n    Given a user\n    When they log in\n    Then they see the dashboard\n' > docs/features/01_auth.feature
