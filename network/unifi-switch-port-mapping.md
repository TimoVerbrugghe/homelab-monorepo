# UniFi Switch Port Mapping

Patch panel to switch mapping for the rack after the move to the **UniFi Switch Enterprise 24 PoE** (USW-Enterprise-24-PoE).

## Switch overview

- **Ports 1–12:** 1 GbE RJ45, PoE+
- **Ports 13–24:** 2.5 GbE RJ45, PoE+
- **SFP+ 1–2:** 10G SFP+
- **PoE budget:** 400W total, max 32W per port (PoE+ only, no PoE++)

## Port mapping

Patch panel position N connects to switch port N (positions 6–22).

| Panel position | Old use | Current use | Switch port | Speed | Cable |
|---|---|---|---|---|---|
| 1 | HDMI – Factory | HDMI – Factory | – | – | – |
| 2 | USB – Factory | USB – Factory | – | – | – |
| 3 | HDMI – Forest | HDMI – Forest | – | – | – |
| 4 | HDMI – Ice | HDMI – Ice | – | – | – |
| 5 | HDMI – Mountain | HDMI – Mountain | – | – | – |
| 6 | Spare | Living AP | 6 | 1 GbE PoE+ | Blue |
| 7 | Spare | 1st Floor AP | 7 | 1 GbE PoE+ | Blue |
| 8 | Living | 2nd Floor AP | 8 | 1 GbE PoE+ | Blue |
| 9 | Bedroom 1 | Zigbee | 9 | 1 GbE PoE+ | Blue |
| 10 | Bedroom 4 | Garden AP | 10 | 1 GbE PoE+ | Blue |
| 11 | Ice | Garden Cam | 11 | 1 GbE PoE+ | Blue |
| 12 | Mountain | Doorbell | 12 | 1 GbE PoE+ | Blue |
| 13 | Forest | Spare | 13 | 2.5 GbE PoE+ | – |
| 14 | PDU | Spare | 14 | 2.5 GbE PoE+ | – |
| 15 | Zigbee | PDU | 15 | 2.5 GbE | White |
| 16 | Living AP | Living | 16 | 2.5 GbE | White |
| 17 | Doorbell | Forest | 17 | 2.5 GbE | White |
| 18 | 2nd Floor AP | Mountain | 18 | 2.5 GbE | White |
| 19 | 1st Floor AP | Ice | 19 | 2.5 GbE | White |
| 20 | Garden AP | Bedroom 4 | 20 | 2.5 GbE | White |
| 21 | Garden Cam | Bedroom 1 | 21 | 2.5 GbE | White |
| 22 | Bedroom 3 | Bedroom 3 | 22 | 2.5 GbE | White |
| 23 | Factory | Factory | SFP+ 1 (SFP+ to RJ45 module) | 10 GbE | White |
| 24 | WAN | WAN | Dream Machine SE – WAN | – | White |

## Panel layout (left to right)

1. **1–5:** HDMI / USB passthroughs
2. **6–12:** PoE devices (APs, camera, doorbell, Zigbee)
3. **13–14:** Spares (2.5 GbE PoE+, usable for either a PoE or a 2.5 GbE device)
4. **15–16:** PDU, Living
5. **17–19:** Servers (Forest, Mountain, Ice)
6. **20–22:** Bedrooms
7. **23–24:** Factory (10 GbE) and WAN

## Uplink

- Switch **SFP+ 2** to Dream Machine SE **SFP+ LAN** with a 10G DAC cable.

## Notes

- Living (16) was placed by elimination during the rewire. Verify in the UniFi controller that port 16 is the living room, and that Living AP is on port 6 and 1st Floor AP on port 7.
- Ports 1–5 have no keystone above them but are usable with a longer patch cable.
