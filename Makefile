# Agent TARS Experiment — Makefile

# Load .env into Make variables and export them to the shell if the file exists.
ifneq ($(wildcard .env),)
  include .env
  export
endif

REPO_URL  := https://github.com/bytedance/UI-TARS-desktop
REPO_DIR  := agent-tars-cli
NODE_MIN  := 22

.PHONY: help install test test-smoke test-research \
        run-anthropic run-openai run-volcengine \
        update clean nuke

## help: Print available targets with descriptions (default).
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' Makefile | sed 's/^## /  /'

## install: Clone upstream repo if missing, install npm deps, verify Node >= 22.
install:
	@node_ver=$$(node --version 2>/dev/null | sed 's/v//;s/\..*//') ; \
	if [ -z "$$node_ver" ]; then \
		echo "ERROR: node not found. Install Node.js >= $(NODE_MIN)."; exit 1; \
	fi; \
	if [ "$$node_ver" -lt "$(NODE_MIN)" ]; then \
		echo "ERROR: Node.js >= $(NODE_MIN) required (found v$$node_ver)."; exit 1; \
	fi; \
	echo "Node.js v$$node_ver — OK"
	@if [ -d "$(REPO_DIR)/.git" ]; then \
		echo "$(REPO_DIR)/ already present — skipping clone."; \
	else \
		echo "Cloning $(REPO_URL) ..."; \
		git clone --depth=1 "$(REPO_URL)" "$(REPO_DIR)"; \
	fi
	npm install
	@echo "Done. Run 'make test' or 'make run-anthropic'."

## test: Run all BDD feature scenarios.
test:
	npm test

## test-smoke: Run @smoke scenarios only (fast connectivity check).
test-smoke:
	npm run test:smoke

## test-research: Run @research scenarios only.
test-research:
	npm run test:research

## run-anthropic: Run Agent TARS CLI interactively with Anthropic (claude-sonnet-4-5).
run-anthropic: _check-env-anthropic
	./node_modules/.bin/agent-tars \
		--provider anthropic \
		--model claude-sonnet-4-5 \
		--apiKey $$ANTHROPIC_API_KEY

## run-openai: Run Agent TARS CLI interactively with OpenAI (gpt-4o).
run-openai: _check-env-openai
	./node_modules/.bin/agent-tars \
		--provider openai \
		--model gpt-4o \
		--apiKey $$OPENAI_API_KEY

## run-volcengine: Run Agent TARS CLI interactively with Volcengine / Doubao.
run-volcengine: _check-env-volcengine
	./node_modules/.bin/agent-tars \
		--provider volcengine \
		--model doubao-1-5-thinking-vision-pro-250428 \
		--apiKey $$VOLC_API_KEY

## update: Pull latest changes in the cloned reference repo (fast-forward only).
update:
	@if [ ! -d "$(REPO_DIR)/.git" ]; then \
		echo "$(REPO_DIR)/ not found — run 'make install' first."; exit 1; \
	fi
	git -C "$(REPO_DIR)" pull --ff-only

## clean: Remove node_modules and stray caches.
clean:
	rm -rf node_modules .npm reports/ $(REPO_DIR)/node_modules $(REPO_DIR)/.turbo

## nuke: clean + remove the cloned agent-tars-cli/ directory.
nuke: clean
	rm -rf "$(REPO_DIR)"
	@echo "Removed $(REPO_DIR)/. Committed files remain."

# --- internal helpers (not shown in help) ---

_check-env-anthropic:
	@if [ -z "$$ANTHROPIC_API_KEY" ]; then \
		echo ""; \
		echo "ERROR: ANTHROPIC_API_KEY is not set."; \
		echo "  Copy .env.example to .env and fill in your key."; \
		echo "  See: https://console.anthropic.com/settings/keys"; \
		echo ""; \
		exit 1; \
	fi

_check-env-openai:
	@if [ -z "$$OPENAI_API_KEY" ]; then \
		echo ""; \
		echo "ERROR: OPENAI_API_KEY is not set."; \
		echo "  Copy .env.example to .env and fill in your key."; \
		echo "  See: https://platform.openai.com/api-keys"; \
		echo ""; \
		exit 1; \
	fi

_check-env-volcengine:
	@if [ -z "$$VOLC_API_KEY" ]; then \
		echo ""; \
		echo "ERROR: VOLC_API_KEY is not set."; \
		echo "  Copy .env.example to .env and fill in your key."; \
		echo "  See: https://console.volcengine.com/ark/region:ark+cn-beijing/apiKey"; \
		echo ""; \
		exit 1; \
	fi
