# Dynamic Persistent Volumes - AWS EBS csi driver

## Add new AWS EBS csi driver version

To add a new version of AWS EBS csi driver, follow the steps below:

### Pre-requisites

If not done yet, install splinter from this repository: <https://github.com/kdwils/splinter>

### Configure AWS EBS csi driver version to use

Create a sub-directory in the base directory for aws-ebs-csi-driver, with the name of the version number you want to install, e.g. `v1.33`

```bash
export EBS_CSI_DRIVER_VERSION="v1.33"
mkdir aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION
```

Copy the current `kustomization.yaml` file from the base directory into the new directory, e.g.

```bash
cp aws-ebs-csi-driver/base/kustomization.yaml aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION
```

Then, change the version number of the URL in the `kustomization.yaml` file to the version you want to install

```bash
vi aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.33
```

### Localize manifest files with kustomize

```bash
export EBS_CSI_DRIVER_VERSION="v1.33"
kustomize localize aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/install
```

### Cleanup `kustomization.yaml` file and move manifests

```bash
export EBS_CSI_DRIVER_VERSION="v1.33"

rm aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/kustomization.yaml
mv aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/install/localized-files/github.com/kubernetes-sigs/aws-ebs-csi-driver/release-1.33/deploy/kubernetes/base/* aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/
rm -rf aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/install
```

### Add nodeAffinity path to `controller.yaml` file that was created with splinter

Make sure to have yq installed first
<https://github.com/mikefarah/yq>

```bash
export EBS_CSI_DRIVER_VERSION="v1.33"

yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' aws-ebs-csi-driver/base/$EBS_CSI_DRIVER_VERSION/controller.yaml
```

## Update AWS EBS csi driver version of existing deployment

### Change version in overlay `kustomization.yaml`

After adding a new version of AWS EBS csi driver in the base directory, you need to update the version of AWS EBS csi driver in the `kustomization.yaml` file for your environment.

For example, if you want to update the version of AWS EBS csi driver for `test`, open the `kustomization.yaml` file and change the version number in the resources section to point to the base directory for the version you want to install.

```bash
vi aws-ebs-csi-driver/overlays/test/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: kube-system

resources:
- ../../base/v1.33

# patches:
# - path: aws-ebs-csi-driver-patch.yaml
#   target:
#     kind: Deployment
#     name: aws-ebs-csi-driver

```

### Apply the new version of AWS EBS csi driver manually (optional)

**This step is usually not necessary when AWS EBS csi driver is managed by ArgoCD.**
**It should pick up on the changes in this repository and, if configured to sync automatically, apply the changes that were done for the specific environment in the overlays directory.**

If the changes don't get applied automatically, check the sync status in ArgoCD UI.

If you want to do a dry-run first, run `kubectl -k` with the `--dry-run=client` option:

```bash
kubectl apply -k aws-ebs-csi-driver/overlays/test/ --dry-run=client
```

If needed, run `kubectl -k` command manually to apply the changes:

```bash
kubectl apply -k aws-ebs-csi-driver/overlays/test/
```
