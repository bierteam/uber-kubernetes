# Installing

```shell
helm dependency update
helm template longhorn --values values.yaml --namespace longhorn . > tmp.yaml
kubectl apply -f tmp.yaml --namespace longhorn
```
