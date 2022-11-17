helm upgrade --install traefik traefik/traefik --version 18.1.0 -n traefik --values values.yaml --set installCRDs=true
