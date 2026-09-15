# CrowdSec

Official `crowdsecurity/crowdsec` Helm chart: LAPI (ban decision store, no persistence)
+ agent DaemonSet (tails Traefik's JSON access logs via hostPath, needs `privileged`
Pod Security). Traefik enforces bans via the
[bouncer plugin](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin)
(`kubernetes/traefik/middlewares/crowdsec-bouncer.yaml`). See inline comments in
`crowdsec-values.yaml` and `kustomization.yaml` for the bouncer key / agent credential
mechanics and pod security/label rationale.

> [!IMPORTANT]
> Deploy `kubernetes/crowdsec/` and create the bouncer secret **before** the
> `crowdsec-bouncer` middleware is referenced on Traefik's `websecure`/`jellyfin`
> entrypoints — see [Order of deployment](../README.md#order-of-deployment).

## Setup

The `crowdsec-secrets.env` file (gitignored, copied from
`crowdsec-secrets.env.template`) must exist — `kustomize build` fails if any
`secretGenerator` env file is missing, even if you leave its values blank to
opt out of a feature. Copy the template to `crowdsec-secrets.env`, then fill
in the required keys:

```bash
openssl rand -hex 32   # crowdsec-secrets.env: bouncer-api-key
openssl rand -hex 16   # crowdsec-secrets.env: agent-password (agent-username: any stable string)
```

`crowdsec-secrets.env`'s `enroll-key` is optional and, when set, enables
console enrollment (a prerequisite for enrolling into the CAPI community
blocklist on [app.crowdsec.net](https://app.crowdsec.net/)). CAPI itself — the
anonymous signal-push/community-blocklist registration — is already active
without any of this, see the comment below `lapi.persistentVolume` in
`crowdsec-values.yaml`. Leave `enroll-key` blank (its default after copying
from the template) to skip console enrollment. To enroll:

1. In `crowdsec-secrets.env`, set `enroll-key` to the enroll key from
   `app.crowdsec.net` → Security Engines → "Enroll command" → "Kubernetes" tab.
2. Re-apply this directory (see [Order of deployment](../README.md#order-of-deployment)).
3. On `app.crowdsec.net`, approve the newly-enrolled engine, then enable the
   community blocklist under its blocklist settings.

> [!NOTE]
> Leave `enroll-key` blank in `crowdsec-secrets.env` (its default after
> copying from the template) to skip console enrollment; `ENROLL_KEY` is read
> as an optional secret key and the entrypoint only enrolls when it's
> non-empty. The key itself must still exist in the file for `kustomize build`
> to succeed.
> [!NOTE]
> All keys live in a single `crowdsec-secrets` Secret, which is reflected in
> full into the `traefik` namespace (see `kustomization.yaml`) so the bouncer
> plugin can read `bouncer-api-key`. The agent/console keys are reflected
> alongside it but unused by Traefik.

## Collections considered but not installed

Both need log sources this agent doesn't currently ingest:

- `Dominic-Wagner/vaultwarden` — would need a second `acquisition` entry for Vaultwarden's logs.
- `crowdsecurity/appsec-virtual-patching` — CrowdSec's WAF-style AppSec Component; needs its
  own `AppsecConfig` and a synchronous bouncer call, a bigger step than adding a collection.
