# ArgoCD Deployment

## Add new ArgoCD version

To add a new version of ArgoCD, follow the steps below:

### Pre-requisites

If not done yet, install splinter from this repository: <https://github.com/kdwils/splinter>

### Change version in base `kustomization.yaml`

Create a sub-directory in the base directory for argo-cd, with the name of the version number you want to install, e.g. `v2.11.3`

```bash
export ARGOCD_VERSION="v2.11.3"
mkdir argo-cd/base/$ARGOCD_VERSION
```

Copy the current `kustomization.yaml` file from the base directory into the new directory, e.g.

```bash
cp argo-cd/base/kustomization.yaml argo-cd/base/$ARGOCD_VERSION
```

Then, change the version number of the URL in the `kustomization.yaml` file to the version you want to install

```bash
vi argo-cd/base/$ARGOCD_VERSION/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
- https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.3/manifests/install.yaml
```

### Localize `install.yaml` file with kustomize

```bash
export ARGOCD_VERSION="v2.11.3"
kustomize localize argo-cd/base/$ARGOCD_VERSION argo-cd/base/$ARGOCD_VERSION/install
```

### Use splinter to split `install.yaml` into multiple files

Move `install.yaml` manifest and split into multiple files.

```bash
export ARGOCD_VERSION="v2.11.3"
mv argo-cd/base/$ARGOCD_VERSION/install/localized-files/raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/ argo-cd/base/$ARGOCD_VERSION/
rm -rf argo-cd/base/$ARGOCD_VERSION/install
cd argo-cd/base/$ARGOCD_VERSION/manifests/
splinter split -i install.yaml -k
rm install.yaml
cd ../../../..
```

### Cleanup `kustomization.yaml` file and move manifests

```bash
export ARGOCD_VERSION="v2.11.3"
rm argo-cd/base/$ARGOCD_VERSION/kustomization.yaml
mv argo-cd/base/$ARGOCD_VERSION/manifests/* argo-cd/base/$ARGOCD_VERSION/
rm -rf argo-cd/base/$ARGOCD_VERSION/manifests
```

### Add namespace to `kustomization.yaml` file that was created with splinter

```bash
KUSTOMIZATION_FILE="argo-cd/base/$ARGOCD_VERSION/kustomization.yaml"
NAMESPACE="argocd"
sed -i "/kind: Kustomization/a namespace: ${NAMESPACE}" "${KUSTOMIZATION_FILE}"
```

### Add nodeAffinity path to `deployment.yaml` & `statefulset.yaml` file that was created with splinter

Make sure to have yq installed first
<https://github.com/mikefarah/yq>

```bash
# yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions = []' argo/argo-cd/base/v2.11.3/deployment.yaml

yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' argo/argo-cd/base/v2.11.3/deployment.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator = "In"' argo/argo-cd/base/v2.11.3/deployment.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] = "true"' argo/argo-cd/base/v2.11.3/deployment.yaml


# yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions = []' argo/argo-cd/base/v2.11.3/statefulset.yaml

yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' argo/argo-cd/base/v2.11.3/statefulset.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator = "In"' argo/argo-cd/base/v2.11.3/statefulset.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] = "true"' argo/argo-cd/base/v2.11.3/statefulset.yaml
```

## Update ArgoCD version of existing deployment

### Change version in overlay `kustomization.yaml`

After adding a new version of ArgoCD in the base directory, you need to update the version of ArgoCD in the `kustomization.yaml` file for your environment.

For example, if you want to update the version of ArgoCD for `test`, open the `kustomization.yaml` file and change the version number in the resources section to point to the base directory for the version you want to install.

```bash
vi argo-cd/overlays/test/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd

resources:
- ../../base/v2.11.3
- namespace.yaml
- ingress.yaml

patches:
- path: argocd-cmd-params-cm.yaml
  target:
    kind: ConfigMap
    name: argocd-cmd-params-cm
    namespace: argocd

```

### Apply the new version of ArgoCD

This step is usually not necessary when ArgoCD is managed by ArgoCD itself.
It should pick up on the changes in this repository and, if configured to sync automatically, apply the changes that were done for the specific environment in the overlays directory.
If the changes don't get applied automatically, check the sync status in ArgoCD UI.

If needed, run `kubectl -k` command manually to apply the changes:

```bash
cd argo
kubectl apply -k argo-cd/overlays/test/
```
