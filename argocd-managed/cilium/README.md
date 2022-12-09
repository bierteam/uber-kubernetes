# Cilium

[](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/)

```bash
helm repo add cilium https://helm.cilium.io/
```

```bash
helm upgrade --install cilium cilium/cilium --version 1.12.3 \
  --namespace kube-system --values values.yaml
```
