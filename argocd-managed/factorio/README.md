# Installing

```shell
helm dependency update
helm template factorio --values values.yaml --namespace factorio . > tmp.yaml
kubectl apply -f tmp.yaml --namespace factorio
```
