# Installing

[](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/)

```shell
helm dependency update
helm template cilium --values values.yaml --namespace kube-system . > tmp.yaml
kubectl apply -f tmp.yaml --namespace kube-system
```
