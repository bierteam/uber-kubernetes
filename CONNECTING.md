# Connecting with Kubectl

To connect with Kubectl, you will need the following tools and configuration:

[kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) en [kubelogin](https://github.com/int128/kubelogin#setup)

You can place the following configuration in your $HOME/.kube/config file:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1UQXlNakl4TXpBeU9Gb1hEVE15TVRBeE9USXhNekF5T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBUFBUCldiajd5UkZ3V3VjM2t6RWc1VnphSjlCT1BIbk5WOXd1VmwvQmthUjN2Y0twVEk3U28zMjkrUEF2TkVPc3A5NUoKZVpKNTFBanE1N245aGRsZWJFQmF2bG9TWC91SVlURDNnY3Nzckl6RFhnSVNJSkJBbUt3VjB4cTdpc09tM0F1Uwp1ZEV5d05OeVkyaXQzTGxyU2NVcWJXVDVZU3hYVHQreVZDRjc0M3FKNGRpWkFNVnU0cGR2cmlPdHVtdFJzVTNMCmV4bmt1a1FuSWxoZ3JQRExBNEFOdjVueGFBYTgyQTRnNUNwNnZIaWIrV2dYdmtocXNLVzlRaHUvdTRiYkhkQ2QKZkZHb2JPMzVnUkNMNVBmU29EOUd6bDNVZlVaYlpLTmk3dHkxRWxkRW5aYTdmRGF6RFZLMnhXZ2lpWExMazgvegpEMHZCbGQ4RFR1Y0poT0FOeXU4Q0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZMU2RLRG9VOHVXQmNLRkhsYzFKWkxPWUZFV3dNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBS0ZLTC9YMHRMTFBVNnpTQjlCZwppQXNRUUdnVGNkOEpNUUM4c0Jsem9JVW5tV2NtdzJnT0NDOTVJN0FZb2JvRktocUJoVDRNNi9oNFV3TEVBUk9VCkVkcWw3YytSLzRhL0FzRWszTFhheWdzQ09qZ0hLVWlGMXk5cG9WR0RxV1V0dDFrUGJSSVVCSXRxaDJsWlY0amkKRStkdUNHdnlpUU5wZEVHMW9CR25DUDU2Qkh4TVlkcEVSZEZQRjc3TW5Wd2RXYW5DTzV3ZDUvRktOQXBIa1ZrbgpXN2hYSkFmM1NaQTlDMmZEdU92Nlk1ZjZNS2Jyb1dYU01ldktDRndiWW1VcHJVcUkxdkNoNmEwSlVMb3FNYlZLCmRTU21IdktpM1VjTW80QlJ4YS9MNHlhcmhlSnZEVVViV0tld3owTEdEUjQ4T1dLMG5ZbFhGQnBDbXkrSjlNV04KSGtBPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://kubernetes.oscarr.nl:8443
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
