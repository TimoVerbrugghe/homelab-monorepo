# Cloudflare Tunnel for Kubernetes Services

This folder contains resources to deploy a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) in my Kubernetes cluster.

## Purpose

The tunnel is intended **only for Kubernetes services that have their own authentication** and are **not routed through Traefik**. Example services include:

- Bitwarden
- Portainer
- Mealie
