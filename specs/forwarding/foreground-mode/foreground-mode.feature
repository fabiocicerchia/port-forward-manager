@domain:forwarding @area:foreground-mode @from:port-forward-manager/portfwd
Feature: Running as a container's main process
  Teams running portfwd as a container entrypoint need it to stay up and shut down cleanly on stop.

  @id:forwarding.foreground-mode.001 @rule:forwarding.foreground.pid1-blocks-and-stops-on-signal @inferred @source:portfwd#cmd_up
  Scenario: As the main process, portfwd stays in the foreground and stops everything on termination
    Given portfwd started a profile as the container's main process
    When the container runtime sends a termination or interrupt signal
    Then every forward is stopped and reported as stopped
    And portfwd exits with status 0
