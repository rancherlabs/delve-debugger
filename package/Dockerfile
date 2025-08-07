FROM registry.suse.com/suse/sle15:15.7

ARG GO_VERSION
ARG DLV_VERSION

RUN zypper --non-interactive install --no-recommends go${GO_VERSION} git sudo

RUN CGO_ENABLED=0 go install -ldflags '-extldflags -static' github.com/go-delve/delve/cmd/dlv@v${DLV_VERSION}
RUN mv /root/go/bin/dlv /usr/bin

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
