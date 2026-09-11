# CrowdSec

`kubernetes/crowdsec/` deploys the official `crowdsecurity/crowdsec` Helm chart, which
runs two components:

- **LAPI** (Local API) — a single-replica Deployment that stores ban decisions in an
  ephemeral, pod-local SQLite database (persistence is disabled; no dynamic
  StorageClass is provisioned for this workload, so the database is lost on every pod
  restart) and serves them over its `crowdsec-service` ClusterIP
  Service. It is never exposed outside the cluster.
- **Agent** — a DaemonSet that tails Traefik's JSON access logs directly from
  `/var/log/containers` (hostPath) via the `acquisition` config in
  `crowdsec-values.yaml`, matching them against the `crowdsecurity/traefik`,
  `crowdsecurity/http-cve`, `crowdsecurity/base-http-scenarios` and
  `crowdsecurity/http-dos` collections, and pushing ban decisions to the LAPI. Because
  it needs the host's `/var/log`, the `crowdsec` namespace uses the `privileged` Pod
  Security Standard.

Enforcement happens in Traefik itself, via the
[Traefik CrowdSec bouncer plugin](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin),
loaded through `experimental.plugins` in `kubernetes/traefik/traefik-values.yaml` and
applied to all ingress traffic through the `crowdsec-bouncer` Middleware
(`kubernetes/traefik/middlewares/crowdsec-bouncer.yaml`) referenced on the `websecure`
entrypoint. The plugin queries the LAPI's decisions stream and blocks/challenges
requests at the edge before they reach any backend service.

## Bouncer API key

The Traefik bouncer key is a static, pre-shared value **you** generate — it is no longer
obtained from `cscli bouncers add`:

```bash
openssl rand -hex 32
```

Store it in a local, uncommitted `kubernetes/crowdsec/crowdsec-bouncer.env` (see
`crowdsec-bouncer.env.template`). The `secretGenerator` in
`kubernetes/crowdsec/kustomization.yaml` turns it into the `crowdsec-bouncer-secrets`
Secret, which is used two ways:

- [Reflector](https://github.com/emberstack/kubernetes-reflector) copies it into the
  `traefik` namespace, where it is mounted into the Traefik pod as a file (`volumes:` in
  `traefik-values.yaml`) that the plugin reads via `crowdsecLapiKeyFile`.
- `lapi.env` in `crowdsec-values.yaml` exposes the same value to the LAPI container as
  `BOUNCER_KEY_traefik_bouncer`. CrowdSec's entrypoint script scans for `BOUNCER_KEY_*`
  env vars on every container start and idempotently runs
  `cscli bouncers add traefik_bouncer -k <key>` (skipped if already registered), so the
  bouncer is re-registered with this exact key every time the LAPI pod restarts or is
  recreated — no persistent storage and no manual `cscli bouncers add` needed. The
  bouncer name uses an underscore (`traefik_bouncer`, not `traefik-bouncer`) because the
  entrypoint derives it from the env var name via `compgen -A variable`, which does not
  expose hyphenated names as shell variables.

> [!IMPORTANT]
> Deploy `kubernetes/crowdsec/` and create the bouncer secret **before** the
> `crowdsec-bouncer` middleware is referenced on Traefik's `websecure` entrypoint — see
> [Order of deployment](../README.md#order-of-deployment) in the main Kubernetes README.

## Pod labels

`lapi.podLabels`/`agent.podLabels` in `crowdsec-values.yaml` only set
`app.kubernetes.io/name`/`app.kubernetes.io/instance`. The chart does not set any
`app.kubernetes.io/*` labels by default (only `k8s-app`/`type`/`version`), so these two
are added to match repo convention. `app.kubernetes.io/part-of: homelab` is deliberately
**not** set here: the `labels:` transformer in `kustomization.yaml` already injects it
into every resource (including pod templates) generated from this directory, so
repeating it in the chart values would be redundant.

## Other collections considered

These [hub.crowdsec.net](https://hub.crowdsec.net) collections were considered but not
installed, because they need log sources this agent doesn't currently ingest (it only
tails Traefik's pod logs via `acquisition` in `crowdsec-values.yaml`):

- `Dominic-Wagner/vaultwarden` — brute-force/probing detection tailored to Vaultwarden
  (`kubernetes/utilities/bitwarden/` runs `vaultwarden/server`). Would require adding a
  second `acquisition` entry (and collection) reading the Vaultwarden pod's logs.
- `crowdsecurity/appsec-virtual-patching` (+ a matching `appsec-crs`/`appsec-generic-rules`
  ruleset) — CrowdSec's WAF-style AppSec Component, which inspects request bodies for
  injection/exploit patterns rather than just access-log lines. It needs its own
  `AppsecConfig` and a bouncer configured to call the AppSec endpoint synchronously,
  which is a bigger integration step than adding a collection.

If either of those become worth the extra setup (e.g. Vaultwarden gets targeted by
credential-stuffing, or the AppSec Component is adopted cluster-wide), revisit this list.
