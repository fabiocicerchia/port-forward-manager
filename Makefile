PREFIX ?= /usr/local

.PHONY: help setup install lint test

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install git hooks and dev tooling
	git config core.hooksPath .githooks
	@command -v pre-commit >/dev/null 2>&1 && pre-commit install || true

install: ## Install pfm onto PREFIX/bin (default /usr/local)
	install -m 0755 pfm $(PREFIX)/bin/pfm

lint: ## Shellcheck the scripts
	shellcheck pfm test.sh

test: ## Run the lifecycle test (kubectl stubbed, no cluster needed)
	./test.sh
