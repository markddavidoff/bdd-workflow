#!/usr/bin/env bash
mkdir -p personas docs
cat > docs/checkout.spec.md <<'MD'
# Checkout spec
Users enter a card number and CVV in a form and click Pay. On success they see a receipt.
Card details are sent to the payment processor.
MD
cat > personas/security-reviewer.persona <<'MD'
name: Security Reviewer
focus: Reviews specs for authn/authz gaps, input validation, secret handling, and data exposure.
tone: skeptical, concrete
MD
