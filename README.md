# agent-tars-experiment

## What this is

A minimal sandbox for running [Agent TARS](https://agent-tars.com) — ByteDance's
open-source multimodal agent framework with browser control, vision, MCP integration,
and a built-in Web UI. The CLI (`@agent-tars/cli`) is model-agnostic; this repo wires
it to Anthropic, OpenAI, and Volcengine (Doubao) via a simple Makefile. The upstream
monorepo is cloned to `agent-tars-cli/` for reference and local hacking only — actual
runs use the published npm package. Upstream: <https://github.com/bytedance/UI-TARS-desktop>

## Prerequisites

- Node.js ≥ 22 and npm
- git
- At least one provider API key (Anthropic, OpenAI, or Volcengine)

## Quickstart

```sh
cp .env.example .env          # 1. copy the template
$EDITOR .env                  # 2. fill in at least one API key
make install && make run-anthropic  # 3. launch
```

The CLI will print a local Web UI URL (e.g. `http://localhost:8888`). Open it,
enter a prompt, and watch the agent go.

## Make targets

| Target | Description |
|---|---|
| `help` | Print available targets (default) |
| `install` | Clone upstream repo if missing; verify Node ≥ 22 |
| `run-anthropic` | Run CLI with Anthropic (`claude-3-7-sonnet-latest`) |
| `run-openai` | Run CLI with OpenAI (`gpt-4o`) |
| `run-volcengine` | Run CLI with Volcengine (`doubao-1-5-thinking-vision-pro-250428`) |
| `update` | Pull latest changes in the reference clone |
| `clean` | Remove stray caches and `node_modules` |
| `nuke` | `clean` + delete the `agent-tars-cli/` checkout |

## Links

- Upstream repo: <https://github.com/bytedance/UI-TARS-desktop>
- Agent TARS site: <https://agent-tars.com>
- UI-TARS paper: <https://arxiv.org/abs/2501.12326>
- UI-TARS-2 paper: <https://arxiv.org/abs/2509.02544>
