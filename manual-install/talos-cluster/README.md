# [Talos](https://www.talos.dev/) IPv6 only cluster

This cluster is used as a playground, no argocd etc (yet)

It used to be managed with [Talhelper](https://budimanjojo.github.io/talhelper/latest/),
which is no longer maintained. It now uses
[topf](https://postfinance.github.io/topf/main/), which generates *and* applies
the machine configs itself instead of writing them to `clusterconfig/` first.

Install `topf`, `sops` and `talosctl` via [Brew](https://brew.sh/) and you can
start making changes or doing life cycle management on it. `sops` is a hard
requirement: unlike talhelper, topf shells out to the `sops` binary to decrypt
`secrets.yaml`.

```sh
brew install postfinance/tap/topf sops siderolabs/tap/talosctl
```

## Layout

| File | Contents |
| --- | --- |
| `topf.yaml` | Cluster name, endpoint, versions and the node list |
| `schematic.yaml` | Image factory schematic for the control planes, referenced as `@schematic.yaml` |
| `secrets.yaml` | SOPS-encrypted Talos secrets bundle (was `talsecret.sops.yaml`) |
| `patches/all/` | Patches applied to every node |
| `patches/control-plane/` | Patches applied to the control planes only |
| `patches/node/<host>/` | Per-node patches (none right now) |

Patches merge in that order, and within a directory in lexicographical order —
hence the numeric prefixes. `.yaml.tpl` files are Go templates with access to
`.Node.Host`, `.Node.Role`, `.Data` and friends.

Everything that talhelper set implicitly now lives in a patch:
`clusterPodNets`/`clusterSvcNets`/`cniConfig` in `all/02-cluster-network.yaml`
and the hostname in `all/01-hostname.yaml.tpl`. topf only feeds `clusterName`,
`clusterEndpoint` and `kubernetesVersion` into `talos generate`, so dropping
either of those patches silently reverts the cluster to the IPv4 defaults or to
auto-generated `talos-xxx-xxx` hostnames.

## Making a config change

```sh
topf render          # write the machine configs to ./output for inspection
topf apply --dry-run # show the diff against what the nodes are running
topf apply           # apply it
```

`topf nodes` lists the nodes with their running Talos version and schematic.
`topf kubeconfig` and `topf talosconfig` print credentials to stdout.

## Talos upgrade

1. Bump `talosVersion` in topf.yaml (don't forget to commit)
2. Run the upgrade. topf builds the factory.talos.dev installer image per node
   from `talosVersion`, `schematicId` and `secureboot`, and walks the control
   planes one at a time.

```sh
topf upgrade --dry-run
topf upgrade --drain
```

Use `topf schematicids` to check which image factory ID `schematic.yaml`
resolves to before upgrading.

## Kubernetes upgrade

topf has no `upgrade-k8s` of its own — `topf apply` would rewrite the static pod
manifests without any version skew or component readiness checks, which is only
safe for patch bumps. So drive the upgrade with `talosctl` and then record the
result in topf.yaml, otherwise the next `topf apply` reverts it.

1. Run the upgrade against one control plane; talosctl discovers the rest.
2. Bump `kubernetesVersion` in topf.yaml to match (don't forget to commit)

```sh
talosctl --talosconfig <(topf talosconfig) upgrade-k8s --to v1.36.4 --nodes 2a05:f080:0:3800:be24:11ff:fe6c:6e3d
```

<details>
  <summary>Command output</summary>
  
  ```sh
  ❯ talosctl upgrade-k8s --talosconfig=./clusterconfig/talosconfig --to=v1.35.1 --nodes=2a02:a470:edcd:0:be24:11ff:fe6c:6e3d;
  automatically detected the lowest Kubernetes version 1.35.1
  discovered controlplane nodes ["2a02:a470:edcd::d81d" "2a05:f080:0:3800:be24:11ff:fe64:a994" "2a02:a470:edcd::c0b6"]
  discovered worker nodes []
  > "2a02:a470:edcd::d81d": Talos version 1.12.4 is compatible with Kubernetes version 1.35.1
  > "2a02:a470:edcd::c0b6": Talos version 1.12.4 is compatible with Kubernetes version 1.35.1
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": Talos version 1.12.4 is compatible with Kubernetes version 1.35.1
  > "2a02:a470:edcd::d81d": pre-pulling registry.k8s.io/kube-apiserver:v1.35.1
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": pre-pulling registry.k8s.io/kube-apiserver:v1.35.1
  > "2a02:a470:edcd::c0b6": pre-pulling registry.k8s.io/kube-apiserver:v1.35.1
  > "2a02:a470:edcd::d81d": pre-pulling registry.k8s.io/kube-controller-manager:v1.35.1
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": pre-pulling registry.k8s.io/kube-controller-manager:v1.35.1
  > "2a02:a470:edcd::c0b6": pre-pulling registry.k8s.io/kube-controller-manager:v1.35.1
  > "2a02:a470:edcd::d81d": pre-pulling registry.k8s.io/kube-scheduler:v1.35.1
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": pre-pulling registry.k8s.io/kube-scheduler:v1.35.1
  > "2a02:a470:edcd::c0b6": pre-pulling registry.k8s.io/kube-scheduler:v1.35.1
  > "2a02:a470:edcd::d81d": pre-pulling ghcr.io/siderolabs/kubelet:v1.35.1
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": pre-pulling ghcr.io/siderolabs/kubelet:v1.35.1
  > "2a02:a470:edcd::c0b6": pre-pulling ghcr.io/siderolabs/kubelet:v1.35.1
  updating "kube-apiserver" to version "1.35.1"
  > "2a02:a470:edcd::d81d": starting update
  > "2a02:a470:edcd::d81d": machine configuration patched
  > "2a02:a470:edcd::d81d": waiting for kube-apiserver pod update
  < "2a02:a470:edcd::d81d": successfully updated
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": starting update
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": machine configuration patched
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": waiting for kube-apiserver pod update
  < "2a05:f080:0:3800:be24:11ff:fe64:a994": successfully updated
  > "2a02:a470:edcd::c0b6": starting update
  > "2a02:a470:edcd::c0b6": machine configuration patched
  > "2a02:a470:edcd::c0b6": waiting for kube-apiserver pod update
  < "2a02:a470:edcd::c0b6": successfully updated
  updating "kube-controller-manager" to version "1.35.1"
  > "2a02:a470:edcd::d81d": starting update
  > "2a02:a470:edcd::d81d": machine configuration patched
  > "2a02:a470:edcd::d81d": waiting for kube-controller-manager pod update
  < "2a02:a470:edcd::d81d": successfully updated
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": starting update
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": machine configuration patched
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": waiting for kube-controller-manager pod update
  < "2a05:f080:0:3800:be24:11ff:fe64:a994": successfully updated
  > "2a02:a470:edcd::c0b6": starting update
  > "2a02:a470:edcd::c0b6": machine configuration patched
  > "2a02:a470:edcd::c0b6": waiting for kube-controller-manager pod update
  < "2a02:a470:edcd::c0b6": successfully updated
  updating "kube-scheduler" to version "1.35.1"
  > "2a02:a470:edcd::d81d": starting update
  > "2a02:a470:edcd::d81d": machine configuration patched
  > "2a02:a470:edcd::d81d": waiting for kube-scheduler pod update
  < "2a02:a470:edcd::d81d": successfully updated
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": starting update
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": machine configuration patched
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": waiting for kube-scheduler pod update
  < "2a05:f080:0:3800:be24:11ff:fe64:a994": successfully updated
  > "2a02:a470:edcd::c0b6": starting update
  > "2a02:a470:edcd::c0b6": machine configuration patched
  > "2a02:a470:edcd::c0b6": waiting for kube-scheduler pod update
  < "2a02:a470:edcd::c0b6": successfully updated
  updating kube-proxy to version "1.35.1"
  > "2a02:a470:edcd::d81d": starting update
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": starting update
  > "2a02:a470:edcd::c0b6": starting update
  updating kubelet to version "1.35.1"
  > "2a02:a470:edcd::d81d": starting update
  > "2a02:a470:edcd::d81d": machine configuration patched
  > "2a02:a470:edcd::d81d": waiting for node update
  < "2a02:a470:edcd::d81d": successfully updated
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": starting update
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": machine configuration patched
  > "2a05:f080:0:3800:be24:11ff:fe64:a994": waiting for node update
  < "2a05:f080:0:3800:be24:11ff:fe64:a994": successfully updated
  > "2a02:a470:edcd::c0b6": starting update
  > "2a02:a470:edcd::c0b6": machine configuration patched
  > "2a02:a470:edcd::c0b6": waiting for node update
  < "2a02:a470:edcd::c0b6": successfully updated
  updating manifests
  > processing manifest v1.Secret/kube-system/bootstrap-token-2p0lf1
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system-bootstrap-approve-node-client-csr
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system-bootstrap-node-bootstrapper
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system-bootstrap-node-renewal
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/flannel
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/flannel
  < no changes
  > processing manifest v1.ServiceAccount/kube-system/flannel
  < no changes
  > processing manifest v1.ConfigMap/kube-system/kube-flannel-cfg
  < no changes
  > processing manifest apps/v1.DaemonSet/kube-system/kube-flannel
  < no changes
  > processing manifest apps/v1.DaemonSet/kube-system/kube-proxy
  < no changes
  > processing manifest v1.ServiceAccount/kube-system/kube-proxy
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/kube-proxy
  < no changes
  > processing manifest v1.ServiceAccount/kube-system/coredns
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/system:coredns
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system:coredns
  < no changes
  > processing manifest v1.ConfigMap/kube-system/coredns
  < no changes
  > processing manifest apps/v1.Deployment/kube-system/coredns
  < no changes
  > processing manifest v1.Service/kube-system/kube-dns
  < no changes
  > processing manifest v1.ConfigMap/kube-system/kubeconfig-in-cluster
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system:talos-nodes
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/system:talos-nodes
  < no changes
  > processing manifest v1.ServiceAccount/kube-system/metrics-server
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/system:aggregated-metrics-reader
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/system:metrics-server
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.RoleBinding/kube-system/metrics-server-auth-reader
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/metrics-server:system:auth-delegator
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/system:metrics-server
  < no changes
  > processing manifest v1.Service/kube-system/metrics-server
  < no changes
  > processing manifest apps/v1.Deployment/kube-system/metrics-server
  < no changes
  > processing manifest apiregistration.k8s.io/v1.APIService/v1beta1.metrics.k8s.io
  < no changes
  > processing manifest v1.Namespace/kubelet-serving-cert-approver
  < no changes
  > processing manifest v1.ServiceAccount/kubelet-serving-cert-approver/kubelet-serving-cert-approver
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/certificates:kubelet-serving-cert-approver
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRole/events:kubelet-serving-cert-approver
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.RoleBinding/default/events:kubelet-serving-cert-approver
  < no changes
  > processing manifest rbac.authorization.k8s.io/v1.ClusterRoleBinding/kubelet-serving-cert-approver
  < no changes
  > processing manifest v1.Service/kubelet-serving-cert-approver/kubelet-serving-cert-approver
  < no changes
  > processing manifest apps/v1.Deployment/kubelet-serving-cert-approver/kubelet-serving-cert-approver
  < no changes
  waiting for all manifests to be applied
  ```
  
</details>

## Other stuff

[Talos docs](https://docs.siderolabs.com/talos/v1.13/overview/what-is-talos)
[topf docs](https://postfinance.github.io/topf/main/)
