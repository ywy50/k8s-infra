# Distributed Storage - Rook Operator

## Add new Rook Operator version

To add a new version of Rook Operator, follow the steps below:

### Pre-requisites

If not done yet, install splinter from this repository: <https://github.com/kdwils/splinter>

### Download specific Rook Operator version

Create a sub-directory in the base directory for rook-operator, with the name of the version number you want to install, e.g. `v1.14.9`

```bash
export ROOK_VERSION="v1.14.9"
mkdir rook-operator/base/$ROOK_VERSION
```

Copy the current `kustomization.yaml` file from the base directory into the new directory, e.g.

```bash
cp rook-operator/base/kustomization.yaml rook-operator/base/$ROOK_VERSION
```

<!-- Then, change the version number of the URL in the `kustomization.yaml` file to the version you want to install

```bash
vi rook-operator/base/$ROOK_VERSION/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- common.yaml
- crds.yaml
- operator.yaml
``` -->

Clone Rook repository from git

```bash
export ROOK_VERSION="v1.14.9"
git clone --single-branch --branch $ROOK_VERSION https://github.com/rook/rook.git rook-operator/base/$ROOK_VERSION/rook
```

Now, copy the manifests from the repository you cloned

```bash
export ROOK_VERSION="v1.14.9"
cp rook-operator/base/$ROOK_VERSION/rook/deploy/examples/crds.yaml rook-operator/base/$ROOK_VERSION
cp rook-operator/base/$ROOK_VERSION/rook/deploy/examples/operator.yaml rook-operator/base/$ROOK_VERSION
cp rook-operator/base/$ROOK_VERSION/rook/deploy/examples/common.yaml rook-operator/base/$ROOK_VERSION
```

Cleanup the cloned git repository

```bash
rm -rf rook-operator/base/$ROOK_VERSION/rook
```

### Localize `crds.yaml`, `operator.yaml` & `common.yaml` file with kustomize

```bash
export ROOK_VERSION="v1.14.9"
kustomize localize rook-operator/base/$ROOK_VERSION rook-operator/base/$ROOK_VERSION/install
```

### Use splinter to split `operator.yaml` & `common.yaml` files into multiple files

Split `operator.yaml` & `common.yaml` manifest into multiple files.

```bash
export ROOK_VERSION="v1.14.9"

cd rook-operator/base/$ROOK_VERSION/install
splinter split -i operator.yaml -k
splinter split -i common.yaml -k
rm operator.yaml
rm common.yaml
cd ../../../..
```

### Cleanup `kustomization.yaml` file and move manifests

```bash
export ROOK_VERSION="v1.14.9"
rm rook-operator/base/$ROOK_VERSION/kustomization.yaml
mv rook-operator/base/$ROOK_VERSION/install/* rook-operator/base/$ROOK_VERSION/
rm -rf rook-operator/base/$ROOK_VERSION/install
```

### Add missing resources to `kustomization.yaml` file that was created with splinter

Make sure to have yq installed first
<https://github.com/mikefarah/yq>

```bash
yq -i '.resources = ["crds.yaml", "configmap.yaml", "deployment.yaml"] + .resources' rook-operator/base/$ROOK_VERSION/kustomization.yaml
```

### Add nodeAffinity path to `deployment.yaml` file that was created with splinter

```bash
export ROOK_VERSION="v1.14.9"
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' rook-operator/base/$ROOK_VERSION/deployment.yaml
```

## Update Rook operator version of existing deployment

### Change version in overlay `kustomization.yaml`

After adding a new version of Rook in the base directory, you need to update the version of Rook in the `kustomization.yaml` file for your environment.

For example, if you want to update the version of Rook for `test`, open the `kustomization.yaml` file and change the version number in the resources section to point to the base directory for the version you want to install.

```bash
vi rook-operator/overlays/test/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: rook-ceph

resources:
- ../../base/v1.14.9

# patches:
# - path: rook-operator-patch.yaml
#   target:
#     kind: Deployment
#     name: rook-operator

```

### Apply the new version of Rook operator manually (optional)

**This step is usually not necessary when Rook operator is managed by ArgoCD.**
**It should pick up on the changes in this repository and, if configured to sync automatically, apply the changes that were done for the specific environment in the overlays directory.**

If the changes don't get applied automatically, check the sync status in ArgoCD UI.

If you want to do a dry-run first, run `kubectl -k` with the `--dry-run=client` option:

```bash
kubectl apply -k rook-operator/overlays/test/ --dry-run=client
```

If needed, run `kubectl -k` command manually to apply the changes:

```bash
kubectl apply -k rook-operator/overlays/test/
```
