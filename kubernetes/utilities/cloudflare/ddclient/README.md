# ddclient (Cloudflare Dynamic DNS)

This folder deploys [linuxserver/ddclient](https://github.com/linuxserver/docker-ddclient) to keep the Cloudflare DNS record
for `jellyfin.timo.be` pointed at the current public IP address of the homelab.

The deployment is stateless: `ddclient.conf` is generated from this folder into a ConfigMap via Kustomize's
`configMapGenerator`, and mounted read-only into the pod. There is no PVC; ddclient's `/config` directory (used for its
runtime PID file and IP-change cache) is an ephemeral `emptyDir`, so on every pod restart ddclient simply re-detects the
current IP and, if needed, re-applies it to Cloudflare - no persistent state is required.

## Secret handling

The Cloudflare API token is never stored in `ddclient.conf`/the ConfigMap. Instead, `ddclient.conf` uses ddclient's native
`password_env=CLOUDFLARE_API_TOKEN` directive, which tells ddclient to read the real token from the `CLOUDFLARE_API_TOKEN`
environment variable at runtime.

Rather than provisioning a second Cloudflare API token, the Deployment reuses the `cloudflare-token-secret` Secret (key
`cloudflare-token`) that already exists in the `cert-manager` namespace for the `letsencrypt-production`/`letsencrypt-staging`
ClusterIssuers' DNS-01 challenges - that token already has `Zone:DNS:Edit` permission scoped to the `timo.be` zone, which is
exactly what ddclient needs. The [emberstack Reflector](https://github.com/emberstack/kubernetes-reflector) operator mirrors
that Secret into the `utilities` namespace (see the `reflector.v1.k8s.emberstack.com/reflection-auto-namespaces` annotation on
`cloudflare-token-secret` in `kubernetes/cluster-bootstrap/cert-manager/kustomization.yaml`), and this Deployment reads it
straight from there via `secretKeyRef`.

## Security context / capabilities

The `lscr.io/linuxserver/ddclient` image's s6-overlay init flow needs to run as root at the container level (its own
`abc` user drops privileges internally), and normally relies on a writable root filesystem and unrestricted
capabilities to prepare `/config` and `/run` before switching to `abc`. This Deployment keeps `readOnlyRootFilesystem:
true` and `capabilities.drop: [ALL]` as the baseline (per the repo hardening policy) and only adds back the five
capabilities actually required for that init sequence to succeed against writable `emptyDir` mounts:

- `CHOWN`, `FOWNER` - let the init script `chown`/`chmod` `/config`, `/run/ddclient` and `/run/ddclient-cache` to `abc:abc`.
- `DAC_OVERRIDE` - lets root still traverse/read the now-`abc`-owned, mode `0700` `/config` directory to finish the
  `chmod 600 /config/*` step.
- `SETUID`, `SETGID` - let `s6-applyuidgid` actually drop root's UID/GID to `abc` (911/1001) to launch the real
  `ddclient` process and its cron/inotify helpers; without these, s6 fails with
  `s6-applyuidgid: fatal: unable to set supplementary group list: Operation not permitted` and the daemon never starts.

An `initContainers: [copy-config]` step copies the read-only ConfigMap-mounted `ddclient.conf` into the writable
`config` `emptyDir` first, since the ConfigMap mount itself can't be `chown`/`chmod`'d in place.

The liveness/readiness probes run `pgrep -f '^ddclient - '`, anchored on the process title ddclient sets when running
in `--foreground` mode (`ddclient - sleeping for N seconds`). A plain `pgrep -f ddclient` also matches the
`s6-supervise svc-ddclient` wrapper and the `inotifywait -e modify /config/ddclient.conf` watcher, both of which exist
regardless of whether the real daemon started - the anchored pattern targets only the actual daemon process.

## Cloudflare prerequisite

ddclient's Cloudflare protocol can only **update** an existing DNS record - it cannot create one. Before deploying,
make sure an `A` record for `jellyfin.timo.be` already exists in the Cloudflare dashboard for the `timo.be` zone (any
placeholder IP is fine); ddclient will correct it to the real public IP on its next update cycle. If the record is
missing, ddclient logs `FAILED: [cloudflare][jellyfin.timo.be]> cannot set IPv4 to <ip>: no 'A' record at Cloudflare`
and retries on its next cycle.
