```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install --atomic --force prometheus-operator-stack prometheus-community/kube-prometheus-stack -f values.yaml
```