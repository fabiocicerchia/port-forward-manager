@domain:cli @area:built-in-help @from:port-forward-manager/portfwd
Feature: Built-in help
  New users see usage and the profile format straight from the command.

  @id:cli.built-in-help.001 @rule:cli.help.usage-on-unknown-command @inferred @source:portfwd#portfwd @questionable
  Scenario Outline: Running without a known command prints usage and the profile format
    When the operator runs portfwd <invocation>
    Then the usage for up, env, status, logs and down is printed
    And the profile format and the protected-forward example are printed
    And the command exits with status 0

    Examples:
      | invocation      |
      | with no command |
      | help            |
      | restart         |
