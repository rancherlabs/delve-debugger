FROM registry.suse.com/suse/sle15:15.3

ARG GO_VERSION
ARG DLV_VERSION

RUN zypper -n install go-${GO_VERSION}

RUN CGO_ENABLED=0 go install -ldflags '-extldflags -static' github.com/go-delve/delve/cmd/dlv@v${DLV_VERSION}

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
