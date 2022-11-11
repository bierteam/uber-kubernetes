helm repo add dex https://charts.dexidp.io

helm template dex dex/dex --version 0.12.1 --values values.yaml > tmp.yaml

helm upgrade --install dex dex/dex --version 0.12.1 --values values.yaml -n dex
