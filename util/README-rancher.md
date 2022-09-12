# Rancher

In order to debug Rancher it is first necessary to recompile it with debug symbols.

1. install Rancher as usual
2. determine the current app version (eg. `v2.6.5`):
```
helm --namespace cattle-system list
```
4. determine the new version for the component debug deployment (eg. `v2.6.5-dbg`)
5. recompile with debugging symbols, eg.

```
cd rancher
export VERSION=v2.6.5-dbg
DEBUG=true TAG=$VERSION make
```

NOTE: currently make support for debug symbols is under review: https://github.com/rancher/rancher/pull/38867


A 2.6.5 fork with the patch is available here: https://github.com/moio/rancher/tree/v2.6.5-dbg

6. either push built images onto a registry, or import them into your cluster nodes manually. If you are using [k3d](https://k3d.io):

```shell
export CLUSTER=upstream
k3d image import --mode direct --cluster $CLUSTER $(cat ./dist/images)
```

7. upgrade the installation to the latest build

```shell
helm -n cattle-system upgrade --version $VERSION --reuse-values --set rancherImageTag=$VERSION rancher ./bin/chart/dev/$(ls -t ./bin/chart/dev | head -n1)
```

8. run
```shell
./util/debug-rancher.sh
```
