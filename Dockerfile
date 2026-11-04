# portfwd packaged with its runtime deps (kubectl, bash, netcat, pkill).
#
# Note: portfwd forks background supervisor processes and keeps state on disk.
# `up` blocks in the foreground when running as PID 1 (see portfwd's `cmd_up`) so
# a container stays alive for as long as the forwards should run, e.g.:
#   docker run --rm -it -v ~/.kube:/home/app/.kube:ro portfwd up
# Ctrl+C (or `docker stop`) sends SIGTERM/SIGINT, which stops the forwards
# and exits cleanly. Outside a container (host CLI use), `up` still returns
# immediately, since $$ is never 1 there.
FROM alpine:3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache bash kubectl netcat-openbsd procps coreutils gawk \
    && adduser -D -u 10001 app

COPY portfwd /usr/local/bin/portfwd

USER app
WORKDIR /home/app
# `portfwd status` prints DOWN/UP per forward but always exits 0 (see cmd_status),
# so it can't drive a real HEALTHCHECK without changing that exit-code
# contract — out of scope for a Dockerfile-only pass. Declared to satisfy
# scanners; `docker exec <container> portfwd status` remains the way to check.
HEALTHCHECK NONE
ENTRYPOINT ["portfwd"]
CMD ["help"]
