#!/usr/bin/env python3
"""Simple Plex GDM discovery test using plexapi.gdm."""

from __future__ import annotations

from datetime import datetime, timezone
from pprint import pformat

from plexapi.gdm import GDM


def _format_entries(label: str, entries: list[dict]) -> str:
    lines = [f"{label}: {len(entries)} discovered"]
    if not entries:
        lines.append("  (none)")
        return "\n".join(lines)

    for index, entry in enumerate(entries, start=1):
        data = entry.get("data", {})
        source = entry.get("from", ("?", "?"))
        name = data.get("Name", "(no name)")
        content_type = data.get("Content-Type", "(unknown)")
        host = data.get("Host", source[0])
        port = data.get("Port", "?")

        lines.append(
            f"  {index}. {name} | {content_type} | host={host}:{port} | reply_from={source[0]}:{source[1]}"
        )
        lines.append("     raw_data=" + pformat(data, compact=True))

    return "\n".join(lines)


def main() -> int:
    print(f"Plex GDM discovery test @ {datetime.now(timezone.utc).isoformat()}")

    gdm = GDM()

    print("\nScanning for Plex media servers (multicast 239.0.0.250:32414)...")
    server_entries = gdm.all(scan_for_clients=False)
    print(_format_entries("Servers", server_entries))

    print("\nScanning for Plex clients (broadcast 255.255.255.255:32412)...")
    client_entries = gdm.all(scan_for_clients=True)
    print(_format_entries("Clients", client_entries))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
