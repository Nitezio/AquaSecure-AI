# AquaSecure frontend WebSocket contract

This is the integration boundary consumed by Sriram's Flutter frontend. The
backend team may keep its internal formats; it only needs to emit frames matching
one of the accepted shapes below.

## Connection

Default live endpoint:

```text
ws://localhost:8080/ws
```

Override it with the `WS_URL` Dart define or the URL-encoded `ws` query
parameter. The client retries dropped connections with exponential delays of
1, 2, 4, 8, 16, and 32 seconds.

Every WebSocket frame must be a UTF-8 JSON object. Malformed or unknown frames
are ignored so that a single bad payload cannot stop subsequent telemetry.

## Backend → frontend telemetry

Preferred format:

```json
{
  "type": "telemetry",
  "timestamp": "2026-08-11T12:00:00Z",
  "sensors": {
    "AIT201": 7.12,
    "FIT101": 2.41,
    "MV101": 2
  }
}
```

Accepted compatibility format:

```json
{
  "timestamp": 1786449600000,
  "ait201": "7.12",
  "fit101": "2.41",
  "mv101": "OPEN"
}
```

Parsing rules:

- `timestamp` accepts ISO 8601, Unix seconds, or Unix milliseconds.
- Sensor values accept JSON numbers or numeric strings.
- Native SWaT `MV101` values are interpreted as `1 = closed`, `2 = open`, and
  `0 = transitioning`.
- Boolean and text values such as `true`, `false`, `OPEN`, and `CLOSED` are also
  accepted for `MV101`.

## Backend → frontend anomaly alert

Preferred format:

```json
{
  "type": "alert",
  "anomaly": true,
  "id": "attack-017",
  "timestamp": "2026-08-11T12:00:05Z",
  "severity": "critical",
  "sensor": "AIT201",
  "title": "CHEMICAL PROCESS ANOMALY",
  "message": "Rapid pH deviation detected in Stage P2 treatment feed.",
  "confidence": 0.974,
  "explanation": "AIT201 was the strongest contributor to the anomaly score.",
  "violatedRule": "pH moved without a corresponding process-state change.",
  "recommendation": "Verify AIT201 locally and maintain manual override.",
  "contributors": [
    { "sensor": "AIT201", "impact": 0.76, "value": 9.42 },
    { "sensor": "FIT101", "impact": 0.16, "value": 2.47 },
    { "sensor": "MV101", "impact": 0.08, "value": 2 }
  ]
}
```

Compatibility aliases include `event: "anomaly"`, `isAnomaly: true`,
`alertId`, `source`, `reason`, `anomalyScore`, `xaiExplanation`, `physicsRule`,
and `featureContributions`. Confidence may be `0..1` or `0..100`.

Only the backend/AI role calculates anomaly scores, explanations, physics rules,
and contributors. Flutter displays the values it receives.

## Backend → frontend clear

The backend can explicitly clear an active alert with either:

```json
{ "type": "reset" }
```

or:

```json
{ "type": "clear" }
```

## Frontend → backend acknowledgement

When the operator clicks **Acknowledge Alarm**, live mode sends:

```json
{
  "type": "alert_acknowledgement",
  "alertId": "attack-017",
  "acknowledgedAt": "2026-08-11T12:00:12.000Z"
}
```

The UI immediately returns to monitoring mode. The backend may log or route the
acknowledgement but should not interpret this prototype message as proof that a
real field device was physically isolated or reset.
