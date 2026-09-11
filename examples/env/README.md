# Env Example

What it shows: generating a project's `.env` from the same committed profile
that opens the forwards, so the two cannot drift apart.

## Run

```sh
portfwd env examples/env/portfwd.yaml
```

```text
DB_HOST=localhost
DB_PORT=5432
REDIS_HOST=localhost
REDIS_PORT=6379
API_GW_HOST=localhost
API_GW_PORT=8080
```

The key is the forward's `name`, uppercased, with anything that is not a letter
or a digit replaced by `_` — `api-gw` becomes `API_GW_*`.

## Other formats

```sh
portfwd env examples/env/portfwd.yaml --format export > .envrc
eval "$(portfwd env examples/env/portfwd.yaml --format export)"
portfwd env examples/env/portfwd.yaml --format json
```

## In practice

```sh
portfwd up examples/env/portfwd.yaml
portfwd env examples/env/portfwd.yaml > .env   # regenerate whenever the profile changes
```
