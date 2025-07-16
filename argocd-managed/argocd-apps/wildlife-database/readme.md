# Installing

```shell
helm dependency update


helm template test --values values.yaml --namespace wildlife-database . > tmp.yaml


kubectl apply -f tmp.yaml --namespace wildlife-database

```