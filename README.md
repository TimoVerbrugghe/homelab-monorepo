# homelab-monorepo

This repository contains all my setup files while I'm learning Ansible, Kubernetes, NixOS & others.

Heavily influenced by TechnoTim (<https://github.com/techno-tim>), Christian Lempa (<https://github.com/ChristianLempa/christianlempa>) & the Linux Unplugged team (<https://linuxunplugged.com/>).

## Home Assistant Add-On

This repository also serves as my personal home assistant add-on repo. Currently, I have the following addons:

- [Tesla Fleet Public Key Hosting addon](./teslafleet-publickeyhost)

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/TimoVerbrugghe/homelab-monorepo)

## My Homelab

I have the following machines & VMs with a brief overview of services they run. All VMs in Proxmox run NixOS.

- TheFactory
  - TrueNAS Scale
  - Docker services (see docker/truenas/ folder)

- Proxmox cluster (Lyoko)
  - Forest Sector
    - Yumi (kubernetes node with local storage, HA, can be live migrated)
      - Cloudflare Tunnel
      - Bitwarden
      - Mealie
      - Portainer
    - William (kubernetes node)
  - Ice Sector
    - Odd (Adguardhome + Cloudflare Tunnel)
    - Manta (kubernetes node)
    - Aelita
      - Plex & Jellyfin
  - Forest Sector
    - Ulrich (Adguardhome + Cloudflare Tunnel)
    - Hass (Home Assistant OS)
    - Skidbladnir (kubernetes node)

## Kubernetes cluster

Built using Talos linux. Currently runs following services:

- Traefik
- Cert-manager (with Reflector to make sure certs are available in other namespaces)
- Kube-VIP
- Tailscale operator
- Keel
- Homepage
- Gatus
- Stirling-PDF
- Webtop
- Adguardhome-sync
- Adguardhome
- PXEBoot (netbootxyz & iVentoy)
- Bitwarden
- Portainer
- Mealie

Several services are not running in this cluster and remain on separate NixOS VMs or TrueNAS with docker because:

- I don't want to run hyperconverged storage solutions (Longhorn, OpenEBS, etc...) due to the amount of resources it takes (so only running stateless services or services that I personally don't see the need to store something out of memory).

- I encountered several issues with NFS-backed storage (even with NFSv4) and sqlite databases (f.e. with plex & bitwarden) so not an option to use NFS-backed storage in the cluster.

- Services that I want HA and do need local storage (portainer, bitwarden, etc...) are running in the Yumi kubernetes node that is HA-enabled in proxmox & can be live migrated.

- Plex & Jellyfin run in a separate VM (Aelita) because I'm passing through my iGPU which makes the VM not eligible for live migration in Proxmox.

## Future Plans

- Run Cloudflare Tunnel directly in kubernetes: <https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/>
