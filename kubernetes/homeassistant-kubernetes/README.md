# Home Assistant Kubernetes Integration (Kustomize)

This kustomization installs the Kubernetes resources needed to integrate your cluster with Home Assistant using the external integration:  
<https://github.com/tibuntu/homeassistant-kubernetes>

## Apply

```bash
kubectl apply -k .
```

## Retrieve Integration Token

After resources are created:

```bash
kubectl get secret homeassistant-kubernetes-integration-token -n homeassistant -o jsonpath='{.data.token}' | base64 -d
```

Use the decoded token when setting up the integration in Home Assistant.

## Notes

- Recreate the secret if rotating credentials.

## Reference

Project / Integration details: <https://github.com/tibuntu/homeassistant-kubernetes>
