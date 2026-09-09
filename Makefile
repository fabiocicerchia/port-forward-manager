PREFIX ?= /usr/local
ARGS   ?= help

# Every verb this repository exposes lives here; `make` on its own prints them.
# FC-GEN-057: the same eight verbs in every repo, each either wired or a
# declared no-op that says why. None of them exit 0 quietly.

.DEFAULT_GOAL := help

.PHONY: help setup install uninstall build test lint run format analyze

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install the pre-commit hook
	pre-commit install

install: ## Install the tools and their man pages (DESTDIR/PREFIX honoured)
	install -d "$(DESTDIR)$(PREFIX)/bin" "$(DESTDIR)$(PREFIX)/share/man/man1"
	install -m 0755 pfm "$(DESTDIR)$(PREFIX)/bin/pfm"
	install -m 0644 man/pfm.1 "$(DESTDIR)$(PREFIX)/share/man/man1/pfm.1"
	@echo "installed pfm into $(DESTDIR)$(PREFIX)/bin"

uninstall: ## Remove what `make install` put down
	rm -f "$(DESTDIR)$(PREFIX)/bin/pfm" "$(DESTDIR)$(PREFIX)/share/man/man1/pfm.1"

lint: ## Run the whole gate — every hook, every file
	pre-commit run --all-files

test: ## Run the lifecycle test (kubectl stubbed, no cluster needed)
	./test.sh

run: ## Run pfm from the checkout (ARGS is the subcommand, default `help`)
	./pfm $(ARGS)

format: ## Rewrite what the gate can fix: whitespace, line endings, final newline
	@# A fixing hook exits 1 when it rewrites a file. That is this target doing
	@# its job, not failing, so the exits are ignored — make still prints what
	@# each hook said.
	-pre-commit run --all-files trailing-whitespace
	-pre-commit run --all-files end-of-file-fixer
	-pre-commit run --all-files mixed-line-ending

analyze: ## Shellcheck the scripts on their own, without the rest of the gate
	@command -v shellcheck >/dev/null 2>&1 || { \
		echo "analyze needs shellcheck: https://github.com/koalaman/shellcheck#installing" >&2; \
		exit 69; }
	shellcheck pfm test.sh

# --- Declared no-op (FC-GEN-058) ---

build: ## Not applicable — nothing is compiled
	@echo 'Nothing to build: pfm is a shell script; make install copies it.'
	@echo "See README > Not applicable."
