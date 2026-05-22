#!/usr/bin/env python3
"""Detect and optionally correct Home Assistant energy statistic spikes.

This script uses Home Assistant's supported WebSocket recorder commands:
- recorder/list_statistic_ids
- recorder/statistics_during_period
- recorder/adjust_sum_statistics

Default behavior is dry-run (report only). Use --apply to perform adjustments.
"""

from __future__ import annotations

import argparse
import asyncio
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import json
import os
import sys
from typing import Any

try:
    import websockets
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Missing dependency 'websockets'. Install with: pip install websockets"
    ) from exc


@dataclass
class Spike:
    start_ms: int
    end_ms: int
    change: float
    state: float | None
    sum_value: float | None


class HAWebSocketClient:
    def __init__(self, base_url: str, token: str) -> None:
        self.base_url = base_url.rstrip("/")
        self.token = token
        self.ws = None
        self._next_id = 1

    @property
    def websocket_url(self) -> str:
        if self.base_url.startswith("https://"):
            return "wss://" + self.base_url[len("https://") :] + "/api/websocket"
        if self.base_url.startswith("http://"):
            return "ws://" + self.base_url[len("http://") :] + "/api/websocket"
        raise ValueError("--url must start with http:// or https://")

    async def connect(self) -> None:
        self.ws = await websockets.connect(self.websocket_url, max_size=16 * 1024 * 1024)

        first = json.loads(await self.ws.recv())
        if first.get("type") != "auth_required":
            raise RuntimeError(f"Unexpected first WS message: {first}")

        await self.ws.send(
            json.dumps({"type": "auth", "access_token": self.token})
        )
        auth_result = json.loads(await self.ws.recv())
        if auth_result.get("type") != "auth_ok":
            raise RuntimeError(f"Authentication failed: {auth_result}")

    async def close(self) -> None:
        if self.ws is not None:
            await self.ws.close()

    async def command(self, payload: dict[str, Any]) -> Any:
        if self.ws is None:
            raise RuntimeError("WebSocket not connected")

        msg_id = self._next_id
        self._next_id += 1

        payload = {"id": msg_id, **payload}
        await self.ws.send(json.dumps(payload))

        while True:
            raw = await self.ws.recv()
            message = json.loads(raw)
            if message.get("id") != msg_id:
                continue
            if message.get("type") != "result":
                continue
            if not message.get("success", False):
                raise RuntimeError(f"Home Assistant error: {message.get('error')}")
            return message.get("result")



def _ms_to_utc_iso(ms: int) -> str:
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc).isoformat()


def _ms_to_local_iso(ms: int) -> str:
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc).astimezone().isoformat()


def _extract_spikes(rows: list[dict[str, Any]], threshold: float) -> list[Spike]:
    spikes: list[Spike] = []
    for row in rows:
        change = row.get("change")
        if change is None:
            continue
        try:
            change_val = float(change)
        except (TypeError, ValueError):
            continue
        # Detect both positive and negative spikes (absolute value >= threshold)
        if abs(change_val) >= threshold:
            spikes.append(
                Spike(
                    start_ms=int(row["start"]),
                    end_ms=int(row["end"]),
                    change=change_val,
                    state=float(row["state"]) if row.get("state") is not None else None,
                    sum_value=float(row["sum"]) if row.get("sum") is not None else None,
                )
            )
    return spikes


async def get_energy_entities(client: HAWebSocketClient) -> list[str]:
    """Return all energy sensor IDs configured in the HA energy dashboard."""
    result = await client.command({"type": "energy/get_prefs"})
    entities: set[str] = set()

    for source in result.get("energy_sources", []):
        stype = source.get("type")
        if stype == "grid":
            for flow in source.get("flow_from", []):
                if eid := flow.get("stat_energy_from"):
                    entities.add(eid)
            for flow in source.get("flow_to", []):
                if eid := flow.get("stat_energy_to"):
                    entities.add(eid)
        elif stype in ("solar", "gas"):
            if eid := source.get("stat_energy_from"):
                entities.add(eid)
        elif stype == "battery":
            for key in ("stat_energy_from", "stat_energy_to"):
                if eid := source.get(key):
                    entities.add(eid)

    for device in result.get("device_consumption", []):
        if eid := device.get("stat_consumption"):
            entities.add(eid)

    return sorted(entities)


async def run(args: argparse.Namespace) -> int:
    token = args.token or os.getenv("HA_TOKEN")
    if not token:
        print("Error: provide --token or set HA_TOKEN", file=sys.stderr)
        return 2

    base_url = args.url or os.getenv("HA_URL")
    if not base_url:
        print("Error: provide --url or set HA_URL", file=sys.stderr)
        return 2

    # --- Determine scan time range ---
    now_utc = datetime.now(tz=timezone.utc)
    if args.from_date:
        try:
            # Handle Z suffix (Zulu/UTC time)
            from_date_str = args.from_date.replace("Z", "+00:00") if args.from_date.endswith("Z") else args.from_date
            start_time = datetime.fromisoformat(from_date_str)
            if start_time.tzinfo is None:
                start_time = start_time.replace(tzinfo=timezone.utc)
            else:
                start_time = start_time.astimezone(timezone.utc)
        except ValueError as e:
            print(f"Error parsing --from-date '{args.from_date}': {e}", file=sys.stderr)
            return 2
    else:
        start_time = now_utc - timedelta(days=args.lookback_days)

    if args.to_date:
        try:
            # Handle Z suffix (Zulu/UTC time)
            to_date_str = args.to_date.replace("Z", "+00:00") if args.to_date.endswith("Z") else args.to_date
            end_time = datetime.fromisoformat(to_date_str)
            if end_time.tzinfo is None:
                end_time = end_time.replace(tzinfo=timezone.utc)
            else:
                end_time = end_time.astimezone(timezone.utc)
            # Cap to now if in future
            if end_time > now_utc:
                end_time = now_utc
        except ValueError as e:
            print(f"Error parsing --to-date '{args.to_date}': {e}", file=sys.stderr)
            return 2
    else:
        end_time = now_utc

    lookback_days = (now_utc - start_time).days
    if args.period == "5minute" and lookback_days > 15:
        print(
            "Warning: 5-minute statistics are short-term in Home Assistant and may not cover "
            "the full lookback window. Use --period hour for long-term scans."
        )

    client = HAWebSocketClient(base_url=base_url, token=token)
    await client.connect()
    try:
        # --- Determine entity list ---
        if args.all_energy:
            entities = await get_energy_entities(client)
            if not entities:
                print("No energy entities found in the energy dashboard configuration.", file=sys.stderr)
                return 3
        else:
            entities = [args.entity]

        # --- Filter out ignored entities ---
        ignore_set = set()
        if args.ignore_entities:
            ignore_set = {e.strip() for e in args.ignore_entities.split(",")}
            before_count = len(entities)
            entities = [e for e in entities if e not in ignore_set]
            if args.all_energy:
                print(f"Found {before_count} energy entities on the dashboard.")
                if ignore_set:
                    print(f"Ignoring {len(ignore_set)} entity/entities: {', '.join(sorted(ignore_set))}")
                print(f"Scanning {len(entities)} entity/entities:")
            for e in entities:
                print(f"  {e}")
            print()
        else:
            if args.all_energy:
                print(f"Found {len(entities)} energy entities on the dashboard:")
                for e in entities:
                    print(f"  {e}")
                print()

        # --- Fetch metadata for all entities at once ---
        metadata_rows = await client.command(
            {"type": "recorder/list_statistic_ids", "statistic_type": "sum"}
        )
        metadata_map = {row["statistic_id"]: row for row in metadata_rows}

        period = args.period
        types = ["change", "state", "sum"]

        # --- Scan each entity ---
        all_spikes: list[tuple[str, str, Spike]] = []  # (entity_id, unit, spike)

        for entity_id in entities:
            metadata = metadata_map.get(entity_id)
            if metadata is None:
                if args.all_energy:
                    print(f"[{entity_id}] not found in sum statistics, skipping.")
                else:
                    print(f"Statistic ID '{entity_id}' not found among sum statistics.", file=sys.stderr)
                    return 3
                continue

            stat_unit = (
                metadata.get("statistics_unit_of_measurement")
                or metadata.get("display_unit_of_measurement")
                or "?"
            )

            stats_result = await client.command(
                {
                    "type": "recorder/statistics_during_period",
                    "start_time": start_time.isoformat(),
                    "end_time": end_time.isoformat(),
                    "statistic_ids": [entity_id],
                    "period": period,
                    "types": types,
                }
            )
            rows = stats_result.get(entity_id, [])
            spikes = _extract_spikes(rows, threshold=args.threshold)

            if not args.all_energy:
                # Single-entity mode: print per-entity summary header
                print(f"Entity: {entity_id}")
                print(f"Period: {period}")
                if args.from_date or args.to_date:
                    print(f"Time range: {start_time.isoformat()} to {end_time.isoformat()}")
                else:
                    print(f"Lookback days: {args.lookback_days}")
                print(f"Threshold: {args.threshold} {stat_unit}")
                print(f"Rows analyzed: {len(rows)}")
                print(f"Spikes found: {len(spikes)}")
            else:
                spike_label = f"{len(spikes)} spike(s)" if spikes else "no spikes"
                print(f"  [{entity_id}] {len(rows)} rows, {spike_label}")

            for spike in spikes:
                all_spikes.append((entity_id, stat_unit, spike))

        # --- Print combined spike table ---
        if args.all_energy:
            if args.from_date or args.to_date:
                print(f"\nTime range: {start_time.isoformat()} to {end_time.isoformat()} | Period: {period} | Threshold: {args.threshold}")
            else:
                print(f"\nLookback: {args.lookback_days} days | Period: {period} | Threshold: {args.threshold}")
            print(f"Total spikes found: {len(all_spikes)} across {len(entities)} entities")

        if not all_spikes:
            print("\nNo spikes at or above threshold were found.")
            return 0

        # Sort by entity, then chronologically
        all_spikes.sort(key=lambda t: (t[0], t[2].start_ms))

        col_entity = max(len(e) for e, _, _ in all_spikes) + 2
        col_entity = max(col_entity, 20)
        print()
        print(f"{'entity':<{col_entity}} {'start_local':<32} {'change':>10} {'unit':<6}")
        print("-" * (col_entity + 52))
        for entity_id, unit, spike in all_spikes:
            print(
                f"{entity_id:<{col_entity}} "
                f"{_ms_to_local_iso(spike.start_ms):<32} "
                f"{spike.change:>10.4f} "
                f"{unit:<6}"
            )
        print("-" * (col_entity + 52))

        if not args.apply:
            print(
                f"\nDry run only. {len(all_spikes)} spike(s) detected. "
                "Re-run with --apply to adjust these spikes to 0 change."
            )
            return 0

        if not args.yes:
            answer = input(f"\nType APPLY to correct all {len(all_spikes)} spike(s): ").strip()
            if answer != "APPLY":
                print("Aborted. No changes applied.")
                return 0

        print(f"\nApplying {len(all_spikes)} adjustment(s)...")
        for entity_id, unit, spike in all_spikes:
            adjustment_unit = args.unit or unit
            await client.command(
                {
                    "type": "recorder/adjust_sum_statistics",
                    "statistic_id": entity_id,
                    "start_time": _ms_to_utc_iso(spike.start_ms),
                    "adjustment": -spike.change,
                    "adjustment_unit_of_measurement": adjustment_unit,
                }
            )
            print(
                f"  [{entity_id}] {_ms_to_local_iso(spike.start_ms)} "
                f"adjusted by {-spike.change:.4f} {adjustment_unit}"
            )

        # Verify
        remaining_total = 0
        for entity_id in {e for e, _, _ in all_spikes}:
            verify_result = await client.command(
                {
                    "type": "recorder/statistics_during_period",
                    "start_time": start_time.isoformat(),
                    "end_time": end_time.isoformat(),
                    "statistic_ids": [entity_id],
                    "period": period,
                    "types": types,
                }
            )
            remaining = _extract_spikes(verify_result.get(entity_id, []), threshold=args.threshold)
            remaining_total += len(remaining)
            for spike in remaining:
                print(
                    f"  STILL PRESENT [{entity_id}] {_ms_to_local_iso(spike.start_ms)} "
                    f"change={spike.change:.4f}"
                )

        print(f"\nVerification complete. Remaining spikes >= {args.threshold}: {remaining_total}")
        if remaining_total:
            print("Some spikes remain (possibly overlapping corrections or different source pattern).")
        return 0
    finally:
        await client.close()



def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Detect and optionally correct Home Assistant long-term statistics spikes"
    )
    parser.add_argument(
        "--url",
        default=None,
        help="Home Assistant base URL (for example: http://homeassistant.local:8123)",
    )
    parser.add_argument(
        "--token",
        default=None,
        help="Long-lived access token (or set HA_TOKEN env var)",
    )
    parser.add_argument(
        "--all-energy",
        action="store_true",
        help="Scan all energy sensors from the HA energy dashboard (ignores --entity)",
    )
    parser.add_argument(
        "--entity",
        default="sensor.jasmijn_office_energy",
        help="Statistic ID / entity ID to inspect (ignored when --all-energy is set)",
    )
    parser.add_argument(
        "--lookback-days",
        type=int,
        default=365,
        help="How many days back to inspect (ignored if --from-date is specified)",
    )
    parser.add_argument(
        "--from-date",
        default=None,
        help="Start of scan range in ISO format (e.g., 2025-01-01 or 2025-01-01T12:00:00Z)",
    )
    parser.add_argument(
        "--to-date",
        default=None,
        help="End of scan range in ISO format; if future, capped to now (e.g., 2026-12-31 or 2026-05-22T23:59:59Z)",
    )
    parser.add_argument(
        "--ignore-entities",
        default=None,
        help="Comma-separated list of entity IDs to skip (e.g., 'sensor.solar,sensor.ev_charger')",
    )
    parser.add_argument(
        "--period",
        choices=["5minute", "hour", "day", "week", "month", "year"],
        default="hour",
        help="Statistics period resolution",
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=2.0,
        help="Spike threshold in statistic unit",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Apply corrections using recorder/adjust_sum_statistics",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Skip interactive APPLY prompt (only relevant with --apply)",
    )
    parser.add_argument(
        "--unit",
        default=None,
        help="Override adjustment unit (defaults to statistic metadata unit)",
    )
    return parser.parse_args()


if __name__ == "__main__":
    raise SystemExit(asyncio.run(run(parse_args())))
