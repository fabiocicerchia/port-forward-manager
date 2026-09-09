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

## Verifying the image

Every published image is signed with [cosign][cosign], keyless: the identity in
the signature is the workflow that published it, not a key anybody holds.

```sh
cosign verify ghcr.io/fabiocicerchia/port-forward-manager:latest \
  --certificate-identity-regexp \
    'https://github.com/fabiocicerchia/port-forward-manager/.github/workflows/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

`no signatures found` means the tag predates signing, not that verification was
set up wrongly — a wrong identity or issuer says so explicitly. Re-run the
publish workflow for that tag to sign it.

[cosign]: https://docs.sigstore.dev/

## Development

### Make targets

`make help` lists them. Every repository in this estate exposes the same eight
verbs, so you do not have to read a Makefile to find out how to build or test it
(FC-GEN-057).

| Verb      | What it does here                                       |
| --------- | ------------------------------------------------------- |
| `setup`   | Install the pre-commit hook                             |
| `install` | Copy `pfm` into `PREFIX/bin` (default `/usr/local`)     |
| `test`    | The lifecycle test, with kubectl stubbed — no cluster   |
| `lint`    | `pre-commit run --all-files` — the whole gate           |
| `run`     | Run `pfm` from the checkout; `ARGS` is the subcommand   |
| `format`  | Rewrite what the gate can fix: whitespace, endings, EOF |
| `analyze` | `shellcheck` on its own, without the rest of the gate   |

#### Not applicable

One verb has no meaning here. It exits 0 and says so rather than pretending to
work (FC-GEN-058):

- `build` — `pfm` is a shell script; `make install` copies it.

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
