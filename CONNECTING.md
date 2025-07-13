# Connecting with Kubectl

To connect with Kubectl, you will need the following tools and configuration:

[kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) en [kubelogin](https://github.com/int128/kubelogin#setup)

You can place the following configuration in your $HOME/.kube/config file:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJlRENDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUUREQmhyTTNNdGMyVnkKZG1WeUxXTmhRREUzTVRrNE56STVPVEV3SGhjTk1qUXdOekF4TWpJeU9UVXhXaGNOTXpRd05qSTVNakl5T1RVeApXakFqTVNFd0h3WURWUVFEREJock0zTXRjMlZ5ZG1WeUxXTmhRREUzTVRrNE56STVPVEV3V1RBVEJnY3Foa2pPClBRSUJCZ2dxaGtqT1BRTUJCd05DQUFTWm4xdDdrR2cwOERrNC9aVldMWXBqUlhMSXF4emRVdytBdkZWeHJ5d0MKWElCRDIvUDRUTXpXaXR0dWdCZlEzNllrTEZsZFFUcitvVGZ4UDJ2NFNSR2FvMEl3UURBT0JnTlZIUThCQWY4RQpCQU1DQXFRd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVXlnOUJPSkJ0RzhmbU5lVkxhV2pCCjFLdjhnMGN3Q2dZSUtvWkl6ajBFQXdJRFNRQXdSZ0loQUlVWEQrdXgwQlBoYTFTT3M4aHNSR1NPTlErcDVYUzcKSUlVVzRLQ3dHVXptQWlFQWdUeGh1RkpmbExjY0ZGVmdvY3NYRiszWk1zWnNJbTlYL2hXTWFxMytBVEE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://kubernetes.oscarr.nl:6443
  name: ubernerds
- cluster:
    server: https://kubernetes.oscarr.nl
  name: ubernerds-traefik
contexts:
- context:
    cluster: ubernerds
    user: ubernerds-oidc
  name: ubernerds
current-context: ubernerds
kind: Config
preferences: {}
users:
- name: ubernerds-oidc
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=https://auth.oscarr.nl
      - --oidc-client-id=kubernetes
      - --oidc-extra-scope=profile
      - --oidc-extra-scope=groups
      - --oidc-extra-scope=offline_access
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false
```

If you don't have a browser available where you use kubectl, you can add
the following options to the user section:

`-  --grant-type=authcode-keyboard`

This will display a URL that you can open in a browser to log in and provide
you with a code that you can copy and paste back into the terminal.

## Windows

If you want to set this up in PowerShell, make sure both binaries are in your
PATH (environment variables). The 'command' in the above config will be kubelogin
on Windows, and the line with 'oidc-login' is no longer needed:

```yaml
...
command: kubelogin
args:
- get-token
...
```
