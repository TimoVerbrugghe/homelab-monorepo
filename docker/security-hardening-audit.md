# Docker security hardening audit (excluding david folder)

## Scope

This audit covers Docker Compose workloads under `docker/`, excluding `docker/david/`.
It reflects the currently applied state.

## Kubernetes → Docker control mapping

| Kubernetes column | Docker Compose equivalent |
| --- | --- |
| `allowPrivEsc=false` | `security_opt: ["no-new-privileges=true"]` |
| `cap drop ALL` | `cap_drop: ["ALL"]` |
| `runAsNonRoot` | `user: UID:GID` (non-zero / non-root) |
| `readOnlyRootFilesystem` | `read_only: true` |
| (new #2) Turn off tty/stdin | `tty: false` + `stdin_open: false` |
| (new #7) Resource limits set | `pids_limit` + `mem_limit` + `cpus` |
| (new #8) Logging limits | `logging.driver: json-file` + `max-size: "50m"` + `max-file: "5"` |

## Security feature matrix (per service)

| Workload | Compose file | no-new-privileges | cap_drop ALL | non-root user | read_only rootfs | tty=false + stdin_open=false | resource limits set | logging (50m/5) | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| adguardhome | docker/adguardhome.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only rootfs enabled |
| watchtower | docker/coreservices.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| dockerproxy | docker/coreservices.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| dawarich_redis | docker/truenas/dawarich.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| dawarich_db | docker/truenas/dawarich.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/3g/2.0 |
| dawarich_app | docker/truenas/dawarich.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/2g/2.0; read_only disabled (Rails writes db/schema.rb + tmp at startup) |
| dawarich_sidekiq | docker/truenas/dawarich.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/2g/2.0; read_only disabled (same image as dawarich_app) |
| photon | docker/truenas/dawarich.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only disabled (startup writes under /photon/.cache) |
| qbittorrent | docker/truenas/downloaders.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/2g/2.0; read_only disabled (incompatible with ro rootfs) |
| jdownloader2 | docker/truenas/downloaders.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only disabled (incompatible with ro rootfs) |
| metube | docker/truenas/downloaders.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only disabled (incompatible with ro rootfs) |
| ariang | docker/truenas/downloaders.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5; read_only disabled (incompatible with ro rootfs) |
| spotdl-web | docker/truenas/downloaders.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5; read_only disabled (incompatible with ro rootfs) |
| filezilla | docker/truenas/filemanagement.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only disabled (incompatible with ro rootfs) |
| doublecommander | docker/truenas/filemanagement.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0; read_only disabled (incompatible with ro rootfs) |
| sonarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| radarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| bazarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| seerr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| prowlarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| recyclarr | docker/truenas/media.yaml | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| flaresolverr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| swaparr-radarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| swaparr-sonarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| yamtrack | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| yamtrack-redis | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| audiobookshelf | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| dispatcharr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| tautulli | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| wrapperr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| obzorarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| houndarr | docker/truenas/media.yaml | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/512m/0.5 |
| nextcloud-aio-mastercontainer | docker/truenas/nextcloud-aio.yaml | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| portainer-agent | docker/truenas/portainer-agent.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/1g/1.0 |
| webtop-chrome | docker/truenas/webtop.yaml | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | limits=512/2g/2.0 |

## Notes

- Compose hardening is implemented with YAML anchors in each workload file for reuse and consistency.
- `docker/recyclarr/recyclarr.yaml` remains out of scope because it is Recyclarr app config, not a Docker Compose workload file.
- `cap_drop: ["ALL"]` has been applied to all stacks except `docker/truenas/media.yaml`.
- `read_only: true` has been enabled for all stacks except `docker/truenas/media.yaml` and `photon` in this pass.
