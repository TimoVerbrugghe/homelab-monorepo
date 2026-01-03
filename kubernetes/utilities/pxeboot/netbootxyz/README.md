# netbootxyz Deployment

After deploying **netbootxyz**, you must configure your DHCP server (e.g., UniFi) to enable network booting:

1. **Set the DHCP Boot Server IP:**  
    Use the IP address defined in your `netbootxyz-service.yaml` (under the `kubevip` service).

2. **Set the Boot File:**  
    Specify `netboot.xyz.efi` as the boot file.
