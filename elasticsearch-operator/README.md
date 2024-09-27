# ECK - Elasticsearch Cluster Operator

## Add new ECK version

To add a new version of ECK, follow the steps below:

### Pre-requisites

If not done yet, install splinter from this repository: <https://github.com/kdwils/splinter>

### Change version in base `kustomization.yaml`

Create a sub-directory in the base directory for elasticsearch-operator, with the name of the version number you want to install, e.g. `v2.13.0`

```bash
export ECK_VERSION="v2.13.0"
export STRIPPED_VERSION=$(echo "$ECK_VERSION" | cut -c2-)
mkdir elasticsearch-operator/base/$ECK_VERSION
```

Copy the current `kustomization.yaml` file from the base directory into the new directory, e.g.

```bash
cp elasticsearch-operator/base/kustomization.yaml elasticsearch-operator/base/$ECK_VERSION
```

Then, change the version number of the URL in the `kustomization.yaml` file to the version you want to install

```bash
vi elasticsearch-operator/base/$ECK_VERSION/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- https://download.elastic.co/downloads/eck/2.13.0/crds.yaml
- https://download.elastic.co/downloads/eck/2.13.0/operator.yaml
```

### Localize `crds.yaml` $ `operator.yaml` file with kustomize

```bash
export ECK_VERSION="v2.13.0"
kustomize localize elasticsearch-operator/base/$ECK_VERSION elasticsearch-operator/base/$ECK_VERSION/install
```

### Use splinter to split `crds.yaml` $ `operator.yaml` files into multiple files

Move `crds.yaml` $ `operator.yaml` manifest and split into multiple files.

```bash
export ECK_VERSION="v2.13.0"
export STRIPPED_VERSION=$(echo "$ECK_VERSION" | cut -c2-)

mv elasticsearch-operator/base/$ECK_VERSION/install/localized-files/download.elastic.co/downloads/eck/$STRIPPED_VERSION/crds.yaml elasticsearch-operator/base/$ECK_VERSION/install

mv elasticsearch-operator/base/$ECK_VERSION/install/localized-files/download.elastic.co/downloads/eck/$STRIPPED_VERSION/operator.yaml elasticsearch-operator/base/$ECK_VERSION/install

rm -rf elasticsearch-operator/base/$ECK_VERSION/install/localized-files

cd elasticsearch-operator/base/$ECK_VERSION/install
splinter split -i crds.yaml -k
rm crds.yaml
splinter split -i operator.yaml -k
rm operator.yaml
cd ../../../..
```

### Cleanup `kustomization.yaml` file and move manifests

```bash
export ECK_VERSION="v2.13.0"
rm elasticsearch-operator/base/$ECK_VERSION/kustomization.yaml
mv elasticsearch-operator/base/$ECK_VERSION/install/* elasticsearch-operator/base/$ECK_VERSION/
rm -rf elasticsearch-operator/base/$ECK_VERSION/install
```

### Add `customresourcedefinition.yaml` as resource to `kustomization.yaml` file that was created with splinter

```bash
KUSTOMIZATION_FILE="elasticsearch-operator/base/$ECK_VERSION/kustomization.yaml"
CRD_FILE="customresourcedefinition.yaml"
TAB=$(printf "\t")
sed -i "/resources:/a \  - ${CRD_FILE}" "${KUSTOMIZATION_FILE}"
```

## Update ECK operator version of existing deployment

### Change version in overlay `kustomization.yaml`

After adding a new version of ECK in the base directory, you need to update the version of ECK in the `kustomization.yaml` file for your environment.

For example, if you want to update the version of ECK for `test`, open the `kustomization.yaml` file and change the version number in the resources section to point to the base directory for the version you want to install.

```bash
vi elasticsearch-operator/overlays/test/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base/v2.13.0

# patches:
# - path: elasticsearch-operator-patch.yaml
#   target:
#     kind: Deployment
#     name: elasticsearch-operator

```

### Apply the new version of ECK operator manually (optional)

**This step is usually not necessary when ECK operator is managed by ArgoCD.**
**It should pick up on the changes in this repository and, if configured to sync automatically, apply the changes that were done for the specific environment in the overlays directory.**

If the changes don't get applied automatically, check the sync status in ArgoCD UI.

If needed, run `kubectl -k` command manually to apply the changes:

```bash
cd elasticsearch-operator
kubectl apply -k elasticsearch-operator/overlays/test/
```
