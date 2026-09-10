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
