# talos5-boot

Boots the game PC (talos5) into Talos from Home Assistant. A suspended
CronJob holds the Job; Home Assistant starts one through ArgoCD's `create-job`
resource action (the "Create Job" button in the UI, or
`kubectl -n talos5-boot create job --from=cronjob/talos5-boot <name>`). It runs
on another talos-cluster node and:

1. exits early when Talos already answers on its apid port,
2. sends a wake-on-lan magic packet to `ff02::1` on the node's LAN link,
3. waits for SSH on Bazzite and logs in with a key whose only allowed command
   sets UEFI `BootNext` to the Talos entry (`Boot0001`) and reboots,
4. waits until Talos answers again.

`BootNext` is one-shot, so rebooting from Talos lands back in Bazzite.

## One-time setup

Job SSH key, kept out of git (talos-cluster has no sealed-secrets controller):

```sh
kubectl -n talos5-boot create secret generic talos5-boot-ssh --from-file=id_ed25519=<private key>
```

On Bazzite, a sudoers drop-in so the forced command needs no password
(`sudo visudo -f /etc/sudoers.d/talos5-boot`):

```
oscar ALL=(root) NOPASSWD: /usr/bin/efibootmgr --bootnext 0001, /usr/bin/systemctl reboot
```

and the public key in `~oscar/.ssh/authorized_keys`, restricted to that command:

```
restrict,command="sudo /usr/bin/efibootmgr --bootnext 0001 && sudo /usr/bin/systemctl reboot" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhygKkcANXC7le3okUen3U6z6WXU2W44bLBpW3b5Rg2 talos5-boot
```

ArgoCD token for the `homeassistant` account, which may only run the
`create-job` action on this app's CronJob:

```sh
argocd account generate-token --account homeassistant
```

## Home Assistant

```yaml
# configuration.yaml
rest_command:
  talos5_boot:
    url: https://argocd.lab.oscarr.nl/api/v1/applications/talos5-boot/resource/actions/v2
    method: post
    headers:
      authorization: !secret argocd_talos5_boot # "Bearer <token>"
    content_type: application/json
    payload: >-
      {"action": "create-job", "namespace": "talos5-boot", "resourceName": "talos5-boot",
       "group": "batch", "version": "v1", "kind": "CronJob"}
```

Call `rest_command.talos5_boot` from a script, button or automation. The
Job's logs show progress: `kubectl -n talos5-boot logs job/<name>`.
