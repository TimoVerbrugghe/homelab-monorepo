# Cloudflare Tunnel for Kubernetes Services

This folder contains resources to deploy a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) in my Kubernetes cluster.

## Purpose

The tunnel is intended for **both** Kubernetes services that have their own authentication **and** are routed through Traefik
(so it uses traefik-forward-auth's authentication).

The reason for running the tunnel inside the cluster is because a cloudflare tunnel outside of the cluster that needs to route
through traefik is giving several 502 bad gateway errors at random times for which I have not found the root cause or a solution.

Example services include:

- Bitwarden
- Portainer
- Mealie

- Any service under the traefik/ingress folder
