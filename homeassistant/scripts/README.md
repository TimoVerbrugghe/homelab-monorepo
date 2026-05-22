# Home Assistant Energy Spike Detector & Fixer

A Python tool to detect and correct anomalous energy spikes in Home Assistant long-term statistics using the official WebSocket recorder API.

## Overview

Home Assistant tracks cumulative energy consumption via `sum`-type statistics. Spikes occur when the recorded "change" in a statistic period is abnormally large—often caused by:

- **Sensor resets** (e.g., device firmware update, integration restart)
- **Database corruption** or migration issues
- **Integration bugs** reporting incorrect deltas
- **Legitimate high-consumption periods** (heavy appliance operation, solar peak generation)

This tool:
1. **Detects** both positive and negative spikes by querying statistics over a time range and filtering by threshold
2. **Displays** them in a clean table with entity ID, timestamp, and change amount
3. **Corrects** them by issuing negative adjustments via `recorder/adjust_sum_statistics` (HA ≥ 2024.6)

## Installation

Ensure Python 3.9+ and the `websockets` package are installed:

```bash
pip install websockets
```

## Authentication

Provide Home Assistant credentials via CLI flags or environment variables:

- **`--url`** / `HA_URL`: Base URL (e.g., `http://homeassistant.local:8123`)
- **`--token`** / `HA_TOKEN`: Long-lived access token

To create a token:
1. In Home Assistant, go to **Settings > User > Create Long-Lived Access Token**
2. Copy the token and store it securely (e.g., `.env` file, environment variable)

Example (env var):
```bash
export HA_URL=http://homeassistant.local:8123
export HA_TOKEN=eyJhbGc...
./fix_energy_spikes.py --all-energy
```

## Quick Start

### Scan a single entity (dry-run)
```bash
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --entity sensor.living_room_energy \
  --lookback-days 365 \
  --threshold 2
```

./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --entity sensor.office_energy \
  --lookback-days 365 \
  --threshold 2
### Scan all energy dashboard entities (dry-run)
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --entity sensor.office_energy \
  --lookback-days 365 \
  --threshold 2
```

### Scan all energy dashboard entities (dry-run)
```bash
```bash
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --all-energy \
  --lookback-days 365 \
  --threshold 5
```

### Apply corrections (with confirmation)
```bash
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --all-energy \
  --lookback-days 365 \
  --threshold 5 \
  --apply
```

Type `APPLY` when prompted to execute corrections.

### Scan a specific date range
```bash
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --all-energy \
  --from-date 2025-01-01 \
  --to-date 2025-12-31 \
  --threshold 2
```

### Ignore specific entities
```bash
./fix_energy_spikes.py \
  --url http://homeassistant.local:8123 \
  --token 'your-token-here' \
  --all-energy \
  --ignore-entities 'sensor.solar_production,sensor.ev_charger' \
  --threshold 2
```

## Command-Line Options

### Entity Selection
- **`--entity ENTITY_ID`** (default: `sensor.office_energy`)  
  Single entity to scan. Ignored if `--all-energy` is set.

- **`--all-energy`**  
  Scan all energy sensors linked to the HA energy dashboard. Overrides `--entity`.

- **`--ignore-entities COMMA_SEPARATED_LIST`**  
  Exclude specific entities from scanning. Example: `sensor.solar,sensor.ev_charger`

### Time Range
- **`--lookback-days DAYS`** (default: `365`)  
  How many days back to scan. Ignored if `--from-date` is provided.

- **`--from-date ISO_DATE`**  
  Start of scan range in ISO 8601 format. Examples:
  - `2025-01-01` (midnight UTC)
  - `2025-06-15T12:30:00Z` (specific time in UTC)
  - `2025-06-15T12:30:00+02:00` (with timezone offset)
  
  If data doesn't exist for this period, the script returns empty results (graceful handling).

- **`--to-date ISO_DATE`**  
  End of scan range in ISO 8601 format. If the date is in the future, it's automatically capped to the current time.

### Filtering
- **`--threshold FLOAT`** (default: `2.0`)  
  Minimum change (in statistic unit) to flag as a spike. Use higher values to skip likely-legitimate spikes (e.g., `--threshold 10` for solar/EV chargers).
- **`--threshold FLOAT`** (default: `2.0`)  
  Minimum absolute change in the statistic's unit (kWh for energy, m³ for gas, etc.) to flag as a spike. Use higher values to skip likely-legitimate spikes (e.g., `--threshold 10` for solar/EV chargers).

- **`--threshold FLOAT`** (default: `2.0`)  
  Minimum absolute change in the statistic's unit (kWh for energy, m³ for gas, etc.) to flag as a spike. Use higher values to skip likely-legitimate spikes (e.g., `--threshold 10` for solar/EV chargers).
- **`--period {5minute, hour, day, week, month, year}`** (default: `hour`)  
  Statistics aggregation period. Use `hour` for annual scans; `5minute` only covers ~10 days.

### Actions
- **`--apply`**  
  Apply corrections instead of just reporting spikes.

- **`--yes`**  
  Skip interactive confirmation when using `--apply`.

### Other
- **`--unit UNIT`**  
  Override the adjustment unit (defaults to statistic metadata unit). Rarely needed.

- **`--url URL`** / **`--token TOKEN`**  
  Authentication (or use `HA_URL` and `HA_TOKEN` environment variables).

## Output Examples

### Single-Entity Dry-Run
```
Entity: sensor.living_room_energy
Period: hour
Lookback days: 365
Threshold: 2.0 kWh
Rows analyzed: 8759
Spikes found: 12

entity                    start_local                      change unit  
------------------------------------------------------------------
sensor.living_room_energy 2025-07-19T10:00:00+02:00        2.0500 kWh   
sensor.living_room_energy 2025-08-06T07:00:00+02:00        2.1800 kWh   
sensor.living_room_energy 2025-10-29T08:00:00+01:00       34.7000 kWh   
Entity: sensor.office_energy
Period: hour
Lookback days: 365
Threshold: 2.0 kWh
Rows analyzed: 8759
Spikes found: 12
entity                start_local                      change unit  
---------------------------------------------------------------
sensor.office_energy  2025-07-19T10:00:00+02:00        2.0500 kWh   
sensor.office_energy  2025-08-06T07:00:00+02:00        2.1800 kWh   
sensor.office_energy  2025-10-29T08:00:00+01:00       34.7000 kWh

Dry run only. 3 spike(s) detected. Re-run with --apply to adjust these spikes to 0 change.
```

### Multi-Entity Dry-Run
```
Found 19 energy entities on the dashboard.
Ignoring 3 entity/entities: sensor.energy_produced_tariff_1, sensor.energy_produced_tariff_2, sensor.tesla_wall_connector_energy
Scanning 16 entity/entities:
  [sensor.all_lights_energy] 8759 rows, 4 spike(s)
  [sensor.bathroom_energy] 3335 rows, 2 spike(s)
  [sensor.jasmijn_office_energy] 8759 rows, 27 spike(s)
  ...

Lookback: 365 days | Period: hour | Threshold: 2.0
Total spikes found: 142 across 16 entities

entity                    start_local                      change unit  
------------------------------------------------------------------
sensor.all_lights_energy  2025-07-19T10:00:00+02:00       2.0500 kWh   
sensor.bathroom_energy    2026-03-13T04:00:00+01:00       3.5200 kWh   
sensor.jasmijn_office_energy 2026-03-07T14:00:00+01:00    6.3900 kWh   
Found 19 energy entities on the dashboard.
Ignoring 3 entity/entities: sensor.solar_production, sensor.solar_production_tariff_2, sensor.ev_charger
Scanning 16 entity/entities:
  [sensor.lights_energy] 8759 rows, 4 spike(s)
  [sensor.bedroom_energy] 3335 rows, 2 spike(s)
  [sensor.office1_energy] 8759 rows, 27 spike(s)
  ...
Lookback: 365 days | Period: hour | Threshold: 2.0
Total spikes found: 142 across 16 entities
entity                 start_local                      change unit  
---------------------------------------------------------------
sensor.lights_energy   2025-07-19T10:00:00+02:00       2.0500 kWh   
sensor.bedroom_energy  2026-03-13T04:00:00+01:00       3.5200 kWh   
sensor.office1_energy  2026-03-07T14:00:00+01:00       6.3900 kWh

Dry run only. 142 spike(s) detected. Re-run with --apply to adjust these spikes to 0 change.
```

## Spike Thresholds: When to Fix

**Rule of thumb:**
The script detects spikes based on absolute value. A spike is flagged when `|change| >= threshold`.

- **Positive spikes** (↑): Energy jumps up unexpectedly
- **Negative spikes** (↓): Energy drops unexpectedly

**By magnitude:**
- **≤ 4 kWh spikes**: Likely integration bugs or sensor resets. Safe to fix.
- **5–10 kWh spikes**: Possible transients or aggregation artifacts. Inspect before fixing.
- **> 10 kWh spikes**: Often legitimate high-consumption periods or peak generation. Only fix if you're confident they're anomalous.
**By magnitude (kWh example):**
- **≤ 4 kWh spikes**: Likely integration bugs or sensor resets. Safe to fix.
- **5–10 kWh spikes**: Possible transients or aggregation artifacts. Inspect before fixing.
- **> 10 kWh spikes**: Often legitimate high-consumption periods or peak generation. Only fix if you're confident they're anomalous.
The script detects spikes based on absolute value. A spike is flagged when `|change| >= threshold`, where threshold is in the statistic unit (kWh, m³, etc.).

**Negative spikes** often appear as pairs with positive spikes (e.g., `-30.55 kWh` then `+30.55 kWh`), indicating sensor resets. These are safe to correct.

**Recommended approach:**
1. Run a dry-run with `--threshold 2` to see all spikes (both positive and negative).
2. Review the table and identify patterns (e.g., paired pos/neg spikes, all small spikes from a single entity).
3. Re-run with `--ignore-entities` to skip known good data sources (solar, EV charger).
4. Use a higher `--threshold` to focus on obvious anomalies.
5. Apply corrections incrementally, verifying each batch.

## Workflow Example: Cleaning Multiple Entities

```bash
# Step 1: Find all spikes across the dashboard
./fix_energy_spikes.py --all-energy --lookback-days 365 --threshold 2

# Step 2: Review the output; note entities with excessive spikes

# Step 3: Re-run, ignoring legitimate high-use entities
./fix_energy_spikes.py \
  --all-energy \
  --lookback-days 365 \
  --threshold 2 \
  --ignore-entities 'sensor.energy_produced_tariff_1,sensor.tesla_wall_connector_energy'

# Step 4: Increase threshold to focus on clearer anomalies
./fix_energy_spikes.py \
  --all-energy \
  --lookback-days 365 \
  --threshold 5 \
  --ignore-entities 'sensor.energy_produced_tariff_1,sensor.tesla_wall_connector_energy'

# Step 5: Apply fixes with confirmation
./fix_energy_spikes.py \
  --all-energy \
  --lookback-days 365 \
  --threshold 5 \
  --ignore-entities 'sensor.energy_produced_tariff_1,sensor.tesla_wall_connector_energy' \
  --apply

# Step 6: Re-run to verify spikes are gone
./fix_energy_spikes.py \
  --all-energy \
  --lookback-days 365 \
  --threshold 5 \
  --ignore-entities 'sensor.energy_produced_tariff_1,sensor.tesla_wall_connector_energy'
```

## Date Range Examples

### Scan Q1 2025
```bash
./fix_energy_spikes.py \
  --all-energy \
  --from-date 2025-01-01 \
  --to-date 2025-03-31 \
  --threshold 2
```

### Scan from March 2025 to today
```bash
./fix_energy_spikes.py \
  --all-energy \
  --from-date 2025-03-01 \
  --threshold 2
  # (--to-date omitted, defaults to now)
```

### Scan a specific week
```bash
./fix_energy_spikes.py \
  --entity sensor.living_room_energy \
  --from-date 2025-07-15T00:00:00Z \
  --to-date 2025-07-21T23:59:59Z \
  --period hour
./fix_energy_spikes.py \
  --entity sensor.office_energy \
  --from-date 2025-07-15T00:00:00Z \
  --to-date 2025-07-21T23:59:59Z \
  --period hour
```

### Handle future dates gracefully
```bash
./fix_energy_spikes.py \
  --all-energy \
  --from-date 2026-01-01 \
  --to-date 2099-12-31 \
  --threshold 2
  # to-date is in future, so it's capped to now; script runs without error
```

## How It Works

### Detection
1. Fetches metadata for all specified energy entities
2. Queries hourly (or other period) statistics within the date range
3. Filters rows where the absolute change magnitude exceeds the threshold: `|change| >= threshold`
4. Detects both positive spikes (↑) and negative spikes (↓)
5. Displays results sorted by entity and timestamp

### Correction
1. For each spike, calculates the negative adjustment: `adjustment = -change`
2. Sends `recorder/adjust_sum_statistics` command with:
   - `statistic_id`: the entity's sensor ID
   - `start_time`: the spike's UTC timestamp
   - `adjustment`: the negative delta
   - `adjustment_unit_of_measurement`: the statistic unit (kWh, m³, etc.)
3. Verification query confirms the spike is gone (change → 0)

**Note:** Adjustments cascade to all later rows in the cumulative total automatically.

## Troubleshooting

### "Message too big" WebSocket error
The script has been tuned to handle large responses (16 MB frame size), but if you hit this with many entities, try:
- Reduce `--lookback-days`
- Increase `--threshold` to return fewer spikes
- Use `--ignore-entities` to exclude high-volume entities (solar, EV charger)

### No results for a date range
If your `--from-date` is before Home Assistant started recording, the script returns empty results (gracefully). This is expected.

### Future --to-date is rejected
If you pass a `--to-date` that's in the future, the script automatically caps it to now. No error.

### Changes not applied despite --apply
1. Verify you typed `APPLY` correctly (case-sensitive)
2. Check Home Assistant logs for recorder errors
3. Ensure the token has recorder permissions (usually automatic for admin users)
4. Re-run a dry-run to confirm spikes are still present (they may take a few seconds to process)

## Requirements

- **Python 3.9+**
- **websockets** package
- **Home Assistant 2024.6+** (for `recorder/adjust_sum_statistics` support)
- **Long-lived access token** with recorder access

## License & Attribution

This script uses Home Assistant's official WebSocket API. It is provided as-is for local use.

---

**Last Updated:** May 2026  
**Tested on:** Home Assistant 2026.5.3
