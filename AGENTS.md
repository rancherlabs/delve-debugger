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

## Test

Run the e2e battery (starts a test target and attaches Delve to it end-to-end):

```bash
make test-e2e-docker   # Docker e2e test (needs local Docker daemon)
make test-e2e-k3d      # k3s-in-k3d e2e test (needs local Docker + k3d)
make test-e2e          # both
```

Each run builds the image and a test target first. Tests are hermetic apart from the container runtime; expect a couple of minutes (the k3d run imports a cluster image). Run the battery after changing Dockerfile, entrypoint, or test scripts. Same battery runs in CI (`.github/workflows/e2e.yml`).

## CI/CD

GitHub Actions (`.github/workflows/release.yml`): on tag push, builds and pushes multi-arch (amd64/arm64) image to `ghcr.io`.

## Conventions

- Bash scripts use `set -e` and positional arguments with `${VAR:-default}` defaults.
- Version bumps happen in `package/Dockerfile` only; the Makefile reads them from there.
