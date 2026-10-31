# CoreDNS

Cluster DNS for the talos cluster, replacing the CoreDNS that Talos deploys.
Talos only lets you pick the image and the upstreams (through `/etc/resolv.conf`);
this chart owns the Corefile, so:

- `dn42.` and `d.f.ip6.arpa.` (fd00::/8) go to Unbound on OPNsense only, the
  public resolvers can't answer them.
- Everything else goes to Unbound first and Cloudflare's DNS64 when it's down.
  All of them synthesise into 64:ff9b::/96, the NAT64 prefix on OPNsense.

Everything is named `kube-dns`, not `coredns`, so it doesn't collide with the
objects Talos created while both run.

## Handover from the Talos CoreDNS

Disabling CoreDNS in Talos (`patches/control-plane/coredns.yaml`) stops Talos
from applying it, but leaves what it already deployed. The Service is shared:
it selects only `k8s-app: kube-dns`, which both the old and new pods carry, so
DNS keeps answering throughout.

1. Push, and let ArgoCD sync the `coredns` app. It creates the `kube-dns`
   Deployment and adopts the `kube-dns` Service. Wait for the new pods to be Ready.
2. Drop the Talos inventory annotation from the Service, or a later
   `talosctl upgrade-k8s` prunes it as a manifest Talos no longer renders:

   ```sh
   kubectl -n kube-system annotate service kube-dns config.k8s.io/owning-inventory-
   ```

3. Disable it in Talos, control planes only:

   ```sh
   cd manual-install/kubernetes
   topf apply --dry-run --nodes-filter 'talos[123]'
   topf apply --nodes-filter 'talos[123]'
   ```

4. Delete the leftovers:

   ```sh
   kubectl -n kube-system delete deployment coredns
   kubectl -n kube-system delete configmap coredns
   kubectl -n kube-system delete serviceaccount coredns
   kubectl delete clusterrolebinding system:coredns
   kubectl delete clusterrole system:coredns
   ```

5. Check: `dig @fd26:4340:84fe::a` from a pod for a cluster name, a public name
   (AAAA in 64:ff9b::/96 for a v4-only host) and a `.dn42` name.
