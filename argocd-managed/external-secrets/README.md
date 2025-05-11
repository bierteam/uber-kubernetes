# Installing

```shell
helm dependency update
helm template external-secrets --values values.yaml --namespace external-secrets . > tmp.yaml
kubectl apply -f tmp.yaml --namespace external-secrets
```
