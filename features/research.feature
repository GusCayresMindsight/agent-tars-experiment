# Research tasks — the agent searches the web, navigates pages,
# and synthesises a coherent written answer.
# These run longer than smoke tests and exercise the full browser loop.

@research
Feature: Web research
  In order to automate information gathering
  As a user of Agent TARS
  I want the agent to search the web and return accurate, synthesised answers

  Background:
    Given the anthropic provider is configured

  Scenario: Research a known open-source AI project
    When I ask the agent "what is ui tars"
    Then the agent exits successfully
    And the response mentions "ByteDance"
    And the response mentions "GUI"
    And the response mentions "open-source" or "open source"

  Scenario: Retrieve benchmark performance data
    When I ask the agent "what benchmarks has ui tars achieved"
    Then the agent exits successfully
    And the response mentions "OSWorld" or "benchmark"

  Scenario: Look up the upstream repository
    When I ask the agent "where is the ui tars source code hosted"
    Then the agent exits successfully
    And the response mentions "github"
