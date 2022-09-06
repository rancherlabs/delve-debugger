# Delve for Kubernetes

Debug your golang binary inside a Kubernetes Pods by attaching Delve from an ephemeral container.

## Requirements
 - binary to debug should be compiled using `go build` with the following options to disable optimizations (that confuse Delve):
```
-gcflags='all=-N -l'
```

 - binary **must not** be compiled with the following options to strip symbols:
 ```
 -ldflags '-s -w'
 ```

 - `kubectl` available
 - Kubernetes >= v1.18

## Running

```
delve-debugger.sh <NAMESPACE> <POD> <CONTAINER> <EXECUTABLE>
```

This will open local port 4000, which you can attach to from GoLand.

