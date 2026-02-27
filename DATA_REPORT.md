## 301360037

## Maaz Bobat

### Task 1 – Data Understanding (Documentation)

In this `README.md` (or a separate `DATA_REPORT.md` if you prefer), briefly describe:

- The main entities in the dataset (see `data/` folder).
- **Data Quality**: Identify issues such as missing values, duplicates, or inconsistent formatting (e.g., location names).
- **Schema**: Explain how you handled the `payload` field in the `events` table (Note: It contains JSON data).
- Assumptions you had to make.

---

## Main Entities

#============================================================
ENTITY: Users
FILE: users.csv
VOLUME: 121 rows raw, 4 columns, 120 after removing 1 duplicate
DESCRIPTION: Represents the end users of the IoT platform.
Each user can own one or more devices.
KEY FIELDS: `user_id`, `signup_date`, `region`, `platform`
#------------------------------------------------------------
ENTITY: Devices
FILE: devices.csv
VOLUME: 450 rows, 6 columns
DESCRIPTION: Represents IoT devices registered to users.
Each device belongs to one user (via `user_id`)
and emits many events.
NETWORKS: Ayla and Tuya (distinct payload structures).
KEY FIELDS: `device_id`, `user_id`, `network`, `device_type`,
`firmware_version`, `location`
#------------------------------------------------------------
ENTITY: Events
FILE: events.csv
VOLUME: 15,000 rows, 6 columns
DESCRIPTION: Represents telemetry events emitted by
devices. All events are of type "telemetry".
Date range: 2024-01-01 -> 2024-02-07
NOTE: `event_value` contains "see_payload". Real
values are in the `payload` JSON column.
KEY FIELDS: `event_id`, `device_id`, `event_type`,
`event_value`, `event_ts`, `payload`
#------------------------------------------------------------
RELATIONSHIPS:
Users (1) -> Devices (many) -> Events (many)
#============================================================

## Data Quality

#============================================================
ISSUE: Duplicate user_id
TABLE: Users
DETAIL: 1 duplicate found
RESOLUTION: Dropped, kept first occurrence

---

ISSUE: Inconsistent region names
TABLE: Users
DETAIL: "United States", "USA", "US" and "Canada",
"can", "CA" all present
RESOLUTION: Normalized to 2-letter codes: US, CA, KR, JP
#------------------------------------------------------------
ISSUE: Missing user_id
TABLE: Devices
DETAIL: 25 devices have no linked user
RESOLUTION: Flagged with user_id_missing boolean column;
kept in dataset
#------------------------------------------------------------
ISSUE: Missing location
TABLE: Devices
DETAIL: 108 of 450 devices (24%) have no location
RESOLUTION: Filled with "Unknown"
#------------------------------------------------------------
ISSUE: Beta firmware
TABLE: Devices
DETAIL: 115 devices running 3.5.beta firmware
RESOLUTION: Flagged — may produce unreliable telemetry
#------------------------------------------------------------
ISSUE: Beta firmware + no user_id
TABLE: Devices
DETAIL: 4 devices are both on beta firmware and
unlinked to a user
RESOLUTION: Flagged as highest data quality risk
#------------------------------------------------------------
ISSUE: Duplicate timestamps
TABLE: Events
DETAIL: 24 events share a timestamp with another event
RESOLUTION: Kept all rows — likely batch reporting
#------------------------------------------------------------
ISSUE: Placeholder event_value
TABLE: Events
DETAIL: All 15,000 rows contain "see_payload"
RESOLUTION: Documented — real values extracted from payload
#============================================================

## Schema — Payload Field

#============================================================
DESCRIPTION: The `payload` column contains raw JSON with two
distinct structures depending on the network.
#------------------------------------------------------------
NETWORK: Ayla (metadata + datapoint)
STRUCTURE:
{
"metadata": { "oem_model": "door_sensor", "dsn": "ACD6F3E680-6" },
"datapoint": { "property": "contact_state", "value": 1, "echo": false }
}
LOGIC: Field name is in `datapoint.property` and
reading is in `datapoint.value`.
PROPERTIES: `contact_state`, `local_temperature`, `connectivity`
#------------------------------------------------------------
NETWORK: Tuya (status[] list)
STRUCTURE:
{
"status": [
{ "code": "cur_voltage", "value": 2301 },
{ "code": "cur_current", "value": 412 },
{ "code": "cur_power", "value": 890 }
]
}
LOGIC: Values are stored as a list of `{code, value}`
pairs — a single event can carry multiple
readings.
CODES: `generic_state`, `switch_led`, `switch_1`,
`cur_voltage`, `cur_current`, `cur_power`,
`local_temperature`
SCALING: `cur_voltage` ÷ 10 = volts,
`cur_current` ÷ 1000 = amps,
`cur_power` ÷ 10 = watts.
#------------------------------------------------------------
PARSING: Parsed via `parse_payload()` into columns:
`source`, `extracted_code`, `extracted_value`,
`temperature_c`, `voltage_v`, `current_a`, `power_w`

APPROACH: A custom `parse_payload()` function detects
the structure by checking for the presence of
"metadata" (Ayla) or "status" (Tuya) keys,
then extracts values into normalized columns:
`source`, `extracted_code`, `extracted_value`,
`temperature_c`, `voltage_v`, `current_a`,
`power_w`. The original `payload` column
is retained as is for reference.

# RESULT: 6,681 Ayla and 8,319 Tuya events (0 errors).

## Assumptions

============================================================
REGION: "United States", "USA", and "US" treated as
identical. Same for "Canada" and "can".
Unmapped values fall to "Other".
#------------------------------------------------------------
ORPHANS: 25 devices with no `user_id` were retained
(749 events). May represent unregistered
or shared devices.
#------------------------------------------------------------
BETA: Events from `3.5.beta` devices are flagged
for caution but not excluded.
#------------------------------------------------------------
DUPLICATES: 24 duplicate timestamps retained since
`event_id` values are all unique.
#------------------------------------------------------------
SCALING: Tuya raw integers for voltage, current, and
power divided by 10, 1000, and 10.
#------------------------------------------------------------
EVENTS: All 15,000 events are `telemetry`. No
filtering needed. Timestamps UTC (ISO).
#============================================================
