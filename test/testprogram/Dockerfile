FROM registry.suse.com/suse/sle15:15.7 AS build

ARG GO_VERSION=1.25

RUN zypper --non-interactive install --no-recommends go${GO_VERSION}

WORKDIR /build
COPY main.go .

# Build with debug symbols: -N disables optimizations, -l disables inlining
# Do NOT use -ldflags '-s -w' which would strip debug info
RUN CGO_ENABLED=0 go build -gcflags='all=-N -l' -o testprogram main.go

FROM registry.suse.com/suse/sle15:15.7

COPY --from=build /build/testprogram /usr/bin/testprogram

# Run as non-root user to exercise UID/GID matching in entrypoint.sh
USER 1000:1000

ENTRYPOINT ["/usr/bin/testprogram"]
