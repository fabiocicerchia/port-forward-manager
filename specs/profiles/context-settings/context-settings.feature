@domain:profiles @area:context-settings @from:port-forward-manager/portfwd
Feature: Protecting a whole cluster context
  Operators mark a production context once instead of flagging each forward to it.

  @id:profiles.context-settings.001 @rule:profiles.contexts.protection-applies-wherever-declared @inferred @source:portfwd#parse_profile
  Scenario Outline: A protected context covers its forwards wherever the contexts section sits
    Given the profile marks context prod as protected in a contexts section placed <position> the forwards
    And forward "prod-db" uses context prod and declares no protection itself
    When the operator starts the profile without a reason
    Then the run is refused with status 77 naming prod-db

    Examples:
      | position |
      | before   |
      | after    |
