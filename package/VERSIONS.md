# Version Information

This document tracks the versions used in the delve-debugger Docker image.

## Last Updated: December 2025

### Base Image
- **Image**: `registry.suse.com/suse/sle15:15.7`
- **Version**: SUSE Linux Enterprise 15 SP7 (Service Pack 7)
- **Status**: Latest stable release
- **Notes**: SP7 is the current stable release with extended support

### Go (Golang)
- **Package**: `go1.25`
- **Version**: 1.25.x (from SUSE repositories)
- **Upstream**: Corresponds to Go 1.25.5 language release
- **Status**: Latest stable version in SUSE repos
- **Installation**: Via `zypper install go1.25`

### Delve Debugger
- **Version**: v1.25.2
- **Release Date**: August 27, 2025
- **Status**: Latest stable release
- **Source**: https://github.com/go-delve/delve
- **Installation**: Via `go install github.com/go-delve/delve/cmd/dlv@v1.25.2`

### Additional Tools
- **git**: Latest available in SUSE repos
- **sudo**: Latest available in SUSE repos
- **procps**: Latest available in SUSE repos

## Verification

To verify versions in the built image:
```bash
docker run --rm <image-name> dlv version
docker run --rm <image-name> go version
```

## Update Policy

Versions should be reviewed and updated:
- When new stable releases of Delve are published
- When SUSE updates their Go packages
- When new SUSE Linux Enterprise service packs are released
- At least quarterly for security updates
