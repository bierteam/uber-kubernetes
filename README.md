# Uber Kubernetes

## What is this?

This is the code repo where our friend group manages some shared infra.
What we define here is pushed to the cluster by [ArgoCD](https://argocd.lab.oscarr.nl/)

## Architecture

All the nodes are meshed together using [Wireguard](https://www.wireguard.com/),
[Tailscale](https://tailscale.com/kb/1151/what-is-tailscale/) and
[Headscale](https://headscale.net/).

This way the Kube-api and ETCD containers always have a stable way of reaching each other.

Internal load balancing of the Kube-api happens using a static pod running haproxy.

All the used DNS records point/CNAME to kubernetes.oscarr.nl

And the records under that subdomain are [automatically managed by a script](https://github.com/bierteam/kubernetes-dns)
that runs every 5 minutes as a Kubernetes cronjob.

Traefik runs as a DaemonSet on all locations and
internal Kubernetes networking is handled by [Cilium](https://cilium.io/).

```mermaid
graph

Users[End users]-- DNS magic --> T1 & T2 & T3 & T4

subgraph Site1[Houten]
    subgraph k8s-1
        T1[Traefik] --> C1[Container X]
    end
end

subgraph Site2[Ede 1]
    subgraph k8s-2
        T2[Traefik]  --> C1
    end
end

subgraph Site3[Ede 2]
    subgraph k8s-3
        T3[Traefik] --> C1
    end
end

subgraph Site4[Veenendaal]
    subgraph k8s-4
        T4[Traefik] --> C1
    end
end

k8s-1 & k8s-2 & k8s-3 & k8s-4 -- Mesh VPN key exchange --- VPN[headscale.oscarr.nl]
```

## Connecting to the cluster

How to connect to the cluster is described [here](CONNECTING.md)
