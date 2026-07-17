# pfm packaged with its runtime deps (kubectl, bash, netcat, pkill).
#
# Note: pfm forks background supervisor processes and keeps state on disk.
# `up` blocks in the foreground when running as PID 1 (see pfm's `cmd_up`) so
# a container stays alive for as long as the forwards should run, e.g.:
#   docker run --rm -it -v ~/.kube:/home/app/.kube:ro pfm up
# Ctrl+C (or `docker stop`) sends SIGTERM/SIGINT, which stops the forwards
# and exits cleanly. Outside a container (host CLI use), `up` still returns
# immediately, since $$ is never 1 there.
FROM alpine:3

RUN apk add --no-cache bash kubectl netcat-openbsd procps coreutils gawk \
    && adduser -D -u 10001 app

COPY pfm /usr/local/bin/pfm

USER app
WORKDIR /home/app
ENTRYPOINT ["pfm"]
CMD ["help"]
