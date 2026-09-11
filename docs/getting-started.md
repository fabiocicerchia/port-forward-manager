# Getting Started

## Prerequisites

- `bash`, `kubectl`, `nc`, `awk`
- A working kube context (`kubectl get pods` should succeed)

## Install

```sh
make install          # copies portfwd to /usr/local/bin
```

## Configure

Create `./portfwd.yaml` (per-project) or `~/.config/portfwd/default.yaml` (global).
Start from [`portfwd.example.yaml`](https://github.com/fabiocicerchia/port-forward-manager/blob/main/portfwd.example.yaml):

```yaml
forwards:
  - name: db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
```

## Run

```sh
portfwd up          # start every forward in the profile
portfwd status      # UP/DOWN per forward
portfwd logs db     # tail one forward
portfwd down        # stop everything
```

Tune with `PORTFWD_STATE_DIR` and `PORTFWD_RECONNECT_DELAY` (see `.env.example`).

## Generate a .env from the profile

The profile already knows which local port every service lands on, so it can
print the variables your app reads instead of you keeping a second file in step:

```sh
portfwd env > .env                       # DB_HOST=localhost, DB_PORT=5432, ...
portfwd env --format export > .envrc     # export DB_HOST=localhost, ...
portfwd env --format json                # for anything that speaks JSON
eval "$(portfwd env --format export)"    # or straight into this shell
```

The key is the forward's `name`, uppercased, with anything that is not a letter
or a digit replaced by `_` (`api-gw` becomes `API_GW_HOST` / `API_GW_PORT`).
