# AGENTS.md

Operational knowledge for AI agents working in this repository.
Last updated by an agent session that set the whole thing up.

---

## What this repo is

A BDD experiment sandbox for **Agent TARS** (`@agent-tars/cli`), ByteDance's
open-source multimodal agent CLI. The CLI takes a natural language prompt and
runs an agentic loop: it plans, calls browser/filesystem/shell tools, and
synthesises a written answer. It ships a local Web UI and a headless mode.

The repo is structured in three layers:

| Layer | Path | Purpose |
|---|---|---|
| Behaviour | `features/*.feature` | Gherkin specs — what the agent should do |
| Tests | `features/step_definitions/`, `features/support/` | Cucumber.js step implementations |
| Execution | `Makefile`, `package.json` | Running, installing, cleaning |

---

## Common commands

```bash
make install          # clone upstream ref + npm install (applies patches)
make test-smoke       # fast pass/fail gate — run this first
make test             # full feature suite
make test-research    # web research scenarios only
make run-anthropic    # interactive Web UI, Anthropic provider
make help             # full target list
```

Tests run the CLI in headless mode (`--headless --input "..." --format text`) via
`spawnSync` with a 120 s timeout. The agent's stdout is what step assertions check.

---

## Known bugs in @agent-tars/core 0.3.0 (Anthropic provider)

Both bugs are in `convertMessages` inside
`multimodal/tarko/llm-client/src/handlers/anthropic.ts` (the function that
re-encodes the OpenAI-format message history into Anthropic's native format
before each LLM request).

### Bug 1 — `SyntaxError: Unexpected end of JSON input`

**Trigger:** any prompt that requires more than ~3 tool-call iterations.

**Root cause:** the streaming accumulator stores `arguments` as `""` (empty
string) when Anthropic emits a `content_block_start` whose `input` is `{}`.
On the next iteration `convertMessages` calls `JSON.parse("")` which throws.

**Fix:**
```diff
- input: JSON.parse(toolCall.function.arguments),
+ input: JSON.parse(toolCall.function.arguments || '{}'),
```

The downstream callers in `tool-processor.ts` already apply this fallback;
`convertMessages` was the only caller that didn't.

### Bug 2 — 400 `messages: text content blocks must be non-empty`

**Trigger:** follows from Bug 1's fix — the assistant message that carries tool
calls also has `content: ""`. Without the guard above, the JSON crash hit first
and masked this. With Bug 1 fixed, the API rejects the empty text block.

**Fix:**
```diff
- if (typeof message.content === 'string') {
+ if (typeof message.content === 'string' && message.content) {
```

### How the fix is maintained

`patches/@agent-tars+core+0.3.0.patch` captures both changes via `patch-package`.
`npm install` applies it automatically through the `postinstall` hook. If upstream
ships a fix, delete the patch file, remove `patch-package` from `devDependencies`,
and drop the `postinstall` script.

Upstream reference: <https://github.com/bytedance/UI-TARS-desktop/pull/1879>
(PR closed without CLA; fix provided as a comment under Apache 2.0.)

---

## Provider behaviour

| Provider | Model used | Browser control mode | Notes |
|---|---|---|---|
| `anthropic` | `claude-sonnet-4-5` | `dom` (forced) | Vision/hybrid not supported; CLI switches automatically |
| `openai` | `gpt-4o` | `dom` | Marked experimental / lower stability by upstream |
| `volcengine` | `doubao-1-5-thinking-vision-pro-250428` | `hybrid` / visual grounding | Only provider with vision-based browser control |

The `anthropic` and `openai` providers use DOM-based browser control. Only
Volcengine's Doubao models support the visual grounding ("hybrid") mode that
UI-TARS was originally designed around.

---

## CLI flags worth knowing

```
--headless            Run without Web UI; print result to stdout
--input "..."         Pass prompt directly (required in headless mode)
--format text|json    Output format in headless mode (default: text)
--debug               Verbose logging — tool calls, iteration count, LLM requests
--thinking            Enable model reasoning/thinking mode
--port <n>            Override default server port (8899)
--open                Auto-open browser when Web UI starts
```

`--format json` gives structured output that is easier to assert on programmatically
if you need to add richer step definitions.

---

## Recommended test prompts (graduated by complexity)

| Level | Prompt | What it exercises |
|---|---|---|
| Smoke | `"what is ui tars"` | Single web search + markdown extraction + synthesis |
| Research | `"tell me the top 5 most popular projects on ProductHunt today"` | Multi-page browser navigation + written report (official quickstart example) |
| Data + viz | `"tell me nvidia's stock price today"` | Search + numerical data extraction |
| Multi-step | `"7-day trip plan to Mexico City from NYC"` | Multi-turn planning + structured output |
| Booking | `"book the earliest flight from San Jose to New York on September 1st on Priceline"` | Form interaction + live site navigation |

Start with the smoke prompt. It reliably completes in 1–2 minutes and is the
one scenario in the upstream snapshot test suite.

---

## Adding a new feature

1. Write a `.feature` file in `features/` with a `@tag` and Gherkin scenarios.
2. If you need a new step pattern, add it to
   `features/step_definitions/agent.steps.js`.
3. The existing steps cover:
   - `Given the {word} provider is configured` — resolves API key from env; marks
     scenario pending (skipped) if the key is absent.
   - `When I ask the agent {string}` — runs headless CLI, captures stdout/stderr.
   - `Then the agent exits successfully` — asserts exit code 0.
   - `Then the response mentions {string}` — case-insensitive substring match on stdout.
   - `Then the response mentions {string} or {string}` — either/or variant.

Run `make test-smoke` after any change as a quick sanity check.

---

## What lives in agent-tars-cli/

A shallow clone of `https://github.com/bytedance/UI-TARS-desktop` — the upstream
monorepo. The Agent TARS CLI source is at `multimodal/agent-tars/`. This clone
is for reference and local hacking only; actual test runs use the installed
`node_modules/.bin/agent-tars` binary (which has the patch applied).

The clone is gitignored. Restore it with `make install`.

---

## What NOT to do

- Do not commit `.env` — it is gitignored for a reason.
- Do not run `npx @agent-tars/cli@latest` directly — it bypasses the patch.
  Use `./node_modules/.bin/agent-tars` or the Makefile targets.
- Do not `npm install` a pinned version of `@agent-tars/cli` — keep `latest`
  so the package tracks the upstream beta.
- Do not add Docker, CI, or providers beyond anthropic / openai / volcengine.
