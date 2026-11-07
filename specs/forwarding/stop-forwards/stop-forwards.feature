@domain:forwarding @area:stop-forwards @from:port-forward-manager/portfwd
Feature: Stopping forwards
  Operators shut every forward down at once and are sure nothing keeps reconnecting.

  @id:forwarding.stop-forwards.001 @rule:forwarding.stop.stops-all @inferred @source:portfwd#cmd_down
  Scenario: Stopping ends every forward and it does not reconnect
    Given forwards "db" and "api" are running
    When the operator stops all forwards
    Then the output shows "portfwd: stopped db" and "portfwd: stopped api"
    And no port-forward connection is left running
    And status reports "portfwd: nothing running"
