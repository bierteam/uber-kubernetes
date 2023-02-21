# Install argocd

The first install/bootstrap is manual. Then ArcoCD takes over.
I got the inspiration from [this blogpost by Burak Kurt](https://medium.com/devopsturkiye/self-managed-argo-cd-app-of-everything-a226eb100cf0)

```bash
helm dependency update
helm template argocd . > bootstrap.yaml
kubectl apply -f bootstrap.yaml
```
