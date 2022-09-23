# Delve in Kubernetes and Docker

Debug your golang app running inside k8s or Docker

_(attaching an ephemeral container with [Delve](https://github.com/go-delve/delve) inside)_

## Usage: ad-hoc guides

Ad-hoc guides are provided for some projects:
- [Rancher](docs/guides/README-rancher.md)
- [Rancher fleet](docs/guides/README-fleet.md) and its components
- [k3d](docs/guides/README-k3d.md) ([k3s](https://k3s.io/) in Docker)

For other use cases follow instructions below.

## Usage: general

### Requirements
- the binary to debug **should** be compiled using `go build` with the following options (that disable optimizations):
```
-gcflags='all=-N -l'
```

- the binary to debug **must not** be compiled with the following options (that strip symbols):
 ```
 -ldflags '-s -w'
 ```

For Kubernetes:
- have `kubectl` available
- use k8s >= v1.18


### Running

For Kubernetes:
```
./delve-debugger.sh <NAMESPACE> <POD> <CONTAINER> <EXECUTABLE>
```

For Docker:
```
./delve-debugger-docker.sh <CONTAINER> <EXECUTABLE>
```

This will open local port 4000, which you can attach to from GoLand.

![GoLand configuration screen](./docs/GoLand_config.png)

Enjoy breakpoints, watches and stack inspection!
