# Installing

```shell
helm dependency update
helm template kubeseal-webgui --values values.yaml --namespace kubeseal-webgui . > tmp.yaml
kubectl apply -f tmp.yaml --namespace kubeseal-webgui
```
