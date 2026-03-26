# AGENTS.md

## Project

Delve-debugger: a tool for debugging Go applications running in Kubernetes pods or Docker containers using the Delve debugger. It builds a container image with Delve pre-installed and provides shell scripts to attach to running processes.

## Build

```bash
make build    # builds Docker image, versions extracted from package/Dockerfile
make import   # imports image into k3d cluster
```

The Dockerfile (`package/Dockerfile`) is the single source of truth for Go, Delve, and SLE versions.

## Structure

- `delve-debugger.sh` — main Kubernetes debugging entrypoint
- `delve-debugger-docker.sh` — Docker debugging entrypoint
- `package/Dockerfile` — container image definition
- `package/entrypoint.sh` — container entrypoint (attaches Delve to target PID)
- `util/` — convenience scripts for specific projects (Rancher, Fleet, k3s)
- `docs/guides/` — per-project debugging guides

## Languages

Bash (scripts), Dockerfile. No Go source code — Go is only the target runtime for debugging.

## CI/CD

GitHub Actions (`.github/workflows/release.yml`): on tag push, builds and pushes multi-arch (amd64/arm64) image to `ghcr.io`.

## Conventions

- Bash scripts use `set -e` and positional arguments with `${VAR:-default}` defaults.
- No test suite — this is a utility project tested manually against live clusters.
- Version bumps happen in `package/Dockerfile` only; the Makefile reads them from there.
