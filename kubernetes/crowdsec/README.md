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

Both secrets are static, self-generated values (not `cscli`-issued) — copy each
`.env.template` to `.env` (gitignored) and fill in:

```bash
openssl rand -hex 32   # crowdsec-bouncer.env: bouncer-api-key
openssl rand -hex 16   # crowdsec-agent.env: agent-password (agent-username: any stable string)
```

## Collections considered but not installed

Both need log sources this agent doesn't currently ingest:

- `Dominic-Wagner/vaultwarden` — would need a second `acquisition` entry for Vaultwarden's logs.
- `crowdsecurity/appsec-virtual-patching` — CrowdSec's WAF-style AppSec Component; needs its
  own `AppsecConfig` and a synchronous bouncer call, a bigger step than adding a collection.
