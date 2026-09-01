---
apiVersion: v1alpha1
kind: KubeNodeConfig
nodeIP:
  validSubnets:
    - 2000::/3
---
apiVersion: v1alpha1
kind: DHCPv6Config
name: {{ index .Node.Data "link" | default .Data.link }}
