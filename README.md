# agent-tars-experiment

## What this is

A BDD sandbox for [Agent TARS](https://agent-tars.com) — ByteDance's open-source
multimodal agent framework with browser control, vision, MCP integration, and a Web UI.
Feature descriptions are first class: Gherkin `.feature` files define what the agent
should be able to do; step definitions implement the assertions; the Makefile and CLI
are the execution layer. The CLI (`@agent-tars/cli`) is model-agnostic — this repo
wires it to Anthropic, OpenAI, and Volcengine (Doubao). Upstream:
<https://github.com/bytedance/UI-TARS-desktop>

## Prerequisites

- Node.js ≥ 22 and npm
- git
- At least one provider API key (Anthropic, OpenAI, or Volcengine)

## Quickstart

```sh
cp .env.example .env          # 1. copy the template
$EDITOR .env                  # 2. fill in at least one API key
make install                  # 3. clone upstream ref + npm install (applies patches)
make test-smoke               # 4. fast connectivity check
```

## Structure

```
features/                     # 1st — behaviour descriptions (Gherkin)
  smoke.feature               #   fast connectivity gate
  research.feature            #   multi-turn web research
  step_definitions/           # 2nd — test implementation
    agent.steps.js
  support/                    # Cucumber World + hooks
    world.js
    hooks.js
patches/                      # patch-package fix for @agent-tars/core 0.3.0
Makefile                      # 3rd — run targets
```

> **Note on the patch:** `@agent-tars/core@0.3.0` has a bug in its Anthropic
> streaming handler (`convertMessages`) that causes a `SyntaxError` after a few
> tool-call iterations. `patches/@agent-tars+core+0.3.0.patch` fixes it and is
> applied automatically by `npm install` via `patch-package`. A fix has been
> submitted upstream at <https://github.com/bytedance/UI-TARS-desktop/pull/1879>.

## Make targets

| Target | Description |
|---|---|
| `help` | Print available targets (default) |
| `install` | Clone upstream repo if missing; `npm install` |
| `test` | Run all BDD feature scenarios |
| `test-smoke` | Run `@smoke` scenarios only |
| `test-research` | Run `@research` scenarios only |
| `run-anthropic` | Interactive Web UI with Anthropic (`claude-sonnet-4-5`) |
| `run-openai` | Interactive Web UI with OpenAI (`gpt-4o`) |
| `run-volcengine` | Interactive Web UI with Volcengine (`doubao-1-5-thinking-vision-pro-250428`) |
| `update` | Pull latest changes in the reference clone |
| `clean` | Remove `node_modules`, caches, reports |
| `nuke` | `clean` + delete the `agent-tars-cli/` checkout |

## Links

- Upstream repo: <https://github.com/bytedance/UI-TARS-desktop>
- Agent TARS site: <https://agent-tars.com>
- UI-TARS paper: <https://arxiv.org/abs/2501.12326>
- UI-TARS-2 paper: <https://arxiv.org/abs/2509.02544>
