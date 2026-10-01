const { defineConfig } = require('@playwright/test');
const { defineBddConfig } = require('playwright-bdd');

// These scenarios exercise pure domain logic (no browser), so no browser project is needed.
const testDir = defineBddConfig({
  features: 'features/**/*.feature',
  steps: 'steps/**/*.js',
});

module.exports = defineConfig({ testDir, reporter: 'line' });
