helm dependency update
helm template dex --values values.yaml . > tmp.yaml
kubectl apply -f tmp.yaml
