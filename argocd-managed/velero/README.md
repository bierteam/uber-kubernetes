# Installing

```shell
helm dependency update
helm template velero --values values.yaml --namespace velero . > tmp.yaml
kubectl apply -f tmp.yaml --namespace velero
```
