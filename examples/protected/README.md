# Protected Example

What it shows: a production forward that cannot be opened without a reason, and
a local record of every session that was.

## Run

Without a reason the run is refused whole — not half-started:

```sh
portfwd up examples/protected/portfwd.yaml
```

```text
portfwd: protected in this profile: prod-db payments
portfwd: opening a protected forward needs --reason "<why>" (logged to /home/you/.local/state/portfwd/protected.log)
```

Exit status is 77. With a reason:

```sh
portfwd up examples/protected/portfwd.yaml --reason "INC-4711: replaying the stuck payment batch"
portfwd status
portfwd down
```

```text
portfwd: profile examples/protected/portfwd.yaml
  dev-db: svc/postgres (ns data) on 5432:5432
  prod-db: svc/postgres (ns data) on 15432:5432 [protected]
  payments: svc/payments (ns app) on 9000:80 [protected]
portfwd: 3 forward(s) started. 'portfwd status' to check, 'portfwd down' to stop.
```

## The log

`portfwd down` appends one tab-separated line per protected session to
`$PORTFWD_AUDIT_LOG` (default `~/.local/state/portfwd/protected.log`, mode 600):

```console
$ column -t -s $'\t' ~/.local/state/portfwd/protected.log
-     app   svc/payments  you  2026-09-11T08:14:02Z  2026-09-11T09:31:40Z  INC-4711: replaying the stuck payment batch
prod  data  svc/postgres  you  2026-09-11T08:14:02Z  2026-09-11T09:31:40Z  INC-4711: replaying the stuck payment batch
```

Context, namespace, target, user, start, end, reason — `-` where the profile
left the field out. A session cut short with the machine is closed out with
`interrupted` as its end on the next `portfwd up`.

It is a plain local file: no server, no daemon, nothing to run as root. Rotate
it, grep it, or ship it wherever your team already ships logs.
