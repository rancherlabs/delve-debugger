# Delve in Kubernetes

Debug your golang app running inside k8s.

Attaches an ephemeral container with Delve to your process/container/pod.

## Running

```
./delve-debugger.sh <NAMESPACE> <POD> <CONTAINER> <EXECUTABLE>
```

This will open local port 4000, which you can attach to from GoLand.

![GoLand configuration screen](./docs/GoLand_config.png)

The debugger is ready when you see the line:

```
2022-09-07T08:24:09Z debug layer=debugger continuing
```

Ctrl+C terminates the ephemeral container. You can start another later by re-running `delve-debugger.sh`. To completely get rid of all ephemeral containers, the Pod needs to be killed.

## Requirements
 - binary to debug should be compiled using `go build` with the following options to disable optimizations (which confuse Delve):
```
-gcflags='all=-N -l'
```

 - binary **must not** be compiled with the following options to strip symbols:
 ```
 -ldflags '-s -w'
 ```

 - `kubectl` available
 - Kubernetes >= v1.18


