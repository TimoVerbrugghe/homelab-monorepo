# TrueNAS iSCSI lifecycle hooks

TrueNAS dispatches [iSCSI Kubernetes Scale](../.github/workflows/iscsi-kubernetes.yaml)
on `main` during startup and shutdown. Configure these in **System > Advanced >
Init/Shutdown Scripts** as enabled **COMMAND** tasks:

| Action | When | curl retry options | Task timeout |
| --- | --- | --- | --- |
| Scale Up | POSTINIT | `--retry 60 --retry-all-errors --retry-delay 10 --retry-max-time 900` | 960 seconds |
| Scale Down | SHUTDOWN | `--retry 3 --retry-all-errors --retry-delay 5 --retry-max-time 180` | 240 seconds |

Both commands also need `--connect-timeout 10 --max-time 20 --fail-with-body -sS`.
Keep the existing GitHub authorization header, dispatch URL, and JSON payload.
Do not commit the token. Keep commands on one line; saved script paths are ignored
for COMMAND tasks.

The startup retry window accommodates DNS and network recovery after a wider
homelab restart without extending the shutdown window. `--retry-max-time` is a
ceiling, not a minimum duration: `--retry 3` allows only four attempts regardless
of how much time remains. The task timeout must exceed the retry window plus a
final request, which can begin just before the retry window expires.

In **Network > Global Configuration**, use these DNS servers in order:

1. `10.10.10.21` (standalone AdGuard Home).
2. `10.10.10.22` (standalone AdGuard Home).
3. `10.10.10.35` (Kubernetes AdGuard Home).

Do not use the obsolete `10.10.10.20` address. POSTINIT means local boot services
have started, not that remote DNS servers or Internet access are available.

## Diagnosing a missed startup dispatch

Check the TrueNAS shell:

```bash
grep 'InitShutdownScriptService.execute_task' /var/log/middlewared.log | tail -n 5
getent ahostsv4 api.github.com
```

Hook failure messages can include the authorization header. Redact credentials
before sharing logs. A successful `initshutdownscript.execute_init_tasks` job
only means the hook runner completed; inspect the middleware log for individual
command failures.

On 2026-11-08, POSTINIT began at 14:45:59 CET. The startup curl command failed
at 14:46:54 after three DNS-resolution timeouts and one connection timeout.
No GitHub Scale Up run existed. TrueNAS still listed the obsolete DNS server
first, and the Kubernetes DNS listener did not start until about 14:53 CET.
The four attempts were exhausted long before the configured 180-second ceiling.

Successful dispatch means GitHub accepted the request, not that scaling finished.
Verify the workflow result and workload readiness. Lost HTTP responses can cause
duplicate dispatches: preserve the workflow's saved replica counts and
same-action idempotency. Do not dispatch opposite actions until the previous
action completes.
