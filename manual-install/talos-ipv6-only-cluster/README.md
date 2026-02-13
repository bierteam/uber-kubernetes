# [Talos](https://www.talos.dev/) IPv6 only cluster

This cluster is used as a playground, no argocd etc (yet)

It uses [Talhelper](https://budimanjojo.github.io/talhelper/latest/)
for command generation

Install `talhelper` and `talosctl` via [Brew](https://brew.sh/) and you can start
making changes or doing life cycle management on it.

## Talos upgrade

1. Bump the Talos version in talconfig.yaml (don't forget to commit)
2. Generate the Talos configs (not sure if needed but why not)
3. Genarate the Talos upgrade commands. It takes all the options needed and
   generates a custom factory.talos.dev link for an image with all the options
   and plugins we need.
4. Run the commands 1 by one and the cluster is updates in no time.

It can be automated even more, but with just a handfull vm's this will do.

```sh
❯ talhelper genconfig
There are issues with your Talhelper config file:
field: "talosVersion"
  * WARNING: "v1.12.4" might not be compatible with this Talhelper version you're using
generated config for ede in ./clusterconfig/talos-ipv6-only-cluster-ede.yaml
generated config for houten in ./clusterconfig/talos-ipv6-only-cluster-houten.yaml
generated client config in ./clusterconfig/talosconfig
generated .gitignore file in ./clusterconfig/.gitignore
❯ talhelper gencommand upgrade
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a02:a470:edcd:0:be24:11ff:fe6c:6e3d --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a02:a470:edcd:0:be24:11ff:fedb:8c0f --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a05:f080:0:3800:be24:11ff:fe64:a994 --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
❯ talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a02:a470:edcd:0:be24:11ff:fe6c:6e3d --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
watching nodes: [2a02:a470:edcd:0:be24:11ff:fe6c:6e3d]
    * 2a02:a470:edcd:0:be24:11ff:fe6c:6e3d: post check passed
❯ talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a02:a470:edcd:0:be24:11ff:fedb:8c0f --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
watching nodes: [2a02:a470:edcd:0:be24:11ff:fedb:8c0f]
    * 2a02:a470:edcd:0:be24:11ff:fedb:8c0f: post check passed
❯ talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=2a05:f080:0:3800:be24:11ff:fe64:a994 --image=factory.talos.dev/metal-installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.4;
watching nodes: [2a05:f080:0:3800:be24:11ff:fe64:a994]
    * 2a05:f080:0:3800:be24:11ff:fe64:a994: post check passed
```

## Kubernetes upgrade

Just like above we use talhelper to generate the command

1. Bump the Kubernetes version in talconfig.yaml (don't forget to commit)
2. Generate the Talos configs (not sure if needed but why not)
3. Run the command.

```sh
❯ talhelper gencommand upgrade-k8s
talosctl upgrade-k8s --talosconfig=./clusterconfig/talosconfig --to=v1.35.1 --nodes=2a02:a470:edcd:0:be24:11ff:fe6c:6e3d;
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

[Talos docs](https://docs.siderolabs.com/talos/v1.12/overview/what-is-talos)
[Talhelper docs](https://budimanjojo.github.io/talhelper/latest/)
