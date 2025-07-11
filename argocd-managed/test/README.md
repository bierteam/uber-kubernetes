# Installing

```shell
helm dependency update
helm template test --values values.yaml --namespace test . > tmp.yaml
kubectl apply -f tmp.yaml --namespace test
```
