@domain:monitoring @area:health-status @from:port-forward-manager/portfwd
Feature: Checking forward health
  Developers see which forwards are reachable right now and which are protected.

  @id:monitoring.health-status.001 @rule:monitoring.status.up-or-down-by-local-port @inferred @source:portfwd#cmd_status @questionable
  Scenario Outline: Each forward is shown up or down by whether its local port answers
    Given forward "db" on ports 5432:5432 is running
    And local port 5432 <answers>
    When the operator checks status
    Then the db line reads "<line>"

    Examples:
      | answers             | line                                           |
      | accepts connections | ● db  UP    localhost:5432:5432                |
      | refuses connections | ○ db  DOWN  localhost:5432:5432 (reconnecting) |

  @id:monitoring.health-status.002 @rule:monitoring.status.protected-marker @inferred @source:portfwd#cmd_status
  Scenario: Forwards in an open protected session are marked protected
    Given "prod-db" was started as protected and "dev-db" was not
    When the operator checks status
    Then the prod-db line ends with "[protected]"
    And the dev-db line has no protected marker

  @id:monitoring.health-status.003 @rule:monitoring.status.nothing-running @inferred @source:portfwd#cmd_status
  Scenario: Status says so when nothing is running
    Given no forward is running
    When the operator checks status
    Then the output is "portfwd: nothing running"
