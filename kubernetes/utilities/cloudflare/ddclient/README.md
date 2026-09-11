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
environment variable at runtime. The Deployment injects that variable from the `ddclient-secrets` Secret (generated from the
gitignored `ddclient-secrets.env`, based on `ddclient-secrets.env.template`), following this repo's usual Cloudflare secret
convention.

The token needs `Zone:DNS:Edit` permission scoped to the `timo.be` zone.
