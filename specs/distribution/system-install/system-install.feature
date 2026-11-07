@domain:distribution @area:system-install @from:port-forward-manager/makefile
Feature: Installing portfwd from a checkout
  Lets operators and packagers put the portfwd command and its man page onto a system under a chosen prefix, and take them off again.

  Background:
    Given the operator has a checkout of port-forward-manager

  @id:distribution.system-install.001 @rule:distribution.system-install.installs-command-and-man-page-under-prefix @inferred @source:Makefile#install
  Scenario Outline: Installing puts the command and its man page under the chosen prefix
    Given the prefix is <prefix>
    And the staging root is "<destdir>"
    When the operator runs make install
    Then an executable portfwd is at "<destdir><prefix>/bin/portfwd" with mode 0755
    And the man page is at "<destdir><prefix>/share/man/man1/portfwd.1" with mode 0644
    And the operator sees "installed portfwd into <destdir><prefix>/bin"

    Examples:
      | prefix       | destdir      |
      | /usr/local   |              |
      | /opt/portfwd |              |
      | /usr         | /tmp/pkgroot |

  @id:distribution.system-install.002 @rule:distribution.system-install.uninstall-removes-installed-files @inferred @source:Makefile#uninstall
  Scenario: Uninstalling removes the command and its man page from the prefix
    Given portfwd was installed under the prefix "/usr/local"
    When the operator runs make uninstall
    Then "/usr/local/bin/portfwd" no longer exists
    And "/usr/local/share/man/man1/portfwd.1" no longer exists

  @id:distribution.system-install.003 @rule:distribution.system-install.uninstall-when-not-installed-is-silent @inferred @source:Makefile#uninstall @questionable
  Scenario: Uninstalling when nothing is installed succeeds without complaint
    Given portfwd is not installed under the prefix "/opt/portfwd"
    When the operator runs make uninstall with that prefix
    Then the command exits with status 0
    And no error is shown
