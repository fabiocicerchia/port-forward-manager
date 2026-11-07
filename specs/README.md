# Specifications of port-forward-manager

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## App integration
Handing forward connection details to other tools and applications.

- **Environment export**: [Exporting forwards as environment variables](app-integration/env-export/env-export.feature) (1)
- **Variable naming**: [Naming environment variables after forwards](app-integration/variable-naming/env-variable-naming.feature) (1)

## Command-line experience
How the command presents itself and reports misuse.

- **Built-in help**: [Built-in help](cli/built-in-help/built-in-help.feature) (1)
- **Usage errors & exit codes**: [Refusing wrong invocations](cli/usage-errors/usage-errors.feature) (1)

## Installation & distribution
Getting portfwd onto a machine or into a container.

- **Container image**: [Running portfwd from the container image](distribution/container-image/container-image.feature) (4)
- **One-line installer**: [Installing portfwd with one command](distribution/one-line-installer/one-line-installer.feature) (3)
- **System install**: [Installing portfwd from a checkout](distribution/system-install/system-install.feature) (3)

## Documentation site
The look and feel of the project's published documentation.

- **Theme & palette**: [Branding the documentation site](documentation-site/theme-palette/docs-site-branding.feature) (4)

## Port forwarding
Opening, keeping alive and closing the set of port-forwards defined in a profile.

- **Auto-reconnect**: [Reconnecting dropped forwards](forwarding/auto-reconnect/auto-reconnect.feature) (1)
- **Foreground mode**: [Running as a container's main process](forwarding/foreground-mode/foreground-mode.feature) (1)
- **Starting forwards**: [Starting forwards](forwarding/start-forwards/start-forwards.feature) (3)
- **Stopping forwards**: [Stopping forwards](forwarding/stop-forwards/stop-forwards.feature) (1)

## Monitoring
Seeing whether forwards are healthy and what they are doing.

- **Forward logs**: [Following a forward's log](monitoring/forward-logs/forward-logs.feature) (1)
- **Health status**: [Checking forward health](monitoring/health-status/health-status.feature) (3)

## Profiles & configuration
How users describe which port-forwards they want and how the tool finds and reads that description.

- **Cluster context settings**: [Protecting a whole cluster context](profiles/context-settings/context-settings.feature) (1)
- **Forward definitions**: [Declaring forwards in a profile](profiles/forward-definitions/forward-definitions.feature) (2)
- **Profile discovery**: [Finding the profile](profiles/profile-discovery/profile-discovery.feature) (3)
- **Runtime settings**: [Choosing where the audit log lives](profiles/runtime-settings/audit-log-location.feature) (1)

## Protected access & audit
Guarding sensitive forwards, such as production, behind a stated reason and keeping a record of every session.

- **Interrupted session recovery**: [Recovering interrupted protected sessions](protected-access/interrupted-sessions/interrupted-protected-sessions.feature) (1)
- **Reason requirement**: [Opening protected forwards only with a reason](protected-access/reason-gate/protected-reason-gate.feature) (4)
- **Session audit log**: [Auditing protected sessions](protected-access/session-audit-log/protected-session-audit-log.feature) (3)
