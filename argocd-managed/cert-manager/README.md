helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --version v1.10.0 \
 --create-namespace \
 --set installCRDs=true \
 --values values.yaml
