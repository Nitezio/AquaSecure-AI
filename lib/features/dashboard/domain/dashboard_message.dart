import 'telemetry_snapshot.dart';
import 'threat_alert.dart';

sealed class DashboardMessage {
  const DashboardMessage();
}

class TelemetryMessage extends DashboardMessage {
  const TelemetryMessage(this.snapshot);

  final TelemetrySnapshot snapshot;
}

class AlertMessage extends DashboardMessage {
  const AlertMessage(this.alert);

  final ThreatAlert alert;
}

class ResetMessage extends DashboardMessage {
  const ResetMessage();
}
