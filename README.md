# k8s infra applications - example

## Install kustomize if not done yet

Install Kustomize by downloading precompiled binaries.
Binaries at various versions for linux, MacOs and Windows are published on the releases page.

The following script detects your OS and downloads the appropriate kustomize binary to your current working directory.

```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

## How it works - Example with ArgoCD

### 1. Review Resource Files

The `base/v2.11.3` directory holds the common resources, such as standard deployment.yaml or service.yaml resource configuration files.

---

**`argo-cd/base/kustomization.yaml`**

The kustomization.yaml file is the most important file in the `base` directory and it describes what resources you use.

**`argo-cd/base/namespace.yaml`**

This is the base configuration for the namespace to be created for argocd and will be used by kustomizations in the overlays directory. It usually is not necessary to modify this file, so it does not get patched by the overlays.

---

### 2. Define Test Environemnt Patch Files

The `overlays` directory houses environment-specific patches. It has 2 sub-directories (one for each environment):

- `test`
- `prod`

---

**`argo-cd/overlays/test/kustomization.yaml`**

This file defines which resource configuration to reference and apply patches, which allows partial YAML files to be defined and overlaid on top of the resource.

---

### 3. Review Patches

To confirm that your patch config file changes are correct before applying to the cluster, you can run e.g.:

```bash
cd argo-cd
kustomize build overlays/test
```

---

### 4. Apply Patches

Once you have confirmed that your patches are correct, use the following command to apply the settings to your cluster:

```bash
cd argo-cd
kubectl apply -k overlays/test
```

---

### 5. Define Prod Environment Patch Files

**Note: this is just an example and not applicable to the current setup right now.**

**`argo-cd/overlays/prod/deployment.yaml`**

We can use this file to change a deployment we are creating.

---

### 6. Review Prod Patches

To see if production values are being applied, run:

```bash
cd argo-cd
kustomize build overlays/prod
```

Once you have reviewed, apply the overlay to the cluster with:

```bash
cd argo-cd
kubectl apply -k overlays/prod
```

### Patch Config map to set the argocd-server path

Use the `argocd-cmd-params-cm.yaml` file to update argocd-server path:

```bash
cd argo-cd
kubectl apply -k argocd-cmd-params-cm.yaml
```

Afterwards, redeploy the argocd-server deployment:

```bash
kubectl -n argocd rollout restart deployment/argocd-server
```
