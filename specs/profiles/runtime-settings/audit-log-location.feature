@domain:profiles @area:runtime-settings @from:port-forward-manager/portfwd
Feature: Choosing where the audit log lives
  Operators and security teams need to know, and be able to set, where protected-session records are written.

  @id:profiles.runtime-settings.001 @rule:profiles.runtime-settings.audit-log-location @inferred @source:portfwd#cmd_up
  Scenario Outline: The audit log location follows the environment
    Given PORTFWD_AUDIT_LOG is <audit_log>
    And XDG_STATE_HOME is <state_home>
    And the profile has a protected forward
    When the operator starts the profile without a reason
    Then the refusal says the reason is logged to <location>

    Examples:
      | audit_log              | state_home       | location                                 |
      | /srv/audit/portfwd.log | unset            | /srv/audit/portfwd.log                   |
      | unset                  | /home/ops/.state | /home/ops/.state/portfwd/protected.log   |
      | unset                  | unset            | $HOME/.local/state/portfwd/protected.log |
