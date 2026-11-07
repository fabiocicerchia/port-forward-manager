@domain:profiles @area:profile-discovery @from:port-forward-manager/portfwd
Feature: Finding the profile
  Operators run portfwd with an explicit profile or rely on a project or personal default.

  @id:profiles.profile-discovery.001 @rule:profiles.discovery.search-order @inferred @source:portfwd#find_profile
  Scenario Outline: The profile is taken from the explicit path, then the working directory, then the user default
    Given <available>
    When the operator starts forwards <invocation>
    Then the output says portfwd: profile <used>

    Examples:
      | available                                                          | invocation               | used                               |
      | team.yaml, ./portfwd.yaml and ~/.config/portfwd/default.yaml exist | naming team.yaml         | team.yaml                          |
      | ./portfwd.yaml and ~/.config/portfwd/default.yaml exist            | without naming a profile | ./portfwd.yaml                     |
      | only ~/.config/portfwd/default.yaml exists                         | without naming a profile | $HOME/.config/portfwd/default.yaml |

  @id:profiles.profile-discovery.002 @rule:profiles.discovery.none-found @inferred @source:portfwd#find_profile
  Scenario: Without any profile the command is refused
    Given no named profile, no ./portfwd.yaml and no ~/.config/portfwd/default.yaml exist
    When the operator starts forwards
    Then the command exits with status 64
    And the message reads portfwd: no profile found (./portfwd.yaml or ~/.config/portfwd/default.yaml)

  @id:profiles.profile-discovery.003 @rule:profiles.discovery.missing-explicit-path-falls-back @inferred @source:portfwd#find_profile @questionable
  Scenario: A named profile that does not exist silently falls back to a default
    Given the named profile staging.yaml does not exist
    And ./portfwd.yaml exists
    When the operator starts forwards naming staging.yaml
    Then the output says portfwd: profile ./portfwd.yaml
    And no warning about staging.yaml is shown
