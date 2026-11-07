@domain:cli @area:usage-errors @from:port-forward-manager/portfwd
Feature: Refusing wrong invocations
  Operators and scripts get a clear message and a standard exit code when portfwd is called wrong.

  @id:cli.usage-errors.001 @rule:cli.usage-errors.exit-64 @inferred @source:portfwd#cmd_up
  Scenario Outline: A wrong invocation is refused with a message and status 64
    When the operator runs portfwd <invocation>
    Then the message reads <message>
    And the command exits with status 64

    Examples:
      | invocation        | message                                             |
      | up --force        | portfwd: unknown option --force                     |
      | up --reason       | portfwd: --reason needs a value                     |
      | env --format      | portfwd: --format needs a value                     |
      | env --format yaml | portfwd: unknown format 'yaml' (dotenv|export|json) |
      | logs              | portfwd: usage: portfwd logs NAME                   |
