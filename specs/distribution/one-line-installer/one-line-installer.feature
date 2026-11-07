@domain:distribution @area:one-line-installer @from:port-forward-manager/install
Feature: Installing portfwd with one command
  Lets an operator get the latest released portfwd onto their PATH with a single piped command, without cloning the repository.

  Background:
    Given the latest portfwd release is published on GitHub

  @id:distribution.one-line-installer.001 @rule:distribution.installer.installs-latest-release @inferred @source:install.sh#install.sh @questionable
  Scenario: The installer puts the latest released portfwd on the PATH as an executable
    Given no install directory is chosen
    When the operator runs the one-line installer
    Then portfwd from the latest release is installed at /usr/local/bin/portfwd
    And the installed portfwd is executable by everyone
    And the operator sees "portfwd installed to /usr/local/bin/portfwd"
    And the operator sees "Run: portfwd up"

  @id:distribution.one-line-installer.002 @rule:distribution.installer.custom-install-directory @inferred @source:install.sh#install.sh
  Scenario Outline: The operator can choose the directory portfwd is installed into
    Given the operator chooses the install directory "<dir>" via DEST
    When the operator runs the one-line installer
    Then portfwd is installed at "<dir>/portfwd"
    And the operator sees "portfwd installed to <dir>/portfwd"

    Examples:
      | dir                    |
      | /home/alice/.local/bin |
      | /opt/tools/bin         |

  @id:distribution.one-line-installer.003 @rule:distribution.installer.aborts-without-installing-on-failure @inferred @source:install.sh#install.sh
  Scenario Outline: A failed download or unwritable install directory stops the installer without reporting success
    Given <failure>
    When the operator runs the one-line installer
    Then the installer exits with a non-zero status
    And the operator does not see "portfwd installed to"
    And no portfwd is left at the install directory from this run

    Examples:
      | failure                                               |
      | the latest release asset cannot be downloaded         |
      | the install directory is not writable by the operator |
