@domain:protected-access @area:interrupted-sessions @from:port-forward-manager/portfwd
Feature: Recovering interrupted protected sessions
  Auditors need a closed record even when a protected session's supervisor died without a clean stop.

  @id:protected-access.interrupted-sessions.001 @rule:protected-access.interrupted-sessions.closed-as-interrupted @inferred @source:portfwd#cmd_up @questionable
  Scenario: A protected session left open by a dead supervisor is closed as interrupted
    Given protected forward "prod-db" was opened with reason "after hours"
    And its supervisor died without the forwards being stopped
    When the operator starts the profile again with --reason "back again"
    Then the audit log gains a prod-db line whose end column reads "interrupted" and whose reason is "after hours"
    And prod-db starts a new session under reason "back again"
