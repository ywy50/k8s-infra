# - op: add #action
#   path: "/spec/template/spec/affinity/nodeAffinity" #resouirce we want to change
#   value:       #value we want to use for patching
#     requiredDuringSchedulingIgnoredDuringExecution:
#       nodeSelectorTerms:
#         - matchExpressions:
#             - key: node-role.kubernetes.io/worker
#               operator: In
#               values:
#                 - 'true'


# yq '.spec.template.spec.affinity' v2.11.3/deployment.yaml



# yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions = []' argo/argo-cd/base/v2.11.3/deployment.yaml

yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' argo/argo-cd/base/v2.11.3/deployment.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator = "In"' argo/argo-cd/base/v2.11.3/deployment.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] = "true"' argo/argo-cd/base/v2.11.3/deployment.yaml


# yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions = []' argo/argo-cd/base/v2.11.3/statefulset.yaml

yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key = "node-role.kubernetes.io/worker"' argo/argo-cd/base/v2.11.3/statefulset.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator = "In"' argo/argo-cd/base/v2.11.3/statefulset.yaml
yq -i '.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] = "true"' argo/argo-cd/base/v2.11.3/statefulset.yaml