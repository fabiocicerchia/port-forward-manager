@domain:protected-access @area:reason-gate @from:port-forward-manager/portfwd
Feature: Opening protected forwards only with a reason
  Operators responsible for production clusters need every forward into a protected context or service to be opened deliberately, with a stated reason, or not at all.

  Background:
    Given a profile whose forwards include protected ones

  @id:protected-access.reason-gate.001 @rule:protected-access.reason-gate.reason-required @inferred @source:portfwd#cmd_up
  Scenario Outline: A profile with protected forwards is refused without a reason
    Given the profile has a forward "<forward>" that is <protected_by>
    When the operator starts the profile without a reason
    Then the command exits with status 77
    And the refusal lists "<forward>" as protected in this profile
    And the refusal says opening a protected forward needs --reason "<why>" and names the audit log it is logged to

    Examples:
      | forward  | protected_by                                            |
      | prod-db  | targeting context prod, which is marked protected: true |
      | payments | marked protected: true on its own                       |

  @id:protected-access.reason-gate.002 @rule:protected-access.reason-gate.refusal-starts-nothing @inferred @source:portfwd#cmd_up
  Scenario: A refused run opens no forward at all, not even unprotected ones
    Given the profile also has an unprotected forward "dev-db"
    When the operator starts the profile without a reason
    Then no forward is started, "dev-db" included
    And status reports nothing running
    And nothing is written to the audit log

  @id:protected-access.reason-gate.003 @rule:protected-access.reason-gate.reason-opens-all @inferred @source:portfwd#cmd_up
  Scenario: With a reason every forward starts and protected ones are flagged
    When the operator starts the profile with --reason "incident 4711"
    Then every forward in the profile is started
    And each protected forward's start line ends with "[protected]"
    And unprotected forwards carry no protected marker

  @id:protected-access.reason-gate.004 @rule:protected-access.reason-gate.only-literal-true-protects @inferred @source:portfwd#parse_profile @questionable
  Scenario Outline: Only the value true marks a forward or context as protected
    Given the profile has a forward "payments" with protected: <value>
    When the operator starts the profile without a reason
    Then the run is <outcome>

    Examples:
      | value  | outcome                            |
      | true   | refused with status 77             |
      | "true" | refused with status 77             |
      | yes    | started, with payments unprotected |
      | True   | started, with payments unprotected |
