# Installing

```shell
helm dependency update
helm template traefik --values values.yaml --namespace traefik . > tmp.yaml
kubectl apply -f tmp.yaml --namespace traefik
```
