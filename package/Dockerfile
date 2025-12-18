# Base image: SUSE Linux Enterprise 15 SP7 (latest as of Dec 2025)
FROM registry.suse.com/suse/sle15:15.7

# Go 1.25 is the latest stable version available in SUSE repositories (Dec 2025)
# Corresponds to upstream Go 1.25.x releases
ARG GO_VERSION=1.25

# Delve 1.25.2 is the latest stable release (released Aug 2025, verified Dec 2025)
# See: https://github.com/go-delve/delve/releases
ARG DLV_VERSION=1.25.2

# Internal version tracking for delve-debugger image builds
ARG DELVE_DEBUGGER_VERSION=1

RUN zypper --non-interactive install --no-recommends go${GO_VERSION} git sudo procps

RUN CGO_ENABLED=0 go install -ldflags '-extldflags -static' github.com/go-delve/delve/cmd/dlv@v${DLV_VERSION}
RUN mv /root/go/bin/dlv /usr/bin

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
