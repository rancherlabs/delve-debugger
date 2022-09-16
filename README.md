# Delve in Kubernetes

Debug your golang app running inside k8s.

Attaches an ephemeral container with [Delve](https://github.com/go-delve/delve) to your process/container/pod.

## Usage: ad-hoc guides

Ad-hoc guides are provided for some projects:
- [Rancher](docs/guides/README-rancher.md)
- [Rancher fleet](docs/guides/README-fleet.md) and its components

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

- have `kubectl` available
- use k8s >= v1.18


### Running

```
./delve-debugger.sh <NAMESPACE> <POD> <CONTAINER> <EXECUTABLE>
```

This will open local port 4000, which you can attach to from GoLand.

![GoLand configuration screen](./docs/GoLand_config.png)

Enjoy breakpoints, watches and stack inspection!
