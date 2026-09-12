# port-forward-manager (`portfwd`)

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
$ portfwd up
portfwd: profile ./portfwd.yaml
  db: svc/postgres (ns data) on 5432:5432
  redis: svc/redis (ns data) on 6379:6379
  api: deploy/api (ns app) on 8080:80
portfwd: 3 forward(s) started.

$ portfwd status
● db     UP    localhost:5432:5432
● redis  UP    localhost:6379:6379
○ api    DOWN  localhost:8080:80 (reconnecting)
```

## What it is

A **committed profile per project**. `portfwd.yaml` sits in the repo next to the
code that needs the forwards, so everyone on the team — and CI — brings up the
same local ports with one command, and a change to the ports arrives as a diff.
One profile can span **several kube contexts** at once, and the whole thing is
**rootless**: no `/etc/hosts` edits, no privileged ports, no daemon, no
`sudo`.

### When to use something else

If what you want is *forward everything in a namespace under real service
names* — `postgres.data.svc.cluster.local` resolving on your laptop —
[kubefwd][kubefwd] is the tool for that job, and it is good at it. It rewrites
`/etc/hosts` and needs root to do so. `portfwd` deliberately does neither: it
forwards the handful of things one project names, onto the localhost ports that
project already expects.

[kubefwd]: https://github.com/txn2/kubefwd

## Features

- One profile file drives many `kubectl port-forward` processes.
- Auto-reconnect when a forward drops (rollout, node drain, laptop sleep).
- Per-forward logs and a live status view.
- `portfwd env` prints the same profile as environment variables, so a
  project's `.env` comes from the file that opens the forwards.
- `protected: true` guards prod: opening it needs `--reason`, and every
  protected session lands in a local log.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/port-forward-manager/main/install.sh | bash
```

Or from a local clone:

```sh
make install          # or copy `portfwd` onto your PATH
```

Or grab the released script directly:

```sh
curl -fsSLO https://github.com/fabiocicerchia/port-forward-manager/releases/latest/download/portfwd
install -m 0755 portfwd /usr/local/bin/portfwd
```

Dependencies: bash, kubectl, nc, awk — nothing else.

## Usage

Per-project `./portfwd.yaml` or global `~/.config/portfwd/default.yaml`
(see [`portfwd.example.yaml`](portfwd.example.yaml)):

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
portfwd up [profile]   # start all forwards
portfwd env [profile]  # print the profile as environment variables
portfwd status         # show forwards and their health
portfwd logs NAME      # tail one forward's log
portfwd down           # stop everything
```

Each forward is supervised: when kubectl drops the connection, portfwd reconnects
after `PORTFWD_RECONNECT_DELAY` (2s default).

### The profile as environment variables

The profile already says where every service will be; `portfwd env` prints that
as the variables an app reads, so a `.env` is generated from the same committed
file rather than kept in sync with it by hand. The key comes from `name`,
uppercased with anything that is not a letter or digit turned into `_`:

```console
$ portfwd env
DB_HOST=localhost
DB_PORT=5432
API_HOST=localhost
API_PORT=8080

$ portfwd env --format export > .envrc
$ eval "$(portfwd env --format export)"
$ portfwd env --format json
{
  "DB_HOST": "localhost",
  "DB_PORT": "5432",
  "API_HOST": "localhost",
  "API_PORT": "8080"
}
```

`--format` takes `dotenv` (the default), `export`, or `json`.

### Protected forwards

`kubectl port-forward` leaves no trail: nothing records that someone opened a
tunnel into the production database at 02:00, or why. Mark a forward — or a
whole context — `protected: true` and portfwd asks for a reason and keeps the
record itself.

```yaml
contexts:
  - name: prod
    protected: true       # everything on this context is protected
forwards:
  - name: prod-db
    target: svc/postgres
    namespace: data
    ports: "15432:5432"
    context: prod
  - name: payments
    target: svc/payments
    ports: "9000:80"
    protected: true       # or protect a single forward
```

```console
$ portfwd up
portfwd: protected in this profile: prod-db payments
portfwd: opening a protected forward needs --reason "<why>" (logged to /home/you/.local/state/portfwd/protected.log)

$ portfwd up --reason "INC-4711: replaying the stuck payment batch"
portfwd: profile ./portfwd.yaml
  prod-db: svc/postgres (ns data) on 15432:5432 [protected]
  payments: svc/payments on 9000:80 [protected]
portfwd: 2 forward(s) started. 'portfwd status' to check, 'portfwd down' to stop.
```

The run is refused whole, not in part — a profile that names prod is opened
deliberately or not at all. When the session ends, one tab-separated line is
appended to `$PORTFWD_AUDIT_LOG` (default
`~/.local/state/portfwd/protected.log`, mode 600):

```console
$ column -t -s $'\t' ~/.local/state/portfwd/protected.log
prod  data  svc/postgres  you  2026-09-11T08:14:02Z  2026-09-11T09:31:40Z  INC-4711: replaying the stuck payment batch
```

Context, namespace, target, user, start, end, reason. A session cut short with
the machine is closed out with `interrupted` as its end on the next `portfwd
up`. There is no server and nothing to sign in to: the log is a file on your
disk, for you to keep, rotate, or ship wherever your team already ships logs.

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

| Verb      | What it does here                                         |
| --------- | --------------------------------------------------------- |
| `setup`   | Install the pre-commit hook                               |
| `install` | Copy `portfwd` into `PREFIX/bin` (default `/usr/local`)   |
| `test`    | The lifecycle test, with kubectl stubbed — no cluster     |
| `lint`    | `pre-commit run --all-files` — the whole gate             |
| `run`     | Run `portfwd` from the checkout; `ARGS` is the subcommand |
| `format`  | Rewrite what the gate can fix: whitespace, endings, EOF   |
| `analyze` | `shellcheck` on its own, without the rest of the gate     |

#### Not applicable

One verb has no meaning here. It exits 0 and says so rather than pretending to
work (FC-GEN-058):

- `build` — `portfwd` is a shell script; `make install` copies it.

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
