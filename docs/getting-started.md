# Getting Started

## Prerequisites

- `bash`, `kubectl`, `nc`, `awk`
- A working kube context (`kubectl get pods` should succeed)

## Install

```sh
make install          # copies pfm to /usr/local/bin
```

## Configure

Create `./pfm.yaml` (per-project) or `~/.config/pfm/default.yaml` (global).
Start from [`pfm.example.yaml`](../pfm.example.yaml):

```yaml
forwards:
  - name: db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
```

## Run

```sh
pfm up          # start every forward in the profile
pfm status      # UP/DOWN per forward
pfm logs db     # tail one forward
pfm down        # stop everything
```

Tune with `PFM_STATE_DIR` and `PFM_RECONNECT_DELAY` (see `.env.example`).
