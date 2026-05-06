'use strict';

const { setWorldConstructor, World } = require('@cucumber/cucumber');

/**
 * AgentWorld — shared state for one Cucumber scenario.
 *
 * run         — provider config resolved by the Given step
 * stdout      — captured standard output from the last agent invocation
 * stderr      — captured standard error from the last agent invocation
 * exitCode    — process exit code from the last agent invocation
 */
class AgentWorld extends World {
  constructor(options) {
    super(options);
    this.run = null;
    this.stdout = '';
    this.stderr = '';
    this.exitCode = null;
  }
}

setWorldConstructor(AgentWorld);
