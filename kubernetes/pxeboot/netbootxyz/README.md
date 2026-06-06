# netbootxyz Deployment

After deploying **netbootxyz**, you must configure your DHCP server (e.g., UniFi) to enable network booting:

1. **Set the DHCP Boot Server IP:**  
    Use the IP address defined in your `netbootxyz-service.yaml` (under the `kubevip` service).

2. **Set the Boot File:**  
    Specify `netboot.xyz.efi` as the boot file.

## Windows PXE Boot

Windows installation over PXE uses a WinPE ISO served by the netbootxyz HTTP asset server and the extracted Windows 11 files served via SMB from TheFactory.

### NFS share on TheFactory

The `build-winpe-image` GitHub Actions workflow uploads the following files to TheFactory at `/mnt/FranzHopper/windowsinstall/`:

| File / folder | Purpose |
| ------------- | ------- |
| `WinPE.iso` | WinPE boot image with virtio drivers — served by netbootxyz |
| `Windows11/` | Extracted Windows 11 ISO — served via SMB from TheFactory |
| `virtio/` | Extracted virtio-win drivers — served via SMB from TheFactory |

The folder is exported over NFS and mounted read-only into the container at `/assets/WinPE/x64/`,
making `WinPE.iso` reachable at `http://10.10.10.37/WinPE/x64/WinPE.iso`.

### Automatic win_base_url configuration

The `local-vars-ipxe-configmap.yaml` injects a `local-vars.ipxe` file into the TFTP root that sets:

```
set win_base_url http://10.10.10.37/WinPE
```

This means you do **not** need to type the URL manually when selecting the Windows installer from the netbootxyz boot menu.

### Windows installation steps

1. PXE boot the target machine — the netbootxyz menu appears.
2. Navigate to **Windows** → the WinPE environment loads.
3. `startnet.cmd` (see [`windows/startnet.cmd`](../../../windows/startnet.cmd) in this repo)
   runs automatically on boot. It calls `wpeinit` to initialise networking, mounts the
   Windows 11 SMB share from TheFactory, scans for `.xml` unattend files on the share, and
   presents a simple numbered menu to choose between:
   - **Attended install** (option `0`) — launches `setup.exe` with no unattend file.
   - **Unattended install** (any other option) — launches `setup.exe /unattend:<file>` with
     the chosen XML file from the share (e.g. `unattend-vm.xml` or `unattend-general.xml`).
4. Select your option and the Windows installer starts.
