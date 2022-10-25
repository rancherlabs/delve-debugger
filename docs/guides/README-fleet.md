# fleet

In order to debug fleet it is first necessary to recompile it with debug symbols.

1. install fleet as usual (eg. as part of Rancher)
2. determine the current **chart** version (eg. `100.0.3+up0.3.9`):
```
if kubectl get ns | grep cattle-fleet-system; then
  export NAMESPACE=cattle-fleet-system
else
  export NAMESPACE=fleet-system
fi
helm --namespace $NAMESPACE list
```
4. determine the new version for the component debug deployment (eg. `100.0.4-dbg`)
5. recompile with debugging symbols, eg.

```
cd fleet
export VERSION=100.0.4-dbg
DEBUG=true TAG=$VERSION make
```

NOTE: currently make support for debug symbols is available on the `master` branch
A 0.3.9 fork with the patch is available here: https://github.com/moio/fleet/tree/v0.3.9-dbg

6. either push built images onto a registry, or import them into your cluster nodes manually. If you are using [k3d](https://k3d.io):

```shell
export CLUSTER=upstream
k3d image import --mode direct --cluster $CLUSTER rancher/fleet:$VERSION rancher/fleet-agent:$VERSION
```

7. upgrade the installation to the latest build

```shell
helm -n $NAMESPACE upgrade --version $VERSION --reuse-values --set debug=true fleet-crd ./dist/artifacts/fleet-crd-$VERSION.tgz
helm -n $NAMESPACE upgrade --version $VERSION --reuse-values --set debug=true --set image.tag=$VERSION --set agentImage.tag=$VERSION fleet ./dist/artifacts/fleet-$VERSION.tgz
```

Note: if fleet is installed by Rancher, its version string starts with 100. Installing a lower version will be overwritten by Rancher with a vanilla version.

8. run
```shell
./util/debug-fleet-controller.sh
```

or

```shell
./util/debug-fleet-agent.sh
```

### gitjob additional steps

After following instructions above:

9. determine the current **image** version (eg. `v0.1.26`):

```shell
kubectl --namespace cattle-fleet-system describe deployment gitjob | grep Image
```

10. determine a new version for the component debug deployment (eg. `v0.1.26-dbg`)

11. build gitjob:

```
cd ../gitjob
export GITJOB_VERSION=v0.1.26-dbg
DEBUG=true TAG=$GITJOB_VERSION make
```

12. either push built images onto a registry, or import them into your cluster nodes manually. If you are using [k3d](https://k3d.io):

```shell
export CLUSTER=upstream
k3d image import --mode direct --cluster $CLUSTER rancher/gitjob:$GITJOB_VERSION
```

3. upgrade the *fleet* chart specifying the rebuilt gitjob image:

```shell
cd ../fleet
helm -n cattle-fleet-system upgrade --version $VERSION --reuse-values --set gitjob.gitjob.tag=$GITJOB_VERSION fleet ./dist/artifacts/fleet-$VERSION.tgz
```
