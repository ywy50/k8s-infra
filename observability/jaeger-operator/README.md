# Jaeger Operator

## Add new Jaeger version

To add a new version of Jaeger, follow the steps below:

### Pre-requisites

If not done yet, install splinter from this repository: <https://github.com/kdwils/splinter>

### Change version in base `kustomization.yaml`

Create a sub-directory in the base directory for observability/jaeger-operator, with the name of the version number you want to install, e.g. `v1.57.0`

```bash
export Jaeger_VERSION="v1.57.0"
mkdir observability/jaeger-operator/base/$Jaeger_VERSION
```

Copy the current `kustomization.yaml` file from the base directory into the new directory, e.g.

```bash
cp observability/jaeger-operator/base/kustomization.yaml observability/jaeger-operator/base/$Jaeger_VERSION
```

Then, change the version number of the URL in the `kustomization.yaml` file to the version you want to install

```bash
vi observability/jaeger-operator/base/$Jaeger_VERSION/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: observability
resources:
- https://github.com/jaegertracing/jaeger-operator/releases/download/v1.57.0/jaeger-operator.yaml
```

### Localize `jaeger-operator.yaml` file with kustomize

```bash
export Jaeger_VERSION="v1.57.0"
kustomize localize observability/jaeger-operator/base/$Jaeger_VERSION observability/jaeger-operator/base/$Jaeger_VERSION/install
```

### Use splinter to split `jaeger-operator.yaml` into multiple files

Move `jaeger-operator.yaml` manifest and split into multiple files.

```bash
export Jaeger_VERSION="v1.57.0"

mv observability/jaeger-operator/base/$Jaeger_VERSION/install/localized-files/github.com/jaegertracing/jaeger-operator/releases/download/$Jaeger_VERSION/jaeger-operator.yaml observability/jaeger-operator/base/$Jaeger_VERSION/install

rm -rf observability/jaeger-operator/base/$Jaeger_VERSION/install/localized-files

cd observability/jaeger-operator/base/$Jaeger_VERSION/install
splinter split -i jaeger-operator.yaml -k
rm jaeger-operator.yaml
cd ../../../../..
```

### Cleanup `kustomization.yaml` file and move manifests

```bash
export Jaeger_VERSION="v1.57.0"
rm observability/jaeger-operator/base/$Jaeger_VERSION/kustomization.yaml
mv observability/jaeger-operator/base/$Jaeger_VERSION/install/* observability/jaeger-operator/base/$Jaeger_VERSION/
rm -rf observability/jaeger-operator/base/$Jaeger_VERSION/install
```

### Add namespace to `kustomization.yaml` file that was created with splinter

```bash
KUSTOMIZATION_FILE="observability/jaeger-operator/base/$Jaeger_VERSION/kustomization.yaml"
NAMESPACE="observability"
sed -i "/kind: Kustomization/a namespace: ${NAMESPACE}" "${KUSTOMIZATION_FILE}"
```

## Update Jaeger version of existing deployment

### Change version in overlay `kustomization.yaml`

After adding a new version of Jaeger in the base directory, you need to update the version of Jaeger in the `kustomization.yaml` file for your environment.

For example, if you want to update the version of Jaeger for `test`, open the `kustomization.yaml` file and change the version number in the resources section to point to the base directory for the version you want to install.

```bash
vi observability/jaeger-operator/overlays/test/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: observability

resources:
- ../../base/v1.57.0

patches:
- path: jaeger-operator-patch.yaml
  target:
    kind: Deployment
    name: jaeger-operator
    namespace: observability

```

### Apply the new version of Jaeger operator manually (optional)

**This step is usually not necessary when Jaeger is managed by ArgoCD.**
**It should pick up on the changes in this repository and, if configured to sync automatically, apply the changes that were done for the specific environment in the overlays directory.**

If the changes don't get applied automatically, check the sync status in ArgoCD UI.

If needed, run `kubectl -k` command manually to apply the changes:

```bash
cd observability/jaeger-operator
kubectl apply -k observability/jaeger-operator/overlays/test/
```
