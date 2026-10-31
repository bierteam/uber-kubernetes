# Cilium

Deployed per cluster by the `cilium` ApplicationSet
(`applicationSets` in `argocd-apps/values.yaml`) to every cluster whose ArgoCD
cluster secret has the label `apps.oscarr.nl/cilium: "true"`, with `values.yaml`
plus `values-<cluster>.yaml`.

| Cluster      | ArgoCD name     | Values file                 | Status |
| ------------ | --------------- | --------------------------- | ------ |
| talos (Omni) | `talos-cluster` | `values-talos-cluster.yaml` | live   |

## Installing by hand

[](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/)

```shell
helm dependency update
helm template cilium --namespace kube-system . \
  -f values.yaml -f values-<cluster>.yaml > tmp.yaml
kubectl apply --server-side -f tmp.yaml --namespace kube-system
```
