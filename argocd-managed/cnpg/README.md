# Installing

```shell
helm dependency update
helm template cnpg --values values.yaml --namespace cnpg-system . > tmp.yaml
kubectl apply -f tmp.yaml --namespace cnpg-system
```
