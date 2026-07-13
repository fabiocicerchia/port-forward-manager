# pfm packaged with its runtime deps (kubectl, bash, netcat, pkill).
#
# Note: pfm forks background supervisor processes and keeps state on disk, so a
# container is best used interactively with your kube config mounted, e.g.:
#   docker run --rm -it -v ~/.kube:/home/app/.kube:ro pfm up
# It is not a long-lived daemon image.
FROM alpine:3

RUN apk add --no-cache bash kubectl netcat-openbsd procps coreutils gawk \
    && adduser -D -u 10001 app

COPY pfm /usr/local/bin/pfm

USER app
WORKDIR /home/app
ENTRYPOINT ["pfm"]
CMD ["help"]
