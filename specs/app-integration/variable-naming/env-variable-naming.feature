@domain:app-integration @area:variable-naming @from:port-forward-manager/portfwd
Feature: Naming environment variables after forwards
  Applications get valid, predictable variable names whatever the forwards are called.

  @id:app-integration.variable-naming.001 @rule:app-integration.variable-naming.valid-uppercase-prefix @inferred @source:portfwd#env_key
  Scenario Outline: A forward name becomes a valid uppercase variable prefix
    Given a forward named "<name>"
    When the operator prints the profile's environment
    Then its variables are <prefix>_HOST and <prefix>_PORT

    Examples:
      | name     | prefix   |
      | db       | DB       |
      | api-gw   | API_GW   |
      | cache.v2 | CACHE_V2 |
      | 9kafka   | _9KAFKA  |
