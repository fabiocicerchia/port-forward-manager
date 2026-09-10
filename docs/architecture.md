# Architecture

`portfwd` is a single Bash script. No daemon, no database — just processes and a
state directory.

## Overview

`portfwd up` reads the profile, then for each forward spawns a background
**supervisor** that runs `kubectl port-forward` and restarts it whenever it
exits, until asked to stop.

## Components

- **`parse_profile`** — awk reads the YAML profile and emits one
  `name|namespace|target|ports|context` row per forward. All config parsing
  lives here.
- **`supervise`** — per-forward loop: run `kubectl port-forward`, and on drop
  wait `PORTFWD_RECONNECT_DELAY` and retry while the `.want` marker exists.
- **State dir** (`PORTFWD_STATE_DIR`, default `$XDG_RUNTIME_DIR/portfwd-$USER`) — holds
  `<name>.pid`, `<name>.want`, `<name>.ports`, and `<name>.log` per forward.

## Data flow

```text
portfwd.yaml ──parse_profile──▶ name|ns|target|ports|ctx
                                   │
                             supervise &  ──▶ kubectl port-forward (retry loop)
                                   │
                          state dir: .pid/.want/.ports/.log
```

`portfwd status` checks each local port with `nc`; `portfwd down` removes `.want`
markers and kills the supervisors and their children.

## Decisions

- **No YAML library** — awk parsing keeps the dependency set to bash + kubectl.
- **File-based state** — survives shell exit and lets `status`/`down` work from
  any terminal.
