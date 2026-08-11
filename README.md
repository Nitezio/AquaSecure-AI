# AquaSecure AI — Flutter control room

Sriram's frontend for the AquaSecure AI SWaT cybersecurity prototype. The app
renders live pH, flow, and valve telemetry; raises a visual facility lockdown;
and presents operator-facing XAI and physics-rule explanations supplied by the
backend.

This repository intentionally contains only the Flutter frontend. It does not
stream the SWaT dataset, run anomaly inference, configure Genkit, or orchestrate
containers.

## Included

- Responsive industrial control-room UI for desktop, tablet, and mobile
- Live AIT201 pH and FIT101 flow charts with operating thresholds
- MV101 actuator status and manual-override presentation
- Normal, disconnected, reconnecting, critical, and acknowledged states
- Reconnecting WebSocket client with tolerant payload parsing
- Deterministic demo stream and one-click attack simulation
- XAI feature attribution and physics-invariant explanation panel
- Six-stage process map, event audit trail, and system-health summary
- Unit and widget tests for payload parsing and the full alarm lifecycle

## Run locally

The default is a self-contained demonstration feed:

```powershell
flutter run -d chrome
```

Click **Run Attack Demo** to trigger the critical UI. Click
**Acknowledge Alarm** to clear it.

For the real Node.js WebSocket backend:

```powershell
flutter run -d chrome `
  --dart-define=DATA_MODE=live `
  --dart-define=WS_URL=ws://localhost:8080/ws
```

Runtime query parameters are also supported for a prebuilt web app:

```text
/?mode=live&ws=ws%3A%2F%2Flocalhost%3A8080%2Fws
```

Use `wss://` when the dashboard itself is served over HTTPS.

## Verify

```powershell
flutter analyze
flutter test
flutter build web --release
```

The production output is written to `build/web`.

## Integration

The complete frontend-facing WebSocket contract is documented in
[`docs/WEBSOCKET_CONTRACT.md`](docs/WEBSOCKET_CONTRACT.md). Payload translation
is isolated in `lib/features/dashboard/domain`, while connection and retry logic
is isolated in `lib/features/dashboard/data`. Backend changes should not require
editing dashboard widgets.

## Key source locations

- `lib/features/dashboard/presentation/dashboard_screen.dart` — responsive page
- `lib/features/dashboard/application/dashboard_controller.dart` — UI state
- `lib/features/dashboard/data/web_socket_telemetry_gateway.dart` — live socket
- `lib/features/dashboard/data/mock_telemetry_gateway.dart` — demo stream
- `lib/features/dashboard/domain` — typed integration models
- `lib/features/dashboard/presentation/widgets` — reusable dashboard components

## Safety boundary

The lockdown and air-gap states are operator-facing prototype visuals. The
frontend never claims to have isolated a real PLC and does not issue equipment
control commands. Real control acknowledgement must be implemented and verified
by the appropriate backend and systems-integration roles.
