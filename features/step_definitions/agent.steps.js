'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { spawnSync } = require('child_process');
const assert = require('assert');
const { resolve } = require('path');

const CLI = resolve(__dirname, '../../node_modules/.bin/agent-tars');

const PROVIDERS = {
  anthropic: {
    provider: 'anthropic',
    model: 'claude-sonnet-4-5',
    envKey: 'ANTHROPIC_API_KEY',
  },
  openai: {
    provider: 'openai',
    model: 'gpt-4o',
    envKey: 'OPENAI_API_KEY',
  },
  volcengine: {
    provider: 'volcengine',
    model: 'doubao-1-5-thinking-vision-pro-250428',
    envKey: 'VOLC_API_KEY',
  },
};

// ---------------------------------------------------------------------------
// Given
// ---------------------------------------------------------------------------

Given('the {word} provider is configured', function (name) {
  const cfg = PROVIDERS[name];
  if (!cfg) throw new Error(`Unknown provider: "${name}". Known: ${Object.keys(PROVIDERS).join(', ')}`);

  const apiKey = process.env[cfg.envKey];
  if (!apiKey) {
    // Skip rather than fail — lets the suite run even with partial key setup.
    return 'pending';
  }

  this.run = { ...cfg, apiKey };
});

// ---------------------------------------------------------------------------
// When
// ---------------------------------------------------------------------------

When('I ask the agent {string}', function (prompt) {
  const { provider, model, apiKey } = this.run;

  const result = spawnSync(
    CLI,
    [
      '--provider', provider,
      '--model', model,
      '--apiKey', apiKey,
      '--headless',
      '--input', prompt,
      '--format', 'text',
    ],
    {
      timeout: 120_000,
      encoding: 'utf8',
      env: process.env,
    },
  );

  this.stdout = result.stdout ?? '';
  this.stderr = result.stderr ?? '';
  this.exitCode = result.status ?? -1;

  if (result.error) {
    throw new Error(`Agent process error: ${result.error.message}`);
  }
});

// ---------------------------------------------------------------------------
// Then
// ---------------------------------------------------------------------------

Then('the agent exits successfully', function () {
  assert.strictEqual(
    this.exitCode,
    0,
    `Agent exited with code ${this.exitCode}\n--- stderr ---\n${this.stderr.slice(0, 800)}`,
  );
});

Then('the response mentions {string}', function (expected) {
  const haystack = this.stdout.toLowerCase();
  assert.ok(
    haystack.includes(expected.toLowerCase()),
    `Expected response to mention "${expected}"\n--- response ---\n${this.stdout.slice(0, 600)}`,
  );
});

// Accepts "X or Y" alternatives without needing separate scenarios.
Then('the response mentions {string} or {string}', function (a, b) {
  const haystack = this.stdout.toLowerCase();
  const found = haystack.includes(a.toLowerCase()) || haystack.includes(b.toLowerCase());
  assert.ok(
    found,
    `Expected response to mention "${a}" or "${b}"\n--- response ---\n${this.stdout.slice(0, 600)}`,
  );
});
