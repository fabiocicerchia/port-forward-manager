@domain:protected-access @area:session-audit-log @from:port-forward-manager/portfwd
Feature: Auditing protected sessions
  Security and compliance reviewers rely on a private local record of who opened which protected forward, where, when, and why.

  Background:
    Given the operator started a profile with protected forwards using --reason "incident 4711"

  @id:protected-access.session-audit-log.001 @rule:protected-access.audit-log.one-record-per-session @inferred @source:portfwd#audit_close
  Scenario: Stopping a protected forward records exactly one session line
    Given protected forward "prod-db" targets svc/postgres in namespace data on context prod
    When the operator stops all forwards
    Then the audit log gains one line per protected forward
    And the prod-db line holds, tab separated: prod, data, svc/postgres, the operator's user name, the UTC start time, the UTC end time, incident 4711
    And unprotected forwards add no line

  @id:protected-access.session-audit-log.002 @rule:protected-access.audit-log.owner-only @inferred @source:portfwd#audit_close @questionable
  Scenario: The audit log is readable only by its owner
    Given no audit log exists yet
    When the operator stops all forwards
    Then the audit log is created with permissions 600

  @id:protected-access.session-audit-log.003 @rule:protected-access.audit-log.columns-stay-intact @inferred @source:portfwd#audit_open
  Scenario Outline: A reason cannot break the audit log's columns
    Given the reason given was "<reason>"
    And the protected forward has <scope>
    When the operator stops all forwards
    Then the reason column reads "<logged_reason>"
    And the context and namespace columns read "<logged_scope>"

    Examples:
      | reason                    | scope                           | logged_reason     | logged_scope |
      | incident<TAB>4711         | context prod and namespace data | incident 4711     | prod, data   |
      | line one<NEWLINE>line two | no context and no namespace     | line one line two | -, -         |
      | ticket|OPS-12             | context prod and namespace data | ticket|OPS-12     | prod, data   |
