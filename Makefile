# Agent TARS Experiment — Makefile
# Sources .env if present; prints a message if not found for run-* targets.

-include .env
export

REPO_URL  := https://github.com/bytedance/UI-TARS-desktop
REPO_DIR  := agent-tars-cli
NODE_MIN  := 22

.PHONY: help install run-anthropic run-openai run-volcengine update clean nuke

## help: Print available targets with descriptions (default).
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## install: Shallow-clone the upstream repo if missing. Verify Node >= 22.
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
	@echo "Done. Run 'make run-anthropic' (or openai / volcengine) to start."

## run-anthropic: Run Agent TARS CLI with Anthropic (claude-3-7-sonnet-latest).
run-anthropic: _check-env-anthropic
	npx @agent-tars/cli@latest \
		--provider anthropic \
		--model claude-3-7-sonnet-latest \
		--apiKey $$ANTHROPIC_API_KEY

## run-openai: Run Agent TARS CLI with OpenAI (gpt-4o).
run-openai: _check-env-openai
	npx @agent-tars/cli@latest \
		--provider openai \
		--model gpt-4o \
		--apiKey $$OPENAI_API_KEY

## run-volcengine: Run Agent TARS CLI with Volcengine / Doubao.
run-volcengine: _check-env-volcengine
	npx @agent-tars/cli@latest \
		--provider volcengine \
		--model doubao-1-5-thinking-vision-pro-250428 \
		--apiKey $$VOLC_API_KEY

## update: Pull latest changes in the cloned reference repo (fast-forward only).
update:
	@if [ ! -d "$(REPO_DIR)/.git" ]; then \
		echo "$(REPO_DIR)/ not found — run 'make install' first."; exit 1; \
	fi
	git -C "$(REPO_DIR)" pull --ff-only

## clean: Remove any stray caches or node_modules.
clean:
	rm -rf node_modules .npm $(REPO_DIR)/node_modules $(REPO_DIR)/.turbo

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
