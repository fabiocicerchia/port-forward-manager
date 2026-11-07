@domain:distribution @area:container-image @from:port-forward-manager/dockerfile
Feature: Running portfwd from the container image
  Lets operators run portfwd and its kubectl tooling from one minimal image without installing anything on the host, under an unprivileged account.

  Background:
    Given the operator has the portfwd container image

  @id:distribution.container-image.001 @rule:distribution.container-image.default-command-shows-help @inferred @source:Dockerfile#CMD
  Scenario: Running the image without a command shows the built-in help
    When the operator runs the image without naming a command
    Then portfwd prints its usage and profile format help
    And no forward is started

  @id:distribution.container-image.002 @rule:distribution.container-image.arguments-are-portfwd-commands @inferred @source:Dockerfile#ENTRYPOINT
  Scenario Outline: Arguments given to the image are run as portfwd commands
    Given the operator's kubeconfig is mounted read-only into the container's home .kube directory
    When the operator runs the image with "<command>"
    Then the container runs "portfwd <command>"

    Examples:
      | command           |
      | up                |
      | status            |
      | env --format=json |
      | down              |

  @id:distribution.container-image.003 @rule:distribution.container-image.runs-as-non-root @inferred @source:Dockerfile#USER
  Scenario: The container runs portfwd as an unprivileged user
    When the operator starts a container from the image
    Then portfwd runs as user "app" with uid 10001, not as root
    And the working directory is /home/app

  @id:distribution.container-image.004 @rule:distribution.container-image.no-health-check @inferred @source:Dockerfile#HEALTHCHECK @questionable
  Scenario: The image reports no container health status
    Given a container from the image is running forwards
    When the operator inspects the container's health
    Then no health status is reported for the container
    And the operator checks forwards by running portfwd status inside the container instead
