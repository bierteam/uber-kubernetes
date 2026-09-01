# [Talos](https://www.talos.dev/) IPv6 only cluster

Managed with [topf](https://postfinance.github.io/topf/main/). It replaced
[talhelper](https://budimanjojo.github.io/talhelper/latest/), which is no longer
maintained.

## Prerequisites

```sh
brew install postfinance/tap/topf sops siderolabs/tap/talosctl
```

`sops` is **required**, not optional: talhelper embedded it as a library, topf
shells out to the binary to decrypt `secrets.yaml`. Without it topf reads the
encrypted file as-is and fails.

## Layout

| Path | Contents |
| --- | --- |
| `topf.yaml` | Cluster name, endpoint, versions, node list |
| `schematic.yaml` | Image factory schematic for the control planes, referenced as `@schematic.yaml` |
| `secrets.yaml` | SOPS-encrypted Talos secrets bundle (was `talsecret.sops.yaml`) |
| `patches/all/` | Applied to every node |
| `patches/control-plane/` | Control planes only |
| `patches/node/<host>/` | Per-node (none currently) |

Patches merge in that order, lexicographically within a directory — hence the
numeric prefixes. `.yaml.tpl` files are Go templates with `.Node.Host`,
`.Node.Role`, `.Data` and sprig functions available.

`secureboot` and `schematicId` are set **per node**, not cluster-wide. This is
required, not redundant: topf resolves secureboot as `node || cluster`, so a
cluster-level `true` cannot be overridden — talos4 (bare metal, no TPM) would be
forced onto the SecureBoot installer.

## Everyday: changing config

```sh
topf render                # write machine configs to ./output for inspection
topf apply --dry-run       # diff against what the nodes are running
topf apply                 # apply
```

`topf nodes` lists nodes with running version and schematic. `topf kubeconfig`
and `topf talosconfig` print credentials to stdout. `topf schematic-ids` shows
what `schematic.yaml` resolves to.

Scope any command to one node with `--nodes-filter <regex>` (matches the host
name).

> **`apply` and `upgrade` prompt for confirmation.** If you pipe `/dev/null` into
> them they loop on the prompt, then exit **0 without doing anything**. An exit
> code of 0 is not proof the change landed — always confirm with `topf nodes` or
> a follow-up `--dry-run`.
> `topf render` writes complete machine configs, including CA private keys in
> plaintext, to `output/`. Gitignored, but delete them when done.

## Talos upgrade

1. Bump `talosVersion` in topf.yaml (commit it)
2. Upgrade — topf builds the factory installer image per node from
   `talosVersion`, `schematicId` and `secureboot`, and does control planes one at
   a time

```sh
topf upgrade --dry-run
topf upgrade --drain
```

## Kubernetes upgrade

topf has no `upgrade-k8s`, and no `gencommand` equivalent — that is a deliberate
gap. `topf apply` would rewrite the static pod manifests with no version-skew or
readiness checks, which is only safe for patch bumps. Drive it with `talosctl`,
which discovers the other nodes from one control plane, then record the result so
the next `topf apply` does not revert it.

```sh
talosctl --talosconfig <(topf talosconfig) \
  -n 2a05:f080:0:3800:be24:11ff:fe6c:6e3d upgrade-k8s --to v1.37.0 --dry-run
```

Then bump `kubernetesVersion` in topf.yaml to match and commit.

<details>
  <summary>Command output</summary>
  
  ```sh
  ❯ talosctl --talosconfig <(topf talosconfig) -n 2a05:f080:0:3800:be24:11ff:fe6c:6e3d upgrade-k8s --to v1.37.0
  automatically detected the lowest Kubernetes version 1.36.4
  discovered controlplane nodes ["2a05:f080:0:3800::1001" "2a05:f080:0:3800::1008" "2a05:f080:0:3800::1000"]
  discovered worker nodes ["2a05:f080:0:3800:56bf:64ff:fe93:5e26"]
  > "2a05:f080:0:3800::1001": Talos version 1.14.0-rc.2 is compatible with Kubernetes version 1.37.0
  > "2a05:f080:0:3800::1008": Talos version 1.14.0-rc.2 is compatible with Kubernetes version 1.37.0
  > "2a05:f080:0:3800::1000": Talos version 1.14.0-rc.2 is compatible with Kubernetes version 1.37.0
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": Talos version 1.14.0-rc.2 is compatible with Kubernetes version 1.37.0
  checking for removed Kubernetes component flags
  checking for removed Kubernetes API resource versions
  > "2a05:f080:0:3800::1001": pre-pulling registry.k8s.io/kube-apiserver:v1.37.0
  > "2a05:f080:0:3800::1008": pre-pulling registry.k8s.io/kube-apiserver:v1.37.0
  > "2a05:f080:0:3800::1000": pre-pulling registry.k8s.io/kube-apiserver:v1.37.0
  > "2a05:f080:0:3800::1001": pre-pulling registry.k8s.io/kube-controller-manager:v1.37.0
  > "2a05:f080:0:3800::1008": pre-pulling registry.k8s.io/kube-controller-manager:v1.37.0
  > "2a05:f080:0:3800::1000": pre-pulling registry.k8s.io/kube-controller-manager:v1.37.0
  > "2a05:f080:0:3800::1001": pre-pulling registry.k8s.io/kube-scheduler:v1.37.0
  > "2a05:f080:0:3800::1008": pre-pulling registry.k8s.io/kube-scheduler:v1.37.0
  > "2a05:f080:0:3800::1000": pre-pulling registry.k8s.io/kube-scheduler:v1.37.0
  > "2a05:f080:0:3800::1001": pre-pulling ghcr.io/siderolabs/kubelet:v1.37.0
  > "2a05:f080:0:3800::1008": pre-pulling ghcr.io/siderolabs/kubelet:v1.37.0
  > "2a05:f080:0:3800::1000": pre-pulling ghcr.io/siderolabs/kubelet:v1.37.0
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": pre-pulling ghcr.io/siderolabs/kubelet:v1.37.0
  updating "kube-apiserver" to version "1.37.0"
  > "2a05:f080:0:3800::1001": starting update
  > update kube-apiserver: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1001": machine configuration patched
  > "2a05:f080:0:3800::1001": waiting for kube-apiserver pod update
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1001": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  < "2a05:f080:0:3800::1001": successfully updated
  > "2a05:f080:0:3800::1008": starting update
  > update kube-apiserver: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1008": machine configuration patched
  > "2a05:f080:0:3800::1008": waiting for kube-apiserver pod update
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1008": kube-apiserver: pod is not ready, waiting
  < "2a05:f080:0:3800::1008": successfully updated
  > "2a05:f080:0:3800::1000": starting update
  > update kube-apiserver: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1000": machine configuration patched
  > "2a05:f080:0:3800::1000": waiting for kube-apiserver pod update
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: waiting, config version mismatch: got "2", expected "3"
  > "2a05:f080:0:3800::1000": kube-apiserver: pod is not ready, waiting
  < "2a05:f080:0:3800::1000": successfully updated
  updating "kube-controller-manager" to version "1.37.0"
  > "2a05:f080:0:3800::1001": starting update
  > update kube-controller-manager: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1001": machine configuration patched
  > "2a05:f080:0:3800::1001": waiting for kube-controller-manager pod update
  > "2a05:f080:0:3800::1001": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1001": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1001": kube-controller-manager: pod is not ready, waiting
  < "2a05:f080:0:3800::1001": successfully updated
  > "2a05:f080:0:3800::1008": starting update
  > update kube-controller-manager: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1008": machine configuration patched
  > "2a05:f080:0:3800::1008": waiting for kube-controller-manager pod update
  > "2a05:f080:0:3800::1008": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1008": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1008": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1008": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1008": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1008": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1008": kube-controller-manager: pod is not ready, waiting
  < "2a05:f080:0:3800::1008": successfully updated
  > "2a05:f080:0:3800::1000": starting update
  > update kube-controller-manager: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1000": machine configuration patched
  > "2a05:f080:0:3800::1000": waiting for kube-controller-manager pod update
  > "2a05:f080:0:3800::1000": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-controller-manager: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1000": kube-controller-manager: pod is not ready, waiting
  > "2a05:f080:0:3800::1000": kube-controller-manager: pod is not ready, waiting
  < "2a05:f080:0:3800::1000": successfully updated
  updating "kube-scheduler" to version "1.37.0"
  > "2a05:f080:0:3800::1001": starting update
  > update kube-scheduler: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1001": machine configuration patched
  > "2a05:f080:0:3800::1001": waiting for kube-scheduler pod update
  > "2a05:f080:0:3800::1001": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1001": kube-scheduler: pod is not ready, waiting
  > "2a05:f080:0:3800::1001": kube-scheduler: pod is not ready, waiting
  > "2a05:f080:0:3800::1001": kube-scheduler: pod is not ready, waiting
  > "2a05:f080:0:3800::1001": kube-scheduler: pod is not ready, waiting
  < "2a05:f080:0:3800::1001": successfully updated
  > "2a05:f080:0:3800::1008": starting update
  > update kube-scheduler: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1008": machine configuration patched
  > "2a05:f080:0:3800::1008": waiting for kube-scheduler pod update
  < "2a05:f080:0:3800::1008": successfully updated
  > "2a05:f080:0:3800::1000": starting update
  > update kube-scheduler: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1000": machine configuration patched
  > "2a05:f080:0:3800::1000": waiting for kube-scheduler pod update
  > "2a05:f080:0:3800::1000": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-scheduler: waiting, config version mismatch: got "1", expected "2"
  > "2a05:f080:0:3800::1000": kube-scheduler: pod is not ready, waiting
  > "2a05:f080:0:3800::1000": kube-scheduler: pod is not ready, waiting
  > "2a05:f080:0:3800::1000": kube-scheduler: pod is not ready, waiting
  < "2a05:f080:0:3800::1000": successfully updated
  updating kube-proxy to version "1.37.0"
  > "2a05:f080:0:3800::1001": starting update
  > "2a05:f080:0:3800::1008": starting update
  > "2a05:f080:0:3800::1000": starting update
  updating kubelet to version "1.37.0"
  > "2a05:f080:0:3800::1001": starting update
  > update kubelet: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1001": machine configuration patched
  > "2a05:f080:0:3800::1001": waiting for kubelet restart
  > "2a05:f080:0:3800::1001": waiting for node update
  < "2a05:f080:0:3800::1001": successfully updated
  > "2a05:f080:0:3800::1008": starting update
  > update kubelet: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1008": machine configuration patched
  > "2a05:f080:0:3800::1008": waiting for kubelet restart
  > "2a05:f080:0:3800::1008": waiting for node update
  < "2a05:f080:0:3800::1008": successfully updated
  > "2a05:f080:0:3800::1000": starting update
  > update kubelet: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800::1000": machine configuration patched
  > "2a05:f080:0:3800::1000": waiting for kubelet restart
  > "2a05:f080:0:3800::1000": waiting for node update
  < "2a05:f080:0:3800::1000": successfully updated
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": starting update
  > update kubelet: 1.36.4 -> 1.37.0
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": machine configuration patched
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": waiting for kubelet restart
  > "2a05:f080:0:3800:56bf:64ff:fe93:5e26": waiting for node update
  < "2a05:f080:0:3800:56bf:64ff:fe93:5e26": successfully updated
  updating manifests
  > skipped Namespace/kubelet-serving-cert-approver: no changes
  > skipped ClusterRole/certificates:kubelet-serving-cert-approver: no changes
  > skipped ClusterRole/events:kubelet-serving-cert-approver: no changes
  > skipped ClusterRole/system:aggregated-metrics-reader: no changes
  > skipped ClusterRole/system:coredns: no changes
  > skipped ClusterRole/system:metrics-server: no changes
  > skipped ClusterRole/system:talos-nodes: no changes
  > skipped ConfigMap/kube-system/coredns: no changes
  > skipped ConfigMap/kube-system/kubeconfig-in-cluster: no changes
  > skipped Secret/kube-system/bootstrap-token-2p0lf1: no changes
  > skipped ClusterRoleBinding/kubelet-serving-cert-approver: no changes
  > skipped ClusterRoleBinding/metrics-server:system:auth-delegator: no changes
  > skipped ClusterRoleBinding/system-bootstrap-approve-node-client-csr: no changes
  > skipped ClusterRoleBinding/system-bootstrap-node-bootstrapper: no changes
  > skipped ClusterRoleBinding/system-bootstrap-node-renewal: no changes
  > skipped ClusterRoleBinding/system:coredns: no changes
  > skipped ClusterRoleBinding/system:metrics-server: no changes
  > skipped ClusterRoleBinding/system:talos-nodes: no changes
  > skipped ServiceAccount/kube-system/coredns: no changes
  > skipped ServiceAccount/kube-system/metrics-server: no changes
  > skipped ServiceAccount/kubelet-serving-cert-approver/kubelet-serving-cert-approver: no changes
  > skipped RoleBinding/default/events:kubelet-serving-cert-approver: no changes
  > skipped RoleBinding/kube-system/metrics-server-auth-reader: no changes
  > skipped Service/kube-system/kube-dns: no changes
  > skipped Service/kube-system/metrics-server: no changes
  > skipped Service/kubelet-serving-cert-approver/kubelet-serving-cert-approver: no changes
  < configured Deployment/kube-system/coredns
  --- a/apps/v1.Deployment/kube-system/coredns
  +++ b/apps/v1.Deployment/kube-system/coredns
  @@ -5,7 +5,7 @@
      config.k8s.io/owning-inventory: talos-bootstrap-manifests-inventory
      deployment.kubernetes.io/revision: "4"
    creationTimestamp: "2026-01-02T01:42:17Z"
  -  generation: 4
  +  generation: 5
    labels:
      k8s-app: kube-dns
      kubernetes.io/name: CoreDNS
  @@ -31,6 +31,19 @@
          k8s-app: kube-dns
      spec:
        affinity:
  +        nodeAffinity:
  +          requiredDuringSchedulingIgnoredDuringExecution:
  +            nodeSelectorTerms:
  +            - matchExpressions:
  +              - key: kubernetes.io/os
  +                operator: In
  +                values:
  +                - linux
  +              - key: kubernetes.io/arch
  +                operator: In
  +                values:
  +                - amd64
  +                - arm64
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
  @@ -49,7 +62,7 @@
          env:
          - name: GOMEMLIMIT
            value: 161MiB
  -        image: registry.k8s.io/coredns/coredns:v1.14.6
  +        image: registry.k8s.io/coredns/coredns:v1.14.7
          imagePullPolicy: IfNotPresent
          livenessProbe:
            failureThreshold: 5

  > skipped Deployment/kube-system/metrics-server: no changes
  > skipped Deployment/kubelet-serving-cert-approver/kubelet-serving-cert-approver: no changes
  > skipped APIService/v1beta1.metrics.k8s.io: no changes
  waiting for kubernetes objects to be fully reconciled
  done
  ```
  
</details>

## Adding or rebuilding a node

1. Clone the Talos VM template in Proxmox and increase the disk size to 100 GB
   afterwards or have bare metal hardware boot with PXE
2. Find the ip in the proxmox summary (provided by the qemu agent) or guess it by using the MAC address
3. Add the node to `topf.yaml`
4. `topf apply --nodes-filter <host>`
5. Verify it joined:

   ```sh
   topf nodes
   talosctl --talosconfig <(topf talosconfig) \
     -n 2a05:f080:0:3800:be24:11ff:fe6c:6e3d etcd members
   ```

## Config documents

Talos 1.14 split `v1alpha1` into typed documents, and topf 0.6 generates them, so
almost every patch is now a document instead of a `machine.*` / `cluster.*` field.

Only `cluster.etcd.advertisedSubnets` (`control-plane/etcd.yaml`) is still
`v1alpha1`; it has no document equivalent yet.

```sh
topf render -o output
talosctl validate -c output/talos1.yaml -m metal
```

## Secrets

The CAs in `secrets.yaml` (Talos, Kubernetes, aggregator, etcd) are valid until
**2035-12-30**. The bootstrap token, cluster secret and service account key do
not expire. `topf kubeconfig` mints a 12h admin cert on demand; kubelet serving
certs rotate automatically.

topf has no rotation support and no guide. The mechanism is `talosctl rotate-ca`
(`--dry-run` defaults to true). **Note:** topf regenerates every machine config
from `secrets.yaml`, so rotating out of band without updating that file means the
next `topf apply` pushes the old CAs back and breaks the cluster.

## Other stuff

- [Talos docs](https://docs.siderolabs.com/talos/v1.14/overview/what-is-talos)
- [topf docs](https://postfinance.github.io/topf/main/)
- [Image Factory](https://factory.talos.dev/)
