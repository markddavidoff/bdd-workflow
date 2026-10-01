#!/usr/bin/env bash
mkdir -p docs/features src
printf '{"version":1,"featureFilesDir":"docs/features"}' > .bdd.json
printf 'Feature: Auth\n\n  Scenario: Log in\n    Given a user\n    When they log in\n    Then they see the dashboard\n' > docs/features/01_auth.feature
