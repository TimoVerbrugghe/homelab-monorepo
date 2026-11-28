# Kubernetes Secret management

Application credentials live in Vaultwarden, except for bootstrap credentials.
Kubernetes-generated and operator-owned Secrets stay with their controllers.

Every five minutes, the controller checks the `kubernetes-secrets` folder and
syncs one Secret per Login into `shared-credentials`. Reflector copies the whole
Secret to the namespaces allowed by the Login.

To add a Secret, create a **Login** in `kubernetes-secrets`:

| Login field | What to enter |
| --- | --- |
| Name | The exact Secret name, e.g. `sonarr-api-key` |
| Password | The credential value |
| Text field `secret-key-password` | The key for that value, e.g. `api-key` |
| Hidden fields | Other values, named after their exact Secret keys |
| Text field `namespaces` | `shared-credentials` |
| Text field `context-name` | `sectorfive` |
| Text fields `secret-annotation` | One field per annotation shown below |

```text
reflector.v1.k8s.emberstack.com/reflection-allowed=true
reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces=mediaplayback,utilities
reflector.v1.k8s.emberstack.com/reflection-auto-enabled=true
reflector.v1.k8s.emberstack.com/reflection-auto-namespaces=mediaplayback,utilities
```

Replace the example namespaces in both lists with the actual consumers.
Verify that each namespace has the reflected Secret before referencing it.
Reflector won't replace an existing same-name Secret. After rotation, restart
workloads that read the Secret through environment variables.
