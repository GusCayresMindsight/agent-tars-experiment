# Smoke tests — fast pass/fail gate on provider connectivity.
# Each scenario requires only one configured API key and completes
# in a single agent run. Run these before any heavier feature suite.

@smoke
Feature: Provider connectivity
  In order to catch misconfigured keys and broken CLI installs early
  As a developer setting up the experiment
  I want a single-turn agent run to complete without error

  Background:
    Given the anthropic provider is configured

  Scenario: Agent completes a simple factual lookup end-to-end
    When I ask the agent "what is ui tars"
    Then the agent exits successfully
    And the response mentions "ByteDance"
    And the response mentions "GUI"

  Scenario: Agent identifies the project as open source
    When I ask the agent "what is ui tars"
    Then the agent exits successfully
    And the response mentions "open-source" or "open source"
