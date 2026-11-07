@domain:monitoring @area:forward-logs @from:port-forward-manager/portfwd
Feature: Following a forward's log
  Developers debugging a flaky forward watch its connections and reconnections live.

  @id:monitoring.forward-logs.001 @rule:monitoring.logs.follow-one-forward @inferred @source:portfwd#cmd_logs
  Scenario: The operator can follow one forward's log live
    Given forward "db" has been started
    When the operator follows the logs of db
    Then the last lines of db's log are shown: its connecting and reconnecting lines and kubectl output
    And new lines appear as they are written until the operator stops
