@domain:forwarding @area:auto-reconnect @from:port-forward-manager/portfwd
Feature: Reconnecting dropped forwards
  Developers keep working through flaky connections because a dropped forward comes back on its own.

  @id:forwarding.auto-reconnect.001 @rule:forwarding.auto-reconnect.reconnect-after-delay @inferred @source:portfwd#supervise
  Scenario Outline: A dropped forward reconnects after the configured delay
    Given forward "db" is running
    And PORTFWD_RECONNECT_DELAY is <setting>
    When db's connection drops
    Then db's log shows "dropped, reconnecting in <delay>s"
    And after <delay> seconds the log shows a new connecting line and db connects again

    Examples:
      | setting | delay |
      | unset   | 2     |
      | 5       | 5     |
