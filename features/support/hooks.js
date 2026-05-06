'use strict';

const { BeforeAll } = require('@cucumber/cucumber');
const { existsSync } = require('fs');
const { resolve } = require('path');

BeforeAll(function () {
  const cli = resolve(__dirname, '../../node_modules/.bin/agent-tars');
  if (!existsSync(cli)) {
    throw new Error(
      'agent-tars binary not found.\n' +
      'Run: npm install\n' +
      `Expected at: ${cli}`,
    );
  }
});
