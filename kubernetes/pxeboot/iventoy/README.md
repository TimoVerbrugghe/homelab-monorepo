# iVentoy PXE Boot Setup

After deploying iVentoy, complete the following configuration steps:

## 1. Configure iVentoy

- Open the iVentoy web interface.
- Go to **Configuration**.
- Set **DHCP server mode** to `ExternalNet`.
- Start iVentoy manually by clicking the green play arrow on the **Boot Information** screen.

## 2. Configure External Router (e.g., Unifi)

- Enable **Network Booting** (PXE) on your router.
- Set the **boot server IP address** to the IP defined in `iventoy-service` for kube-vip.
- Set the **boot filename** to:  

    ```text
    iventoy_loader_16000_uefi
    ```

- For more details, see the [iVentoy external DHCP documentation](https://www.iventoy.com/en/doc_ext_dhcp.html).
