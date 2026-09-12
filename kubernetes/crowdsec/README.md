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

`crowdsec-bouncer.env` and `crowdsec-agent.env` are static, self-generated
values (not `cscli`-issued) — copy each `.env.template` to `.env` (gitignored)
and fill in:

```bash
openssl rand -hex 32   # crowdsec-bouncer.env: bouncer-api-key
openssl rand -hex 16   # crowdsec-agent.env: agent-password (agent-username: any stable string)
```

`crowdsec-console.env` is optional and enables console enrollment (a
prerequisite for enrolling into the CAPI community blocklist on
[app.crowdsec.net](https://app.crowdsec.net/)). CAPI itself — the anonymous
signal-push/community-blocklist registration — is already active without any
of this, see the comment above `lapi.persistentVolume` in
`crowdsec-values.yaml`. To enroll:

1. Copy `crowdsec-console.env.template` to `crowdsec-console.env` and paste in
   the enroll key from `app.crowdsec.net` → Security Engines → "Enroll
   command" → "Kubernetes" tab.
2. Re-apply this directory (see [Order of deployment](../README.md#order-of-deployment)).
3. On `app.crowdsec.net`, approve the newly-enrolled engine, then enable the
   community blocklist under its blocklist settings.
4. Leave `enroll-key` blank in `crowdsec-console.env` to skip enrollment;
   `ENROLL_KEY` is read as an optional secret key.

## Collections considered but not installed

Both need log sources this agent doesn't currently ingest:

- `Dominic-Wagner/vaultwarden` — would need a second `acquisition` entry for Vaultwarden's logs.
- `crowdsecurity/appsec-virtual-patching` — CrowdSec's WAF-style AppSec Component; needs its
  own `AppsecConfig` and a synchronous bouncer call, a bigger step than adding a collection.
