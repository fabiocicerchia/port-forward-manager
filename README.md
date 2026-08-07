# port-forward-manager (`pfm`)

> Manage multiple kubectl port-forwards from a profile file, with
> auto-reconnect, per-forward logs, and an at-a-glance status view.

[![code-quality](https://github.com/fabiocicerchia/port-forward-manager/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/port-forward-manager/actions/workflows/code-quality.yml)
[![security](https://github.com/fabiocicerchia/port-forward-manager/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/port-forward-manager/actions/workflows/security.yml)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/port-forward-manager/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/port-forward-manager)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/port-forward-manager/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)
[![Release](https://img.shields.io/github/v/release/fabiocicerchia/port-forward-manager)](https://github.com/fabiocicerchia/port-forward-manager/releases)

The perpetual daily annoyance, fixed.

```console
$ pfm up
pfm: profile ./pfm.yaml
  db: svc/postgres (ns data) on 5432:5432
  redis: svc/redis (ns data) on 6379:6379
  api: deploy/api (ns app) on 8080:80
pfm: 3 forward(s) started.

$ pfm status
● db     UP    localhost:5432:5432
● redis  UP    localhost:6379:6379
○ api    DOWN  localhost:8080:80 (reconnecting)
```

## Features

- One profile file drives many `kubectl port-forward` processes.
- Auto-reconnect when a forward drops (rollout, node drain, laptop sleep).
- Per-forward logs and a live status view.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/port-forward-manager/main/install.sh | bash
```

Or from a local clone:

```sh
make install          # or copy `pfm` onto your PATH
```

Or grab the released script directly:

```sh
curl -fsSLO https://github.com/fabiocicerchia/port-forward-manager/releases/latest/download/pfm
install -m 0755 pfm /usr/local/bin/pfm
```

Dependencies: bash, kubectl, nc, awk — nothing else.

## Usage

Per-project `./pfm.yaml` or global `~/.config/pfm/default.yaml`
(see [`pfm.example.yaml`](pfm.example.yaml)):

```yaml
forwards:
  - name: db
    target: svc/postgres
    namespace: data
    ports: "5432:5432"
  - name: api
    target: deploy/api
    namespace: app
    ports: "8080:80"
    context: staging
```

```sh
pfm up [profile]   # start all forwards
pfm status         # show forwards and their health
pfm logs NAME      # tail one forward's log
pfm down           # stop everything
```

Each forward is supervised: when kubectl drops the connection, pfm reconnects
after `PFM_RECONNECT_DELAY` (2s default).

## Documentation

Full docs live in [`docs/`](docs/). Runnable examples live in
[`examples/`](examples/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By participating you agree to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Found a vulnerability? See [SECURITY.md](SECURITY.md) — please don't open a
public issue.

## Support

Need help implementing this? [Get in touch](https://fabiocicerchia.it/contact).

## License

[Apache 2.0](LICENSE) © 2026 Fabio Cicerchia
