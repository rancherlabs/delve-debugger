# k3d

## Compiling
In order to debug k3s it is first necessary to recompile it with debug symbols.

```
cd k3s
DEBUG=true make
```

NOTE: currently make support for debug symbols is available on the `master` branch.

A v1.23.6-rc4+k3s1 fork with the patch is available here: https://github.com/moio/k3s/tree/v1.23.6-rc4+k3s1-dbg

## Running 

With k3d, you will have to specify the image you just built. Run:

```shell
docker images
```

to get its name and version and then append `--image <IMAGE_NAME>` to the `k3d create` commandline.

After creation, find the container name you want to debug:
```shell
docker ps
```

Then debug it with

```shell
./util-debugger-k3d.sh <CONTAINER_NAME>
```
