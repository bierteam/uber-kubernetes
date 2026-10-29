# Installing

```shell
helm dependency update
helm template sealed-secrets --values values.yaml --namespace kube-system . > tmp.yaml
kubectl apply -f tmp.yaml --namespace kube-system
```
