@domain:profiles @area:forward-definitions @from:port-forward-manager/portfwd
Feature: Declaring forwards in a profile
  Operators describe each forward in a small YAML profile and expect what they wrote to be what runs.

  @id:profiles.forward-definitions.001 @rule:profiles.forwards.block-and-inline-styles @inferred @source:portfwd#parse_profile
  Scenario Outline: Block and inline forward entries are read the same way
    Given the profile declares forward "db" <style>
    When the operator starts the profile
    Then db is started as svc/postgres (ns data) on 5432:5432

    Examples:
      | style                                                             |
      | with name, target, namespace and ports on separate indented lines |
      | with name, target, namespace and ports all on the "- name:" line  |

  @id:profiles.forward-definitions.002 @rule:profiles.forwards.incomplete-entry-ignored @inferred @source:portfwd#parse_profile @questionable
  Scenario: A forward missing its name, target or ports is silently left out
    Given the profile declares "db" fully and "cache" without ports
    When the operator starts the profile
    Then only db is started
    And the summary reads portfwd: 1 forward(s) started.
    And no warning mentions cache
