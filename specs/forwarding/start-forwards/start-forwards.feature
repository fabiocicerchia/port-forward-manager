@domain:forwarding @area:start-forwards @from:port-forward-manager/portfwd
Feature: Starting forwards
  Developers and operators bring up every forward in a profile with one command and see what started.

  Background:
    Given a profile with forwards "db" (svc/postgres, namespace data, ports 5432:5432) and "api" (deploy/api, ports 8080:80)

  @id:forwarding.start-forwards.001 @rule:forwarding.start.reports-each-forward @inferred @source:portfwd#cmd_up
  Scenario: Starting a profile reports each forward and how many started
    Given nothing is running
    When the operator starts the profile
    Then the output names the profile file used
    And it shows "db: svc/postgres (ns data) on 5432:5432" and "api: deploy/api on 8080:80"
    And it ends with "portfwd: 2 forward(s) started." and points to status and down

  @id:forwarding.start-forwards.002 @rule:forwarding.start.skip-running @inferred @source:portfwd#cmd_up
  Scenario: A forward that is already running is not started twice
    Given "db" is already running
    When the operator starts the profile
    Then the output shows "db: already running"
    And only api is started
    And the summary reads "portfwd: 1 forward(s) started."

  @id:forwarding.start-forwards.003 @rule:forwarding.start.connects-declared-target @inferred @source:portfwd#supervise
  Scenario: Each forward connects to its declared target, ports, namespace and context
    Given "api" also declares context staging
    When the operator starts the profile
    Then db's log shows connecting: kubectl port-forward svc/postgres 5432:5432 -n data
    And api's log shows connecting: kubectl port-forward deploy/api 8080:80 --context staging
