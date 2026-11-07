@domain:app-integration @area:env-export @from:port-forward-manager/portfwd
Feature: Exporting forwards as environment variables
  Applications get each forward's local host and port from the same profile that opens them.

  Background:
    Given a profile with forwards "db" (ports 5432:5432) and "api-gw" (ports 8080:80)

  @id:app-integration.env-export.001 @rule:app-integration.export.formats @inferred @source:portfwd#cmd_env
  Scenario Outline: Each forward is printed as a host and local port in the chosen format
    When the operator prints the profile's environment <option>
    Then the output is <output>

    Examples:
      | option               | output                                                                                                             |
      | with no format       | DB_HOST=localhost, DB_PORT=5432, API_GW_HOST=localhost, API_GW_PORT=8080, one per line                             |
      | with --format export | export DB_HOST=localhost, export DB_PORT=5432, export API_GW_HOST=localhost, export API_GW_PORT=8080, one per line |
      | with --format json   | a JSON object {"DB_HOST": "localhost", "DB_PORT": "5432", "API_GW_HOST": "localhost", "API_GW_PORT": "8080"}       |
