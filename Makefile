.PHONY: sync drift validate test install-smoke
sync:
	@bash scripts/sync-skills.sh

install-smoke:
	@bash tests/e2e/install-smoke.sh

drift: sync
	@bash scripts/check-drift.sh

validate:
	@for p in bdd-flow bdd-knowledge-base spec-personas bdd-scaffold; do \
	  claude plugin validate "plugins/$$p" --strict --json || exit 1; done
	@claude plugin validate .claude-plugin/marketplace.json --strict --json

test:
	@bats tests/
	@python3 -m pytest plugins/bdd-flow/hooks -q
