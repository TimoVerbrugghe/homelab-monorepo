# Auto-mounting the Emulation NFS shares on SteamOS

Mounts three shares from `nfs.local.timo.be:/mnt/X.A.N.A./media/games/` to the matching
`/home/deck/Emulation/` folders, so RetroDeck/EmuDeck (or any other emulation frontend)
sees them without a manual mount step:

| NFS path                                    | Mount point                    |
| -------------------------------------------- | ------------------------------- |
| `/mnt/X.A.N.A./media/games/roms`  | `/home/deck/Emulation/roms`  |
| `/mnt/X.A.N.A./media/games/bios`  | `/home/deck/Emulation/bios`  |
| `/mnt/X.A.N.A./media/games/saves` | `/home/deck/Emulation/saves` |

## Design

- Static `.mount`/`.automount` units in `/etc/systemd/system/`, not `/etc/fstab` and not
  a user-scoped systemd unit.
  - NFS mounting requires `CAP_SYS_ADMIN`, so it must be a **system** unit — a
    `systemd --user` unit (unprivileged `deck` user) can't do it.
  - Unlike `/etc/fstab`, these unit files have no counterpart in the base SteamOS
    image, so there's nothing for an update to merge/conflict with.
- `nofail` + `_netdev` + automount idle timeout mean this never blocks boot/login if the
  NAS is unreachable; each mount happens lazily on first access.
- Being system units, they work identically in Desktop Mode and Game Mode (gamescope).
- Since SteamOS 3.6, `/etc` changes are discarded on update unless whitelisted (see
  [Igalia's writeup](https://blogs.igalia.com/berto/2025/02/05/keeping-your-system-wide-configuration-files-intact-after-updating-steamos/)).
  `steammachine-emulation.conf` is that whitelist, covering all three unit pairs and
  their `systemctl enable` symlinks.
- No `steamos-readonly disable/enable` needed: `/etc` is a writable overlay independent
  of the (read-only) OS partition that toggle controls.

## Files

- `home-deck-Emulation-{roms,bios,saves}.mount` / `.automount` — one mount + automount
  unit pair per share. Filenames encode the mount point path (`systemd-escape --path
  /home/deck/Emulation/<name>`); rename + update `Where=` if a path ever changes.
- `steammachine-emulation.conf` — `atomic-update.conf.d` keep-list entry so updates
  don't discard the units above.

These are installed (not copied) directly by the `configure-steammachine` Ansible role
at [ansible/roles/configure-steammachine](../../ansible/roles/configure-steammachine) —
this folder is the single source of truth.

## Installing

Add the Deck to the `steammachine` group in
[ansible/inventory/hosts.yaml](../../ansible/inventory/hosts.yaml) (`ansible_user: deck`,
passwordless `sudo`), then:

```bash
ansible-playbook ansible/playbooks/configure-steammachine.yaml -i ansible/inventory/hosts.yaml
```

Verify:

```bash
ssh deck@<steammachine-host> 'ls /home/deck/Emulation/{roms,bios,saves}; systemctl status "home-deck-Emulation-*.automount"; mount | grep Emulation'
```

## Troubleshooting

- `unknown filesystem type 'nfs'`: test manually, e.g. `sudo mount -t nfs4
  nfs.local.timo.be:/mnt/X.A.N.A./media/games/roms /home/deck/Emulation/roms`.
- If a mount point already has existing local files, back them up first — the mount
  shadows, not merges, the directory.
- Undo (per share, e.g. `roms`): `sudo systemctl disable --now
  home-deck-Emulation-roms.automount home-deck-Emulation-roms.mount`, then `sudo rm
  /etc/systemd/system/home-deck-Emulation-roms.{mount,automount}`. Remove
  `/etc/atomic-update.conf.d/steammachine-emulation.conf` and `sudo systemctl
  daemon-reload` once all shares are removed.
- After a factory reset (or any full `/etc` wipe), just re-run the playbook — it's
  idempotent.
- Check the whitelist is active: `cat
  /etc/atomic-update.conf.d/steammachine-emulation.conf` — only uncommented lines are
  honored.
