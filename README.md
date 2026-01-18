# homelab-monorepo

<!-- AUTO-GENERATED BADGES - DO NOT EDIT MANUALLY -->
[![View Architecture Diagram](https://img.shields.io/badge/View%20Diagram-draw.io-blue?logo=diagramsdotnet&logoColor=white)](https://app.diagrams.net/?url=https://raw.githubusercontent.com/TimoVerbrugghe/homelab-monorepo/master/diagrams/homelab.drawio)
![Kubernetes Manifests](https://img.shields.io/badge/kubernetes%20manifests-203-326CE5?logo=kubernetes&logoColor=white)
![Docker Compose](https://img.shields.io/badge/docker%20compose-18-2496ED?logo=docker&logoColor=white)
![Ansible Playbooks](https://img.shields.io/badge/ansible%20playbooks-13-EE0000?logo=ansible&logoColor=white)
![NixOS Machines](https://img.shields.io/badge/nixos%20machines-7-5277C3?logo=nixos&logoColor=white)
![Shell Scripts](https://img.shields.io/badge/shell%20scripts-17-4EAA25?logo=gnubash&logoColor=white)
![GitHub Workflows](https://img.shields.io/badge/github%20workflows-14-2088FF?logo=githubactions&logoColor=white)
![HA Addons](https://img.shields.io/badge/ha%20addons-1-41BDF5?logo=homeassistant&logoColor=white)
![Repo Size](https://img.shields.io/github/repo-size/TimoVerbrugghe/homelab-monorepo)
<!-- END AUTO-GENERATED BADGES -->

This repository contains all my setup files while I'm learning Ansible, Kubernetes, NixOS & others.

Heavily influenced by TechnoTim (<https://github.com/techno-tim>), Christian Lempa (<https://github.com/ChristianLempa/christianlempa>) & the Linux Unplugged team (<https://linuxunplugged.com/>).

## Home Assistant Add-On

This repository also serves as my personal home assistant add-on repo. Currently, I have the following addons:

- [Tesla Fleet Public Key Hosting addon](./teslafleet-publickeyhost)

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/TimoVerbrugghe/homelab-monorepo)

## GitHub Workflows Status

![Bitwarden Export Docker](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/bitwarden-export-docker.yaml?branch=master&label=bitwarden-export-docker&logo=githubactions&logoColor=white)
![Build NixOS ISOs](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/build-nixos-isos.yaml?branch=master&label=build-nixos-isos&logo=githubactions&logoColor=white)
![Check Broken Links](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/check-broken-links.yaml?branch=master&label=check-broken-links&logo=githubactions&logoColor=white)
![Deploy K8s Resource](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/deploy-k8s-resource.yaml?branch=master&label=deploy-k8s-resource&logo=githubactions&logoColor=white)
![DrawIO Export](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/drawio-export.yaml?branch=master&label=drawio-export&logo=githubactions&logoColor=white)
![iSCSI Kubernetes](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/iscsi-kubernetes.yaml?branch=master&label=iscsi-kubernetes&logo=githubactions&logoColor=white)
![K8s Backup Docker](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/k8s-backup-docker.yaml?branch=master&label=k8s-backup-docker&logo=githubactions&logoColor=white)
![K8s Restore Docker](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/k8s-restore-docker.yaml?branch=master&label=k8s-restore-docker&logo=githubactions&logoColor=white)
![Lint Markdown](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/lint-markdown.yaml?branch=master&label=lint-markdown&logo=githubactions&logoColor=white)
![Lint YAML/JSON](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/lint-yaml-json.yaml?branch=master&label=lint-yaml-json&logo=githubactions&logoColor=white)
![NS-USBLoader Docker](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/ns-usbloader-docker.yaml?branch=master&label=ns-usbloader-docker&logo=githubactions&logoColor=white)
![Update Badges](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/update-badges.yaml?branch=master&label=update-badges&logo=githubactions&logoColor=white)
![Update Talos Machines](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/update-talos-machines.yaml?branch=master&label=update-talos-machines&logo=githubactions&logoColor=white)
![Validate Shell Scripts](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/validate-shell-scripts.yaml?branch=master&label=validate-shell-scripts&logo=githubactions&logoColor=white)

## My Homelab

I have the following machines & VMs with a brief overview of services they run. All VMs in Proxmox run NixOS.

- TheFactory
  - TrueNAS Scale
  - Docker services (see docker/truenas/ folder)

- Proxmox cluster (Lyoko)
  - Forest Sector
    - Yumi (kubernetes node with local storage, HA, can be live migrated)
      - Bitwarden
      - Mealie
      - Portainer
    - William (kubernetes node)
  - Ice Sector
    - Odd (Adguardhome on NixOS)
    - Manta (kubernetes node)
  - Forest Sector
    - Ulrich (Adguardhome on NixOS)
    - Hass (Home Assistant OS)
    - Skidbladnir (kubernetes node)

## Kubernetes cluster

Built using Talos linux. Currently runs several services such as Traefik, Plex, Homepage, Gatus, Adguardhome, ... (check the kubernetes subfolder for all deployments).

Several services are not running in this cluster and remain on separate NixOS VMs or TrueNAS with docker because:

- I don't want to run hyperconverged storage solutions (Longhorn, OpenEBS, etc...) due to the amount of resources it takes & the complexity of the setup.
- I encountered several issues with NFS-backed storage (even with NFSv4) and sqlite databases
  (f.e. with plex & bitwarden) so not an option to use NFS-backed storage in the cluster. For
  Plex & Jellyfin in the kubernetes cluster, I'm using iSCSI backed storage.
- Services that I want HA and do need local storage (portainer, bitwarden, etc...) are running in the Yumi kubernetes node that is HA-enabled in proxmox & can be live migrated.

## Future Plans

- Nothing right now. Feel free to suggest other things I might want to do in this setup!
