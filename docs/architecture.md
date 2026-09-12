# Architecture

`portfwd` is a single Bash script. No daemon, no database — just processes and a
state directory.

## Overview

`portfwd up` reads the profile, then for each forward spawns a background
**supervisor** that runs `kubectl port-forward` and restarts it whenever it
exits, until asked to stop.

## Components

- **`parse_profile`** — awk reads the YAML profile and emits one
  `name|namespace|target|ports|context|protected` row per forward. All config
  parsing lives here, including the optional `contexts:` section, which is
  folded into each row's `protected` field before it is emitted.
- **`supervise`** — per-forward loop: run `kubectl port-forward`, and on drop
  wait `PORTFWD_RECONNECT_DELAY` and retry while the `.want` marker exists.
- **State dir** (`PORTFWD_STATE_DIR`, default `$XDG_RUNTIME_DIR/portfwd-$USER`) — holds
  `<name>.pid`, `<name>.want`, `<name>.ports`, and `<name>.log` per forward,
  plus `<name>.session` while a protected forward is open.
- **`audit_open` / `audit_close`** — the protected-session record. `up` writes
  the pending half (context, namespace, target, start, reason) to
  `<name>.session`; `down` reads it back, appends the finished row to
  `$PORTFWD_AUDIT_LOG`, and removes the marker.

## Data flow

```text
portfwd.yaml ──parse_profile──▶ name|ns|target|ports|ctx|protected
                                   │            │
                                   │            └─▶ portfwd env ──▶ NAME_HOST / NAME_PORT
                             supervise &  ──▶ kubectl port-forward (retry loop)
                                   │
                          state dir: .pid/.want/.ports/.log/.session
                                   │
                          protected session ──▶ $PORTFWD_AUDIT_LOG (append)
```

`portfwd status` checks each local port with `nc`; `portfwd down` removes `.want`
markers, kills the supervisors and their children, and closes out any protected
session they held.

## Decisions

- **No YAML library** — awk parsing keeps the dependency set to bash + kubectl.
- **File-based state** — survives shell exit and lets `status`/`down` work from
  any terminal.
- **`up` refuses whole, not in part** — one protected forward without a
  `--reason` fails the run rather than starting the unprotected ones, so a
  guarded profile cannot be half-opened by habit.
- **The audit log is a file** — appended locally, mode 600, no network and no
  privileged helper. A record that needed a server would be one nobody runs;
  ship the file with whatever already ships your logs.
- **The session is closed on `down`, not by a trap** — the supervisor is a
  background job that may be killed several ways, so the record is written by
  the command that ends the session. A marker left behind by a machine that
  died is closed out with `interrupted` on the next `up`.
